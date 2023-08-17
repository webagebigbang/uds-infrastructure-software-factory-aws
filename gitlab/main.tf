data "aws_partition" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  elasticache_subnet_group_name = var.create_cache_testing_subnets ? aws_elasticache_subnet_group.test_cache_subnet[0].name : var.elasticache_subnet_group_name
  vpc_id                        = var.create_cache_testing_vpc ? aws_vpc.test_vpc[0].id : var.vpc_id
}

# Object Storage Resources

module "s3_bucket" {
  for_each = toset(var.bucket_names)

  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.14.1"

  bucket        = "${var.bucket_name_prefix}${each.key}${var.bucket_name_suffix}"
  force_destroy = var.force_destroy
}

module "irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.28.0"

  role_name        = "${var.bucket_name_prefix}role${var.bucket_name_suffix}"
  role_description = "Role for GitLab to access buckets."

  role_permissions_boundary_arn = var.role_permissions_boundary_arn
  role_policy_arns = {
    "main" = aws_iam_policy.irsa_policy.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = [format("%s:%s", var.kubernetes_namespace, var.kubernetes_service_account)]
    }
  }
}

resource "aws_iam_policy" "irsa_policy" {
  name        = "${var.bucket_name_prefix}policy${var.bucket_name_suffix}"
  path        = "/"
  description = "IRSA policy to access GitLab buckets."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:ListBucket"]
        Resource = [
          for bucket_name in var.bucket_names :
          "arn:${data.aws_partition.current.partition}:s3:::${var.bucket_name_prefix}${bucket_name}${var.bucket_name_suffix}"
        ]
      },
      {
        Effect = "Allow"
        Action = ["s3:*Object"]
        Resource = [
          for bucket_name in var.bucket_names :
          "arn:${data.aws_partition.current.partition}:s3:::${var.bucket_name_prefix}${bucket_name}${var.bucket_name_suffix}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ]
        Resource = ["${module.kms_key.kms_key_arn}"]
      }
    ]
  })
}

module "kms_key" {
  source = "github.com/defenseunicorns/terraform-aws-uds-kms?ref=v0.0.2"

  kms_key_alias_name_prefix = var.kms_key_alias
  kms_key_deletion_window   = 7
  kms_key_description       = "GitLab Key"
}

# Redis Resources

resource "aws_elasticache_replication_group" "redis_cluster_mode" {
  replication_group_id = var.elasticache_cluster_name
  description          = "Redis Replication Group for GitLab"

  subnet_group_name = local.elasticache_subnet_group_name

  node_type            = "cache.r6g.large"
  engine_version       = "7.0"
  parameter_group_name = "default.redis7.cluster.on"

  num_cache_clusters = 2

  automatic_failover_enabled = true
  multi_az_enabled           = true

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
}

## These are used for testing Elasticache only.

resource "aws_vpc" "test_vpc" {
  count      = var.create_cache_testing_vpc ? 1 : 0
  cidr_block = "10.4.0.0/16"
}

resource "aws_subnet" "test_subnet0" {
  count             = var.create_cache_testing_subnets ? 1 : 0
  vpc_id            = aws_vpc.test_vpc[0].id
  cidr_block        = "10.4.6.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_subnet" "test_subnet1" {
  count             = var.create_cache_testing_subnets ? 1 : 0
  vpc_id            = local.vpc_id #aws_vpc.test_vpc[0].id
  cidr_block        = "10.4.7.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
}

resource "aws_elasticache_subnet_group" "test_cache_subnet" {
  count      = var.create_cache_testing_subnets ? 1 : 0
  name       = "test-cache-subnet"
  subnet_ids = [aws_subnet.test_subnet0[0].id, aws_subnet.test_subnet1[0].id]
}

data "aws_partition" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  db_subnet_group_name          = var.create_testing_resources ? module.db_subnet_group[0].db_subnet_group_id : var.gitlab_db_subnet_group_name
  elasticache_subnet_group_name = var.create_testing_resources ? aws_elasticache_subnet_group.test_cache_subnet[0].name : var.elasticache_subnet_group_name
}

# Object Storage Resources

## This will create a bucket for each name in `bucket_names`.
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

# RDS

module "gitlab_db" {
  source = "../modules/rds"

  identifier = "gitlab-db"

  db_name  = var.gitlab_db_name
  username = "gitlab"

  subnet_group_name = local.db_subnet_group_name

  password = var.gitlab_db_password
}

module "idam_db" {
  source = "../modules/rds"

  identifier = "keycloak-db"

  db_name  = var.idam_db_name
  username = "kcadmin"

  subnet_group_name = local.db_subnet_group_name

  password = var.idam_db_password
}

module "sonarqube_db" {
  source = "../modules/rds"

  identifier = "sonarqube-db"

  db_name  = var.sonarqube_db_name
  username = "sonarqube"

  subnet_group_name = local.db_subnet_group_name

  password = var.sonarqube_db_password
}

# Redis Resources

resource "aws_elasticache_cluster" "redis" {
  cluster_id = var.elasticache_cluster_name
  engine = "redis"
  node_type = "cache.r6g.large"
  num_cache_nodes = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.0"
  port = 6379
  subnet_group_name = local.elasticache_subnet_group_name
}

## These are used for testing Elasticache and RDS locally only.  CI will provide subnets.

resource "aws_vpc" "test_vpc" {
  count      = var.create_testing_resources ? 1 : 0
  cidr_block = "10.4.0.0/16"
}

resource "aws_subnet" "test_db_subnet0" {
  count             = var.create_testing_resources ? 1 : 0
  vpc_id            = aws_vpc.test_vpc[0].id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = "10.4.2.0/24"
}

resource "aws_subnet" "test_db_subnet1" {
  count             = var.create_testing_resources ? 1 : 0
  vpc_id            = aws_vpc.test_vpc[0].id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block        = "10.4.3.0/24"
}

module "db_subnet_group" {
  count   = var.create_testing_resources ? 1 : 0
  source  = "terraform-aws-modules/rds/aws//modules/db_subnet_group"
  version = "6.1.1"

  create     = var.create_testing_resources
  name       = "rds_db_subnet_group"
  subnet_ids = [aws_subnet.test_db_subnet0[0].id, aws_subnet.test_db_subnet1[0].id]
}

resource "aws_subnet" "test_cache_subnet0" {
  count             = var.create_testing_resources ? 1 : 0
  vpc_id            = aws_vpc.test_vpc[0].id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = "10.4.0.0/24"
}

resource "aws_subnet" "test_cache_subnet1" {
  count             = var.create_testing_resources ? 1 : 0
  vpc_id            = aws_vpc.test_vpc[0].id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block        = "10.4.1.0/24"
}

resource "aws_elasticache_subnet_group" "test_cache_subnet" {
  count      = var.create_testing_resources ? 1 : 0
  name       = "test-cache-subnet"
  subnet_ids = [aws_subnet.test_cache_subnet0[0].id, aws_subnet.test_cache_subnet1[0].id]
}

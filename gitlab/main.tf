data "aws_partition" "current" {}

module "s3_bucket" {
  for_each = toset(var.bucket_names)

  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.14.1"

  bucket        = "${var.name_prefix}${each.key}${var.name_suffix}"
  force_destroy = var.force_destroy
}

module "irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.28.0"

  role_name        = "${var.name_prefix}role"
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
  name        = "${var.name_prefix}policy"
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
          "arn:${data.aws_partition.current.partition}:s3:::${bucket_name}"
        ]
      },
      {
        Effect = "Allow"
        Action = ["s3:*Object"]
        Resource = [
          for bucket_name in var.bucket_names :
          "arn:${data.aws_partition.current.partition}:s3:::${bucket_name}/*"
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

  kms_key_alias_name_prefix = var.name_prefix
  kms_key_deletion_window   = 7
  kms_key_description       = "GitLab Key"
}

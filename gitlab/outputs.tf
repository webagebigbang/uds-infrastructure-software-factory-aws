output "irsa_arn" {
  value = module.irsa.iam_role_arn
}

# This will be a list of bucket names.
output "s3_bucket_id" {
  value = values(module.s3_bucket).*.s3_bucket_id
}

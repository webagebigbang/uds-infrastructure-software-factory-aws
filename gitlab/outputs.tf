output "iam_access_key_id" {
  value = module.s3_user.iam_access_key_id
}

output "iam_access_key_secret" {
  value     = module.s3_user.iam_access_key_secret
  sensitive = true
}

output "s3_bucket_id" {
  value = values(module.s3_bucket).*.s3_bucket_id
}

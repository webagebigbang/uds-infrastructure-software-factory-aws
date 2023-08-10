module "s3_bucket" {
  for_each = toset(var.bucket_names)

  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.14.1"

  bucket        = "${bucket_name_prefix}${each.key}${bucket_name_suffix}"
  force_destroy = var.force_destroy
}

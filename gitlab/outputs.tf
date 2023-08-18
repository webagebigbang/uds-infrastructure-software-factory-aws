output "elasticache_configuration_arn" {
  value = aws_elasticache_replication_group.redis_cluster_mode.arn
}

output "elasticache_configuration_id" {
  value = aws_elasticache_replication_group.redis_cluster_mode.id
}

output "elasticache_configuration_endpoint" {
  value = aws_elasticache_replication_group.redis_cluster_mode.configuration_endpoint_address
}

output "irsa_arn" {
  value = module.irsa.iam_role_arn
}

# This will be a list of bucket names.
output "s3_bucket_id" {
  value = values(module.s3_bucket).*.s3_bucket_id
}

# Object Storage

output "irsa_arn" {
  value = module.irsa.iam_role_arn
}

## This will be a list of bucket names.
output "s3_bucket_id" {
  value = values(module.s3_bucket).*.s3_bucket_id
}

# Elasticache
output "elasticache_configuration_arn" {
  value = aws_elasticache_replication_group.redis_cluster_mode.arn
}

output "elasticache_configuration_id" {
  value = aws_elasticache_replication_group.redis_cluster_mode.id
}

output "elasticache_configuration_endpoint" {
  value = aws_elasticache_replication_group.redis_cluster_mode.configuration_endpoint_address
}

# RDS

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = module.rds.db_instance_endpoint
  sensitive   = true
}

output "db_instance_name" {
  description = "The database name"
  value       = module.rds.db_instance_name
  sensitive   = true
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = module.rds.db_instance_username
  sensitive   = true
}

output "db_instance_master_user_secret_arn" {
  description = "The ARN of the master user secret"
  value       = module.rds.db_instance_master_user_secret_arn
  sensitive   = true
}

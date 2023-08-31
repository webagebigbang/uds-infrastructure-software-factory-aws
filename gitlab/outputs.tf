# Object Storage

output "irsa_arn" {
  value = module.irsa.iam_role_arn
}

## This will be a list of bucket names.
output "s3_bucket_id" {
  value = values(module.s3_bucket).*.s3_bucket_id
}

# Elasticache
output "redis_arn" {
  value = aws_elasticache_cluster.redis.arn
}

output "redis_cache_nodes" {
  value = aws_elasticache_cluster.redis.cache_nodes
}

# RDS

output "gitlab_db_instance_endpoint" {
  description = "GitLab DB connection endpoint"
  value       = module.gitlab_db.db_instance_endpoint
  sensitive   = true
}

output "gitlab_db_instance_name" {
  description = "GitLab DB name"
  value       = module.gitlab_db.db_instance_name
  sensitive   = true
}

output "gitlab_db_instance_username" {
  description = "The master username for the database"
  value       = module.gitlab_db.db_instance_username
  sensitive   = true
}

output "gitlab_db_instance_master_user_secret_arn" {
  description = "The ARN of the master user secret"
  value       = module.gitlab_db.db_instance_master_user_secret_arn
  sensitive   = true
}

output "idam_db_instance_endpoint" {
  description = "IDAM DB connection endpoint"
  value       = module.idam_db.db_instance_endpoint
  sensitive   = true
}

output "idam_db_instance_name" {
  description = "IDAM DB name"
  value       = module.idam_db.db_instance_name
  sensitive   = true
}

output "idam_db_instance_username" {
  description = "The master username for the database"
  value       = module.idam_db.db_instance_username
  sensitive   = true
}

output "idam_db_instance_master_user_secret_arn" {
  description = "The ARN of the master user secret"
  value       = module.idam_db.db_instance_master_user_secret_arn
  sensitive   = true
}

output "sonarqube_db_instance_endpoint" {
  description = "SonarQube DB connection endpoint"
  value       = module.sonarqube_db.db_instance_endpoint
  sensitive   = true
}

output "sonarqube_db_instance_name" {
  description = "SonarQube DB name"
  value       = module.sonarqube_db.db_instance_name
  sensitive   = true
}

output "sonarqube_db_instance_username" {
  description = "The master username for the database"
  value       = module.sonarqube_db.db_instance_username
  sensitive   = true
}

output "sonarqube_db_instance_master_user_secret_arn" {
  description = "The ARN of the master user secret"
  value       = module.sonarqube_db.db_instance_master_user_secret_arn
  sensitive   = true
}

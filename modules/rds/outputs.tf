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

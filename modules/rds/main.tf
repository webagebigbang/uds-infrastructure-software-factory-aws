module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.1.1"

  identifier = var.identifier #"gitlab-db"

  allocated_storage       = 20
  backup_retention_period = 1
  backup_window           = "03:00-06:00"
  maintenance_window      = "Mon:00:00-Mon:03:00"

  engine               = "postgres"
  engine_version       = "15.3"
  major_engine_version = "15"
  family               = "postgres15"
  instance_class       = "db.t4g.large"

  db_name  = var.db_name #var.gitlab_db_name
  username = var.username #"gitlab"
  port     = "5432"

  db_subnet_group_name = var.subnet_group_name #local.db_subnet_group_name

  manage_master_user_password = var.password == null
  password = var.password
}

variable "identifier" {
  description = "Identifier for RDS instance"
  type        = string
}

variable "db_name" {
  description = "Name of DB to create"
  type        = string
  default     = null
}

variable "username" {
  description = "DB user"
  type        = string
  default     = null
}

variable "subnet_group_name" {
  description = "Name of the DB subnet group"
  type        = string
  default     = null
}

variable "password" {
  description = "DB password. A null password will tell AWS to manage a password for us."
  type        = string
  default     = null
}

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

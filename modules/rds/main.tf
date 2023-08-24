module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.1.1"

  identifier = var.identifier

  allocated_storage       = 20
  backup_retention_period = 1
  backup_window           = "03:00-06:00"
  maintenance_window      = "Mon:00:00-Mon:03:00"

  engine               = "postgres"
  engine_version       = "15.3"
  major_engine_version = "15"
  family               = "postgres15"
  instance_class       = "db.t4g.large"

  db_name  = var.db_name
  username = var.username
  port     = "5432"

  db_subnet_group_name = var.subnet_group_name

  manage_master_user_password = var.password == null
  password = var.password
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = [for az_name in slice(data.aws_availability_zones.available.names, 0, min(length(data.aws_availability_zones.available.names), var.num_azs)) : az_name]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name                  = var.name                  #"oursler-swf"
  cidr                  = var.cidr                  #"10.0.0.0/16"
  secondary_cidr_blocks = var.secondary_cidr_blocks #["100.64.0.0/16"]
  azs                   = local.azs
  public_subnets        = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 4, k)]
  private_subnets       = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 4, k + 4)]
  database_subnets      = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 4, k + 8)]
  elasticache_subnets   = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 4, k + 12)]

  create_redshift_subnet_group = false

  enable_dns_hostnames = false
  enable_dns_support   = false

  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true
}

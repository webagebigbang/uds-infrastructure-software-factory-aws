data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = [for az_name in slice(data.aws_availability_zones.available.names, 0, min(length(data.aws_availability_zones.available.names), var.num_azs)) : az_name]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name                    = var.name
  cidr                    = var.cidr
  secondary_cidr_blocks   = var.secondary_cidr_blocks
  azs                     = local.azs
  public_subnets          = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 4, k)]
  private_subnets         = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 4, k + 4)]
  database_subnets        = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 4, k + 8)]
  elasticache_subnets     = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 4, k + 12)]
  map_public_ip_on_launch = true
  single_nat_gateway      = true
  enable_nat_gateway      = true

  create_redshift_subnet_group = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true
  vpc_flow_log_permissions_boundary    = var.vpc_flow_log_permissions_boundary
}

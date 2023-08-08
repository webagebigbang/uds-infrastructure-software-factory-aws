output "azs" {
  description = "A list of availability zones in the region"
  value       = module.vpc.azs
}

output "name" {
  description = "The name of the VPC"
  value       = module.vpc.name
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

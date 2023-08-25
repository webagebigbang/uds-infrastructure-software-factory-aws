variable "create_test_resources" {
  description = "Whether to create a VPC for local testing.  CI and other implementations should provide this."
  type        = bool
  default     = false
}

# used for testing only
# EKS module we're currently using expects 3 AZs which isn't cool
variable "num_azs" {
  description = "The number of AZs to attempt to use in a region."
  type        = number
  default     = 3
}

variable "vpc_id" {
  description = "VPC ID where the EKS will be deployed"
  type        = string
  default     = ""
}

variable "cluster_subnets" {
  description = "IDs of the subnets where the EKS cluster will be deployed"
  type        = list(string)
  default     = []
}

variable "cidr_blocks" {
  description = "Subnet CIDR blocks where the EKS cluster will be deployed"
  type        = list(string)
  default     = []
}

variable "cluster_cni_subnets" {
  description = "IDs of the subnets where the EKS worker nodes will be deployed"
  type        = list(string)
  default     = []
}

variable "iam_role_permissions_boundary" {
  description = "The ARN of the permissions boundary for IAM resources"
  type        = string
  default     = null
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "uds-swf-cluster"
}

variable "region" {
  description = "The AWS region to deploy into"
  type        = string
}


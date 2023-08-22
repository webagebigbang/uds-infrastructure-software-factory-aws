variable "create_test_resources" {
  description = "Whether to create a VPC for local testing.  CI and other implementations should provide this."
  type = bool
  default = false
}

variable "vpc_id" {
  description = "VPC ID where the EKS will be deployed"
  type = string
  default = ""
}

variable "cluster_subnets" {
  description = "IDs of the subnets where the EKS cluster will be deployed"
  type = list(string)
  default = []
}

variable "cidr_blocks" {
  description = "Subnet CIDR blocks where the EKS cluster will be deployed"
  type = string
  default = list(string)
}

variable "cluster_cni_subnets" {
  description = "IDs of the subnets where the EKS worker nodes will be deployed"
  type = list(string)
  default = []
}

variable "iam_role_permissions_boundary" {
  description = "The ARN of the permissions boundary for IAM resources"
  type        = string
  default     = null
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type = string
  default = "uds-swf-cluster"
}

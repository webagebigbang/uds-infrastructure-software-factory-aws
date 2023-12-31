variable "region" {
  description = "AWS region"
  type        = string
}

variable "create_testing_resources" {
  description = "Whether to create VPC and subnets for local testing."
  type        = bool
  default     = false
}

# Object Storage Variables (including related IAM and KMS)

variable "bucket_names" {
  description = "List of buckets to create"
  type        = list(string)
  default     = ["gitlab-artifacts", "gitlab-backups", "gitlab-ci-secure-files", "gitlab-dependency-proxy", "git-lfs", "gitlab-mr-diffs", "gitlab-packages", "gitlab-pages", "gitlab-terraform-state", "gitlab-uploads", "registry", "runner-cache", "tmp"]
}

variable "force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = false
}

variable "kubernetes_namespace" {
  description = "Name of the namespace that the service account exists in. Used to generate fully qualified subject for the service account."
  type        = string
}

variable "kubernetes_service_account" {
  description = "Name of the service account to bind to. Used to generate fully qualified subject for service account."
  type        = string
}

variable "bucket_name_prefix" {
  description = "Optional prefix for resource names"
  type        = string
  default     = "uds-"
}

variable "bucket_name_suffix" {
  description = "Optional suffix for resource names"
  type        = string
  default     = ""
}

variable "kms_key_alias" {
  description = "KMS Key Alias name prefix"
  type        = string
  default     = "uds-gitlab"
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  type        = string
}

variable "role_permissions_boundary_arn" {
  description = "Permissions boundary ARN to use for IAM role"
  type        = string
  default     = null
}

# RDS

variable "gitlab_db_subnet_group_name" {
  description = "Name of the DB subnet group"
  type        = string
  default     = null
}

variable "gitlab_db_name" {
  description = "Name of the GitLab database."
  type        = string
  default     = "gitlabdb"
}

variable "gitlab_db_password" {
  description = "Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file. Passing this password will tell AWS we do not want it to manage the password for us.  Leaving this null will tell AWS to manage the password."
  type        = string
  default     = null
}

variable "idam_db_subnet_group_name" {
  description = "Name of the DB subnet group"
  type        = string
  default     = null
}

variable "idam_db_name" {
  description = "Name of the IDAM database."
  type        = string
  default     = "keycloak"
}

variable "idam_db_password" {
  description = "Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file. Passing this password will tell AWS we do not want it to manage the password for us.  Leaving this null will tell AWS to manage the password."
  type        = string
  default     = null
}

variable "sonarqube_db_subnet_group_name" {
  description = "Name of the DB subnet group"
  type        = string
  default     = null
}

variable "sonarqube_db_name" {
  description = "Name of the SonarQube database."
  type        = string
  default     = "sonarqubedb"
}

variable "sonarqube_db_password" {
  description = "Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file. Passing this password will tell AWS we do not want it to manage the password for us.  Leaving this null will tell AWS to manage the password."
  type        = string
  default     = null
}

# Elasticache Variables

variable "elasticache_cluster_name" {
  description = "ElastiCache Cluster Name"
  type        = string
  default     = "uds-gitlab-cluster"
}

variable "elasticache_password" {
  description = "Password for ElastiCache auth."
  type        = string
  sensitive   = true
}

variable "elasticache_subnet_group_name" {
  description = "Subnet group name to use for ElastiCache"
  type        = string
  default     = ""
}

variable "eks_cluster_sg_id" {
  description = "ID of the EKS cluster's security group.  Used to allow access to ElastiCache (Redis)."
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "VPC ID used for ElastiCache Security Group"
  type        = string
  default     = null
}

variable "bucket_names" {
  description = "List of buckets to create"
  type        = list(string)
  default     = ["gitlab-artifacts", "gitlab-backups", "gitlab-ci-secure-files", "gitlab-dependency-proxy", "git-lfs", "gitlab-mr-diffs", "gitlab-packages", "gitlab-pages", "gitlab-terraform-state", "gitlab-uploads", "registry", "runner-cache", "tmp"]
}

variable "bucket_name_prefix" {
  description = "Optional prefix for bucket names"
  type        = string
  default     = "uds-swf-"
}

variable "bucket_name_suffix" {
  description = "Optional suffix for bucket names"
  type        = string
  default     = ""
}

variable "force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = false
}

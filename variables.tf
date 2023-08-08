variable "num_azs" {
  description = "The number of AZs to attempt to use in a region."
  type        = number
  default     = 2
}

variable "region" {
  description = "The AWS region to deploy into"
  type        = string
}

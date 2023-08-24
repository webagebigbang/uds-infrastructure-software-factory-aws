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

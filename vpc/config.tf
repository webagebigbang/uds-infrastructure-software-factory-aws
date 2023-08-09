terraform {
  backend "s3" {
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = "~> 1.5.5"
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      terraform  = true
      repository = "uds-infrastructure-software-factory-aws"
    }
  }
}

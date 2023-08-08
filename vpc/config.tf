terraform {
  backend "s3" {
#    dynamodb_table = var.state_lock_table #"terraform-uds-software-factory-locks"
#    bucket         = var.state_bucket     #"terraform-tfstate-uds-software-factory"
    #encrypt        = true
#    key    = var.state_key #"uds-software-factory/vpc.tfstate"
#    region = var.region
    #role_arn       = "arn:aws:iam::<bastion_account_id>:role/TerraformState"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
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

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.45"
    }
  }
}

provider "aws" {
  region              = var.aws_region
//allowed_account_ids = var.allowed_account_ids
}

terraform {
  backend "s3" {
    region         = "us-east-1"
    bucket         = "boanerges-terraform-state"
    key            = "demo/terraform.tfstate"
    encrypt        = true
    acl            = "private"
  }
}

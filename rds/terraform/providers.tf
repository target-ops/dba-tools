terraform {
  backend "s3" {
    bucket  = "S3_BUCKET_NAME_HERE"
    encrypt = true
    key     = "S3_KEY_HERE"
    region  = "AWS_REGION_HERE"
  }
}


provider "aws" {
  region = var.region

  default_tags {
    tags = {
      environment = var.environment
      automation  = "terraform"
      team        = var.team
    }
  }
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
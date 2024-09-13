terraform {
  backend "s3" {
    encrypt = true
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
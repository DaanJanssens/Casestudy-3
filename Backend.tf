terraform {
  backend "s3" {
    bucket  = "git-case2-terraform-bucket"
    key     = "global/s3/terrafrom.tfstate"
    region  = "eu-central-1"
    encrypt = true

  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.40.0"
    }
  }
}

provider "aws" {
  region = var.region
}
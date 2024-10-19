terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "=5.72.1"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  default_tags {
    tags = {
      stack = "wasmcloud-fargate"
    }
  }
}


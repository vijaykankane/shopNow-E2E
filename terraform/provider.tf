terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "2.70.1"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile


}
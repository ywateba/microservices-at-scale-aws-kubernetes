terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}



provider "aws" {
  region  = var.region


  shared_credentials_file = "~/.aws/credentials"
  profile = "perso"
}

# Backend configuration can also go here, if using remote state
variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

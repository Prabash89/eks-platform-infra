terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }

  # You will configure the S3 backend later in backend.tf
  # backend "s3" {}
}

provider "aws" {
  region = var.aws_region
  # Assume role or use default AWS credentials for initial setup
}
provider "aws" {
  region = var.aws_region
}

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-495294314260-us-east-1"
    key            = "eks-platform-infra/uat/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

module "vpc" {
  source = "../../modules/vpc"

  vpc_name           = "${var.environment}-vpc"
  cidr_block         = var.vpc_cidr
  availability_zones = var.azs
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  cluster_name       = local.cluster_name
}

module "eks" {
  source = "../../modules/eks"

  cluster_name    = local.cluster_name
  cluster_version = var.kubernetes_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  node_groups     = var.node_groups
}

locals {
  cluster_name = "${var.environment}-eks-cluster"
}

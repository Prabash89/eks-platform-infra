# terraform/main.tf
# Provider Configuration
terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # The backend is configured in backend.tf
}

provider "aws" {
  region = var.aws_region
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}

# 1. VPC MODULE: Network Foundation
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = var.tags
}

# 2. EKS MODULE: Kubernetes Cluster
module "eks" {
  source  = "aws-ia/eks/aws"
  version = "~> 1.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.28"

  # Link to the VPC
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Node Group Configuration
  node_groups = {
    managed_ondemand = {
      node_group_name = "managed_ondemand"
      instance_types  = ["t3.medium"]
      min_size        = 2
      max_size        = 5
      desired_size    = 2
      subnet_ids      = module.vpc.private_subnets
    }
  }

  tags = var.tags
}

# 3. OUTPUTS: Information to access your cluster
output "cluster_name" {
  description = "The name of the created EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "The endpoint URL for your EKS cluster API server"
  value       = module.eks.cluster_endpoint
  sensitive   = true
}

output "cluster_certificate_authority_data" {
  description = "The base64-encoded certificate data required to communicate with your cluster"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "vpc_id" {
  description = "The ID of the created VPC"
  value       = module.vpc.vpc_id
}
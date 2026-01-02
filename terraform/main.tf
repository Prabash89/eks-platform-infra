# Create the foundational VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  enable_dns_hostnames   = true

  tags = var.tags
}

# Create the EKS cluster WITH add-ons using EKS Blueprints
module "eks_blueprints" {
  source  = "aws-ia/eks-blueprints/aws"
  version = "~> 4.30" # Use the latest version

  # Cluster details
  cluster_name    = var.cluster_name
  cluster_version = "1.28"

  # Network
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  # Node Groups
  node_groups = {
    managed_node_group = {
      node_group_name = "managed-ondemand"
      instance_types  = ["t3.medium"]
      min_size        = 2
      max_size        = 5
      desired_size    = 2
      subnet_ids      = module.vpc.private_subnets
    }
  }

  # ==================== CORE ADD-ONS ====================
  # This is where we declare what should be installed on the cluster.
  # ArgoCD will be our GitOps operator.
  platform_teams = {
    admin = {
      users = [data.aws_caller_identity.current.arn]
    }
  }

  # Enable ArgoCD as the primary add-on
  enable_argocd = true
  argocd_helm_config = {
    version = "5.46.7"
    values  = [templatefile("${path.module}/argocd-values.yaml", {})]
  }

  # This application set will automatically bootstrap our App Config repo
  argocd_applications = {
    apps = {
      path   = "chart"            # Path within the App Config Repo
      repo_url = "https://github.com/Prabash89/eks-applications.git" # <<< UPDATE in Step 5
    }
  }

  tags = var.tags
}

# Fetch current AWS account ID for platform team mapping
data "aws_caller_identity" "current" {}
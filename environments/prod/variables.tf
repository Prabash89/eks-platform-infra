variable "aws_region" {
  default = "us-east-1"
}

variable "environment" {
  default = "prod"
}

variable "kubernetes_version" {
  default = "1.31"
}

variable "vpc_cidr" {
  default = "10.2.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.2.10.0/24", "10.2.11.0/24", "10.2.12.0/24"]
}

variable "node_groups" {
  default = {
    general = {
      min_size     = 3
      max_size     = 10
      desired_size = 3

      instance_types = ["m5.large"]
      capacity_type  = "ON_DEMAND"
    }
  }
}

variable "aws_region" {
  default = "us-east-1"
}

variable "environment" {
  default = "uat"
}

variable "kubernetes_version" {
  default = "1.31"
}

variable "vpc_cidr" {
  default = "10.1.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.1.10.0/24", "10.1.11.0/24"]
}

variable "node_groups" {
  default = {
    general = {
      min_size     = 2
      max_size     = 5
      desired_size = 2

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"
    }
  }
}

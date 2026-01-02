terraform {
  backend "s3" {
    bucket         = "terraform-state-495294314260-us-east-1"
    key            = "eks-platform-infra/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
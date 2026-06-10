module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.azs
  public_subnets  = var.public_subnets

  enable_nat_gateway = false

  tags = {
    Project     = "eks-vpc"
    Environment = "dev"
  }
}
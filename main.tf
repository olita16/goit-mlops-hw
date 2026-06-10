module "vpc" {
  source = "./vpc"

  vpc_name       = var.vpc_name
  vpc_cidr       = var.vpc_cidr
  azs            = var.azs
  public_subnets = var.public_subnets
}

module "eks" {
  source = "./eks"

  cluster_name = var.cluster_name
}
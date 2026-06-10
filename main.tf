module "vpc" {
  source = "./vpc"
}

module "eks" {
  source = "./eks"

  cluster_name = var.cluster_name
  region       = var.region
  state_bucket = var.state_bucket
}
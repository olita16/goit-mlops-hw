data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "tf-state-olena-eks-2026"
    key    = "vpc/terraform.tfstate"
    region = "eu-central-1"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.vpc.outputs.public_subnets

  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    cpu = {
      desired_size = 1
      min_size     = 1
      max_size     = 1
      instance_types = ["t3.micro"]

      labels = {
        workload = "cpu"
      }
    }

    gpu = {
      desired_size = 1
      min_size     = 1
      max_size     = 1
      instance_types = ["t3.micro"]

      labels = {
        workload = "gpu"
      }
    }
  }
}
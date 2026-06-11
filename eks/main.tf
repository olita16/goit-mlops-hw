data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = "vpc/terraform.tfstate"
    region = var.region
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.30"

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  enable_cluster_creator_admin_permissions = true

  vpc_id    = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets

  eks_managed_node_groups = {
    cpu_group = {
      instance_types = ["t3.micro"]
      ami_type       = "AL2_x86_64"

      desired_size = 1
      min_size     = 1
      max_size     = 2

      labels = {
        workload = "cpu"
      }
    }

    gpu_group = {
      instance_types = ["t3.micro"]
      ami_type       = "AL2_x86_64"

      desired_size = 1
      min_size     = 1
      max_size     = 2

      labels = {
        workload = "gpu"
      }
    }
  }
}
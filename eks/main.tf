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

  # -----------------------------
  # FIX: AWS VPC CNI IP exhaustion
  # -----------------------------
  cluster_addons = {
    vpc-cni = {
      most_recent = true

      configuration_values = jsonencode({
      env = {
        ENABLE_PREFIX_DELEGATION = "true"
        WARM_IP_TARGET           = "2"
        MINIMUM_IP_TARGET        = "2"
      }
    })
  }

    kube-proxy = {
      most_recent = true
    }

    coredns = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    cpu_group = {
      instance_types = ["t3.small"]
      ami_type       = "AL2_x86_64"

      desired_size = 2
      min_size     = 2
      max_size     = 3

      labels = {
        workload = "cpu"
      }

      update_config = {
        max_unavailable = 1
      }
    }

    gpu_group = {
      instance_types = ["t3.small"]
      ami_type       = "AL2_x86_64"

      desired_size = 2
      min_size     = 2
      max_size     = 3

      labels = {
        workload = "gpu"
      }

      update_config = {
        max_unavailable = 1
      }
    }
  }
}
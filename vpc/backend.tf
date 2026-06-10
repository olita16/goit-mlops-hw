terraform {
  backend "s3" {
    bucket = "tf-state-olena-eks-2026"
    key    = "vpc/terraform.tfstate"
    region = "eu-central-1"
  }
}


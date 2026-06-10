terraform {
  backend "s3" {
    bucket = "tf-state-olena-eks-2026"
    key    = "root/terraform.tfstate"
    region = "eu-central-1"
  }
}
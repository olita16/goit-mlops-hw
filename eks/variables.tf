variable "cluster_name" {
  type    = string
  default = "demo-eks-cluster"
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "state_bucket" {
  type    = string
  default = "tf-state-olena-eks-2026"
}
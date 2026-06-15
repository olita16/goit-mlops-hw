variable "aws_region" {
  description = "AWS region where resources will be created."
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Project name prefix for AWS resources."
  type        = string
  default     = "mlops-train-automation"
}

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

locals {
  common_tags = {
    Project = var.project_name
    Managed = "terraform"
  }
}

# IAM role for Lambda functions

resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda functions

resource "aws_lambda_function" "validate" {
  function_name    = "${var.project_name}-validate"
  role             = aws_iam_role.lambda_role.arn
  handler          = "validate.lambda_handler"
  runtime          = "python3.12"
  filename         = "${path.module}/lambda/validate.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/validate.zip")
  timeout          = 30

  tags = local.common_tags
}

resource "aws_lambda_function" "log_metrics" {
  function_name    = "${var.project_name}-log-metrics"
  role             = aws_iam_role.lambda_role.arn
  handler          = "log_metrics.lambda_handler"
  runtime          = "python3.12"
  filename         = "${path.module}/lambda/log_metrics.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/log_metrics.zip")
  timeout          = 30

  tags = local.common_tags
}

# IAM role for AWS Step Functions

resource "aws_iam_role" "step_functions_role" {
  name = "${var.project_name}-step-functions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "step_functions_lambda_invoke" {
  name = "${var.project_name}-invoke-lambda"
  role = aws_iam_role.step_functions_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = [
          aws_lambda_function.validate.arn,
          aws_lambda_function.log_metrics.arn
        ]
      }
    ]
  })
}


# AWS Step Functions state machine

resource "aws_sfn_state_machine" "train_pipeline" {
  name     = "${var.project_name}-state-machine"
  role_arn = aws_iam_role.step_functions_role.arn
  type     = "STANDARD"

  definition = jsonencode({
    Comment = "Automated ML model training pipeline"
    StartAt = "ValidateData"
    States = {
      ValidateData = {
        Type       = "Task"
        Resource   = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = aws_lambda_function.validate.arn
          "Payload.$"  = "$"
        }
        OutputPath = "$.Payload"
        Next       = "LogMetrics"
      }
      LogMetrics = {
        Type       = "Task"
        Resource   = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = aws_lambda_function.log_metrics.arn
          "Payload.$"  = "$"
        }
        OutputPath = "$.Payload"
        End        = true
      }
    }
  })

  tags = local.common_tags
}

output "state_machine_arn" {
  description = "ARN of the training Step Function. Use this value in GitLab CI variable STEP_FUNCTION_ARN."
  value       = aws_sfn_state_machine.train_pipeline.arn
}

output "validate_lambda_name" {
  description = "Validate Lambda function name."
  value       = aws_lambda_function.validate.function_name
}

output "log_metrics_lambda_name" {
  description = "Log metrics Lambda function name."
  value       = aws_lambda_function.log_metrics.function_name
}

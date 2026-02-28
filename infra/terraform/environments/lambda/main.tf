terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    # Backend configuration is provided via -backend-config flags during init
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Data source to get VPC info
data "aws_vpc" "main" {
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Data source to get Lambda subnets (Multi-AZ)
data "aws_subnets" "lambda" {
  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-private-lambda-*"]
  }
}

# Lambda Web Module
module "lambda_web" {
  source = "../../modules/lambda_web"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = data.aws_vpc.main.id
  subnet_ids         = data.aws_subnets.lambda.ids
  log_retention_days = 14

  tags = local.common_tags
}

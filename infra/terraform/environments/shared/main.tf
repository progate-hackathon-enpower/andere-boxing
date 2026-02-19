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

# IAM Module for GitHub Actions
module "iam" {
  source = "../../modules/iam"

  github_repository = var.github_repository
  github_role_name  = var.github_actions_role_name
  environment       = var.environment
  project_name      = var.project_name

  tags = local.common_tags
}

terraform {
  required_version = ">= 1.0"
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
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }

  account_id                  = data.aws_caller_identity.current.account_id
  deterministic_bucket_name   = "${var.project_name}-terraform-state-${local.account_id}"
  deterministic_table_name    = "${var.project_name}-terraform-locks"
  
  final_bucket_name           = var.enable_deterministic_naming ? local.deterministic_bucket_name : var.terraform_state_bucket_name
  final_table_name            = var.enable_deterministic_naming ? local.deterministic_table_name : var.terraform_state_lock_table_name
}

# S3 backend initialization
module "terraform_backend" {
  source = "../modules/s3"

  bucket_name          = local.final_bucket_name
  dynamodb_table_name  = local.final_table_name
  environment          = var.environment
  project_name         = var.project_name
  versioning_enabled   = true
  sse_algorithm        = "AES256"

  tags = local.common_tags
}

output "bucket_name" {
  value       = local.final_bucket_name
  description = "Terraform state S3 bucket name"
}

output "dynamodb_table_name" {
  value       = local.final_table_name
  description = "Terraform state lock DynamoDB table name"
}

output "backend_config" {
  value       = module.terraform_backend.backend_config
  description = "Backend configuration to be used in terraform init"
}

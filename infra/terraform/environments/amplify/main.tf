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

# Fetch secrets from Secrets Manager
data "aws_secretsmanager_secret" "github_token" {
  name = var.github_token_secret_name
}

data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = data.aws_secretsmanager_secret.github_token.id
}

data "aws_secretsmanager_secret" "dotenv_private_key" {
  name = var.dotenv_private_key_secret_name
}

data "aws_secretsmanager_secret_version" "dotenv_private_key" {
  secret_id = data.aws_secretsmanager_secret.dotenv_private_key.id
}

# Amplify Module
module "amplify" {
  source = "../../modules/amplify"

  app_name            = var.amplify_app_name
  github_repository   = var.github_repository
  github_access_token = data.aws_secretsmanager_secret_version.github_token.secret_string
  branch_name         = var.amplify_branch_name
  framework           = var.amplify_framework
  stage               = var.amplify_stage
  enable_auto_build   = var.amplify_enable_auto_build
  environment         = var.environment
  project_name        = var.project_name

  build_spec = <<-YAML
    version: 1
    applications:
      - appRoot: apps/web
        frontend:
          phases:
            preBuild:
              commands:
                - npm install -g pnpm @dotenvx/dotenvx
                - pnpm install
            build:
              commands:
                - dotenvx run -- env | grep -v "^DOTENV_PRIVATE_KEY=" >> .env.production
                - dotenvx run -- pnpm run build
          artifacts:
            baseDirectory: .amplify-hosting
            files:
              - '**/*'
          cache:
            paths:
              - node_modules/**/*
  YAML

  environment_variables = merge(
    var.amplify_environment_variables,
    {
      DOTENV_PRIVATE_KEY = data.aws_secretsmanager_secret_version.dotenv_private_key.secret_string
    }
  )
  branch_environment_variables = var.amplify_branch_environment_variables

  tags = local.common_tags
}

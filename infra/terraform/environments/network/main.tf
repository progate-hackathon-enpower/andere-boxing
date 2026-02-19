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

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr                            = var.vpc_cidr
  availability_zones                  = var.availability_zones
  public_subnet_cidrs                 = var.public_subnet_cidrs
  private_subnet_eks_cidrs            = var.private_subnet_eks_cidrs
  private_subnet_observability_cidrs  = var.private_subnet_observability_cidrs
  private_subnet_lambda_cidrs         = var.private_subnet_lambda_cidrs
  environment                         = var.environment
  project_name                        = var.project_name

  tags = local.common_tags
}

# NAT Gateway Module
module "nat_gateway" {
  source = "../../modules/nat_gateway"

  public_subnet_ids      = module.vpc.public_subnet_ids
  availability_zones     = var.availability_zones
  private_subnet_ids     = module.vpc.private_subnet_ids
  internet_gateway_id    = module.vpc.internet_gateway_id
  environment            = var.environment
  project_name           = var.project_name

  tags = local.common_tags

  depends_on = [module.vpc]
}

# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/flowlogs/${var.project_name}"
  retention_in_days = var.vpc_flow_logs_retention_days

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-vpc-flow-logs"
    }
  )
}

# IAM role for VPC Flow Logs
resource "aws_iam_role" "vpc_flow_logs" {
  name = "${var.project_name}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

# IAM policy for VPC Flow Logs
resource "aws_iam_role_policy" "vpc_flow_logs" {
  name = "${var.project_name}-vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

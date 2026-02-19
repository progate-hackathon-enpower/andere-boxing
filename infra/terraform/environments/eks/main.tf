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

# Data source to get public subnet
data "aws_subnet" "public" {
  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

# Data source to get private EKS subnet
data "aws_subnet" "eks" {
  tags = {
    Name = "${var.project_name}-private-eks"
  }
}

# Security Group Module
module "security_group" {
  source = "../../modules/security_group"

  project_name          = var.project_name
  vpc_id                = data.aws_vpc.main.id
  public_node_port_from = var.public_node_port_from
  public_node_port_to   = var.public_node_port_to

  tags = local.common_tags
}

# EKS Module
module "eks" {
  source = "../../modules/eks"

  project_name                   = var.project_name
  environment                    = var.environment
  subnet_ids                     = [data.aws_subnet.public.id, data.aws_subnet.eks.id]
  private_subnet_ids             = [data.aws_subnet.eks.id]
  public_subnet_ids              = [data.aws_subnet.public.id]
  cluster_security_group_id      = module.security_group.eks_cluster_security_group_id
  private_node_security_group_id = module.security_group.eks_private_node_security_group_id
  public_node_security_group_id  = module.security_group.eks_public_node_security_group_id
  kubernetes_version             = var.kubernetes_version
  node_instance_types            = var.node_instance_types
  capacity_type                  = var.capacity_type

  # Private node group scaling
  private_node_desired_size = var.private_node_desired_size
  private_node_min_size     = var.private_node_min_size
  private_node_max_size     = var.private_node_max_size

  # Public node group scaling
  public_node_desired_size = var.public_node_desired_size
  public_node_min_size     = var.public_node_min_size
  public_node_max_size     = var.public_node_max_size

  tags = local.common_tags

  depends_on = [module.security_group]
}

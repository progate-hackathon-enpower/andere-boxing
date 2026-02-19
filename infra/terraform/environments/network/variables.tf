variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "ap-northeast-1"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

# VPC Configuration
variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones for multi-AZ setup"
  default     = ["ap-northeast-1a", "ap-northeast-1c"]
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_eks_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private EKS subnets"
  default     = ["10.0.10.0/23", "10.0.12.0/23"]
}

variable "private_subnet_observability_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private observability subnets"
  default     = ["10.0.20.0/23", "10.0.22.0/23"]
}

variable "private_subnet_lambda_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private Lambda subnets"
  default     = ["10.0.28.0/23", "10.0.30.0/23"]
}

variable "vpc_flow_logs_retention_days" {
  type        = number
  description = "CloudWatch Logs retention for VPC Flow Logs"
  default     = 7
}

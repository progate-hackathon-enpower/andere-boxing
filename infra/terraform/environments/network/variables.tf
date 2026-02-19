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

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR block for public subnet"
  default     = "10.0.0.0/24"
}

variable "private_subnet_eks_cidr" {
  type        = string
  description = "CIDR block for private EKS subnet"
  default     = "10.0.10.0/23"
}

variable "private_subnet_observability_cidr" {
  type        = string
  description = "CIDR block for private observability subnet"
  default     = "10.0.20.0/23"
}

variable "private_subnet_lambda_cidr" {
  type        = string
  description = "CIDR block for private Lambda subnet"
  default     = "10.0.28.0/22"
}

variable "availability_zone" {
  type        = string
  description = "Availability zone"
  default     = "ap-northeast-1a"
}

variable "vpc_flow_logs_retention_days" {
  type        = number
  description = "CloudWatch Logs retention for VPC Flow Logs"
  default     = 7
}

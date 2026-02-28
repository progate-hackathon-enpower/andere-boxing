variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
}

variable "private_subnet_eks_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private EKS subnets"
}

variable "private_subnet_observability_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private observability subnets"
}

variable "private_subnet_lambda_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private Lambda subnets"
}

variable "tags" {
  type        = map(string)
  description = "Common tags to apply to resources"
  default     = {}
}

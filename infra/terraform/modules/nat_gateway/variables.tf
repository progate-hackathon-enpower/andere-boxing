variable "public_subnet_id" {
  type        = string
  description = "Public subnet ID where NAT Gateway will be placed"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs that route through NAT Gateway"
}

variable "internet_gateway_id" {
  type        = string
  description = "Internet Gateway ID"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "tags" {
  type        = map(string)
  description = "Common tags to apply to resources"
  default     = {}
}

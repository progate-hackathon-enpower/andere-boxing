variable "project_name" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "log_retention_days" {
  type        = number
  description = "CloudWatch Logs retention days"
  default     = 14
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for Lambda VPC configuration"
}

variable "tags" {
  type        = map(string)
  description = "Common tags"
  default     = {}
}

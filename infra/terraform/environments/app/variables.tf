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

# ECR Configuration
variable "ecr_repository_names" {
  type        = list(string)
  description = "List of ECR repository names"
  default     = ["api", "worker"]
}

variable "ecr_image_tag_mutability" {
  type        = string
  description = "ECR image tag mutability"
  default     = "IMMUTABLE"
}

variable "ecr_scan_on_push" {
  type        = bool
  description = "Enable ECR image scanning on push"
  default     = true
}

variable "ecr_retention_days" {
  type        = number
  description = "Days to retain untagged ECR images"
  default     = 30
}

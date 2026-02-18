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

variable "github_repository" {
  type        = string
  description = "GitHub repository in format: owner/repo"
}

# IAM Configuration
variable "github_actions_role_name" {
  type        = string
  description = "IAM role name for GitHub Actions"
  default     = "github-actions-role"
}

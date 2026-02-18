variable "environment" {
  type        = string
  description = "Environment name"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "github_role_name" {
  type        = string
  description = "IAM role name for GitHub Actions"
  default     = "github-actions-role"
}

variable "github_repository" {
  type        = string
  description = "GitHub repository in format: owner/repo"
}

variable "tags" {
  type        = map(string)
  description = "Common tags to apply to resources"
  default     = {}
}

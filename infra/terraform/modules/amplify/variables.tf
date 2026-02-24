variable "environment" {
  type        = string
  description = "Environment name"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "app_name" {
  type        = string
  description = "Amplify app name"
}

variable "github_repository" {
  type        = string
  description = "GitHub repository in format: owner/repo"
}

variable "github_access_token" {
  type        = string
  description = "GitHub classic personal access token for Amplify"
  sensitive   = true
}

variable "branch_name" {
  type        = string
  description = "Git branch name to deploy"
  default     = "main"
}

variable "framework" {
  type        = string
  description = "Framework for the branch (e.g., React)"
  default     = "React"
}

variable "stage" {
  type        = string
  description = "Amplify branch stage (PRODUCTION, BETA, DEVELOPMENT, etc.)"
  default     = "PRODUCTION"
}

variable "build_spec" {
  type        = string
  description = "Amplify build specification YAML"
}

variable "environment_variables" {
  type        = map(string)
  description = "Environment variables for the Amplify app"
  default     = {}
}

variable "branch_environment_variables" {
  type        = map(string)
  description = "Environment variables for the branch"
  default     = {}
}

variable "enable_auto_build" {
  type        = bool
  description = "Enable auto build on push"
  default     = true
}

variable "enable_preview" {
  type        = bool
  description = "Enable preview builds for pull request branches"
  default     = true
}

variable "preview_branch_patterns" {
  type        = list(string)
  description = "Branch patterns for auto branch creation (preview)"
  default     = ["*"]
}

variable "tags" {
  type        = map(string)
  description = "Common tags to apply to resources"
  default     = {}
}

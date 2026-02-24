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

variable "github_token_secret_name" {
  type        = string
  description = "Secrets Manager secret name for GitHub classic token"
  default     = "andere-boxing/github-access-token"
}

variable "dotenv_private_key_secret_name" {
  type        = string
  description = "Secrets Manager secret name for dotenvx DOTENV_PRIVATE_KEY"
  default     = "andere-boxing/dotenv-private-key"
}

# Amplify Configuration
variable "amplify_app_name" {
  type        = string
  description = "Amplify app name"
  default     = "web"
}

variable "amplify_branch_name" {
  type        = string
  description = "Git branch to deploy"
  default     = "main"
}

variable "amplify_framework" {
  type        = string
  description = "Framework for the Amplify app"
  default     = "React"
}

variable "amplify_stage" {
  type        = string
  description = "Amplify branch stage"
  default     = "PRODUCTION"
}

variable "amplify_enable_auto_build" {
  type        = bool
  description = "Enable auto build on push"
  default     = true
}

variable "amplify_environment_variables" {
  type        = map(string)
  description = "Environment variables for the Amplify app"
  default     = {}
}

variable "amplify_branch_environment_variables" {
  type        = map(string)
  description = "Environment variables for the branch"
  default     = {}
}

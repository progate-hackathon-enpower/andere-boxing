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

variable "enable_deterministic_naming" {
  type        = bool
  description = "Enable deterministic bucket naming (project-terraform-state-accountid)"
  default     = true
}

variable "terraform_state_bucket_name" {
  type        = string
  description = "S3 bucket name for Terraform state (optional if deterministic naming enabled)"
  default     = ""
}

variable "terraform_state_lock_table_name" {
  type        = string
  description = "DynamoDB table name for Terraform state locking (optional if deterministic naming enabled)"
  default     = ""
}

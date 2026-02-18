variable "bucket_name" {
  type        = string
  description = "S3 bucket name for Terraform state"
}

variable "dynamodb_table_name" {
  type        = string
  description = "DynamoDB table name for Terraform state locking"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "versioning_enabled" {
  type        = bool
  description = "Enable versioning for state bucket"
  default     = true
}

variable "sse_algorithm" {
  type        = string
  description = "Server-side encryption algorithm"
  default     = "AES256"
}

variable "tags" {
  type        = map(string)
  description = "Common tags to apply to resources"
  default     = {}
}

output "state_bucket_id" {
  value       = aws_s3_bucket.terraform_state.id
  description = "Terraform state S3 bucket ID"
}

output "state_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "Terraform state S3 bucket ARN"
}

output "logs_bucket_id" {
  value       = aws_s3_bucket.terraform_logs.id
  description = "Terraform logs S3 bucket ID"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "DynamoDB table name for state locking"
}

output "backend_config" {
  value = {
    bucket         = aws_s3_bucket.terraform_state.id
    key            = "terraform.tfstate"
    region         = data.aws_region.current.name
    dynamodb_table = aws_dynamodb_table.terraform_locks.name
    encrypt        = true
  }
  description = "Backend configuration for terraform init"
  sensitive   = false
}

data "aws_region" "current" {}

output "repository_urls" {
  value = {
    for name, repo in aws_ecr_repository.main : name => repo.repository_url
  }
  description = "ECR repository URLs"
}

output "repository_arns" {
  value = {
    for name, repo in aws_ecr_repository.main : name => repo.arn
  }
  description = "ECR repository ARNs"
}

output "registry_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "AWS Account ID (ECR Registry ID)"
}

data "aws_caller_identity" "current" {}

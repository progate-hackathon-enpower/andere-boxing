output "ecr_repository_urls" {
  value       = module.ecr.repository_urls
  description = "ECR repository URLs"
}

output "ecr_repository_arns" {
  value       = module.ecr.repository_arns
  description = "ECR repository ARNs"
}

output "registry_id" {
  value       = module.ecr.registry_id
  description = "AWS Account ID (ECR Registry ID)"
}

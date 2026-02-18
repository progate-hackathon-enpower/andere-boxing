output "github_actions_role_arn" {
  value       = module.iam.github_actions_role_arn
  description = "GitHub Actions IAM role ARN"
}

output "github_actions_role_name" {
  value       = module.iam.github_actions_role_name
  description = "GitHub Actions IAM role name"
}

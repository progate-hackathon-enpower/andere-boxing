output "github_actions_role_arn" {
  value       = aws_iam_role.github_actions.arn
  description = "GitHub Actions IAM role ARN"
}

output "github_actions_role_name" {
  value       = aws_iam_role.github_actions.name
  description = "GitHub Actions IAM role name"
}

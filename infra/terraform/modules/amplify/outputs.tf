output "app_id" {
  value       = aws_amplify_app.main.id
  description = "Amplify app ID"
}

output "app_arn" {
  value       = aws_amplify_app.main.arn
  description = "Amplify app ARN"
}

output "default_domain" {
  value       = aws_amplify_app.main.default_domain
  description = "Amplify default domain"
}

output "branch_name" {
  value       = aws_amplify_branch.main.branch_name
  description = "Deployed branch name"
}

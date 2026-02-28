output "function_name" {
  value       = aws_lambda_function.web.function_name
  description = "Lambda function name"
}

output "function_arn" {
  value       = aws_lambda_function.web.arn
  description = "Lambda function ARN"
}

output "role_arn" {
  value       = aws_iam_role.lambda_exec.arn
  description = "Lambda execution role ARN"
}

output "function_url" {
  value       = aws_lambda_function_url.web.function_url
  description = "Lambda Function URL"
}

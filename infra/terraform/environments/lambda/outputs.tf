output "lambda_web_function_name" {
  value       = module.lambda_web.function_name
  description = "Lambda Web function name"
}

output "lambda_web_role_arn" {
  value       = module.lambda_web.role_arn
  description = "Lambda Web execution role ARN"
}

output "lambda_web_function_url" {
  value       = module.lambda_web.function_url
  description = "Lambda Web Function URL"
}

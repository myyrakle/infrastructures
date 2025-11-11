output "function_url" {
  value       = aws_lambda_function_url.release_url.function_url
  description = "Function Url"
}

output "function_name" {
  value       = aws_lambda_function_url.release_url.function_name
  description = "Function Name"
}

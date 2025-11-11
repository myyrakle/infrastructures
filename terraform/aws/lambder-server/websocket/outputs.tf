output "endpoint" {
  value       = aws_apigatewayv2_api.gateway.api_endpoint
  description = "WebSocket endpoint"
}

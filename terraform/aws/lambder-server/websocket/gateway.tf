resource "aws_apigatewayv2_api" "gateway" {
  name                       = "${local.resource_id}-gateway"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"

  tags = local.tags
}

resource "aws_apigatewayv2_stage" "release_stage" {
  api_id = aws_apigatewayv2_api.gateway.id
  name   = "release"
}


// Connect Setting

resource "aws_apigatewayv2_integration" "connect_integration" {
  api_id           = aws_apigatewayv2_api.gateway.id
  integration_type = "AWS_PROXY"

  credentials_arn      = aws_iam_role.api_gateway_role.arn
  connection_type      = "INTERNET"
  description          = "Connect Lambda"
  integration_method   = "POST"
  integration_uri      = aws_lambda_function.connect_lambda.invoke_arn
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_integration_response" "connect_integration_response" {
  api_id                   = aws_apigatewayv2_api.gateway.id
  integration_id           = aws_apigatewayv2_integration.connect_integration.id
  integration_response_key = "/200/"
}

resource "aws_apigatewayv2_route" "connect_route" {
  api_id    = aws_apigatewayv2_api.gateway.id
  route_key = "$connect"
  target    = "integrations/${aws_apigatewayv2_integration.connect_integration.id}"
}

resource "aws_lambda_permission" "connect" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.connect_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.gateway.execution_arn}/*/*"
}

// Disconnect Setting

resource "aws_apigatewayv2_integration" "disconnect_integration" {
  api_id           = aws_apigatewayv2_api.gateway.id
  integration_type = "AWS_PROXY"

  credentials_arn      = aws_iam_role.api_gateway_role.arn
  connection_type      = "INTERNET"
  description          = "Connect Lambda"
  integration_method   = "POST"
  integration_uri      = aws_lambda_function.disconnect_lambda.invoke_arn
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_integration_response" "disconnect_integration_response" {
  api_id                   = aws_apigatewayv2_api.gateway.id
  integration_id           = aws_apigatewayv2_integration.disconnect_integration.id
  integration_response_key = "/200/"
}

resource "aws_apigatewayv2_route" "disconnect_route" {
  api_id    = aws_apigatewayv2_api.gateway.id
  route_key = "$disconnect"
  target    = "integrations/${aws_apigatewayv2_integration.disconnect_integration.id}"
}

resource "aws_lambda_permission" "disconnect" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.disconnect_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.gateway.execution_arn}/*/*"
}

// Default setting

resource "aws_apigatewayv2_integration" "default_integration" {
  api_id           = aws_apigatewayv2_api.gateway.id
  integration_type = "AWS_PROXY"

  credentials_arn      = aws_iam_role.api_gateway_role.arn
  connection_type      = "INTERNET"
  description          = "Connect Lambda"
  integration_method   = "POST"
  integration_uri      = aws_lambda_function.default_lambda.invoke_arn
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.gateway.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.default_integration.id}"
}

resource "aws_lambda_permission" "default" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.default_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.gateway.execution_arn}/*/*"
}

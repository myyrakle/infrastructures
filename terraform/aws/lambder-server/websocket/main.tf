terraform {
  required_providers {
    # 일종의 라이브러리 로드
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region
}

resource "aws_lambda_function" "connect_lambda" {
  description   = "A lambda connect function for ${local.resource_id}"
  function_name = "${local.resource_id}-connect"
  role          = aws_iam_role.lambda_role.arn
  layers        = var.lambda_layers
  runtime       = var.lambda_runtime
  handler       = "index.handler"
  filename      = "codes/zip/connect.zip"

  environment {
    variables = {
      ServerName          = var.server_name
      ENVIRONMENT         = var.environment
      ConnectionTableName = "${local.resource_id}_connection"
    }
  }

  tags = local.tags
}

resource "aws_lambda_function" "disconnect_lambda" {
  description   = "A lambda disconnect function for ${local.resource_id}"
  function_name = "${local.resource_id}-disconnect"
  role          = aws_iam_role.lambda_role.arn
  layers        = var.lambda_layers
  runtime       = var.lambda_runtime
  handler       = "index.handler"
  filename      = "codes/zip/disconnect.zip"

  environment {
    variables = {
      ServerName          = var.server_name
      ENVIRONMENT         = var.environment
      ConnectionTableName = "${local.resource_id}_connection"
    }
  }

  tags = local.tags
}

resource "aws_lambda_function" "default_lambda" {
  description   = "A lambda default function for ${local.resource_id}"
  function_name = "${local.resource_id}-default"
  role          = aws_iam_role.lambda_role.arn
  layers        = var.lambda_layers
  runtime       = var.lambda_runtime
  handler       = "index.handler"
  filename      = "codes/zip/default.zip"

  environment {
    variables = {
      ServerName          = var.server_name
      ENVIRONMENT         = var.environment
      ConnectionTableName = "${local.resource_id}_connection"
      GatewayEndpoint     = "${replace(aws_apigatewayv2_api.gateway.api_endpoint, "wss://", "")}/release"
    }
  }

  tags = local.tags
}


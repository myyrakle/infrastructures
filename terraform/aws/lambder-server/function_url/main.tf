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

resource "aws_lambda_function" "lambda" {
  description   = "A lambda function for ${local.resource_id}}"
  function_name = local.resource_id
  role          = aws_iam_role.lambda_role.arn
  layers        = var.lambda_layers
  runtime       = var.lambda_runtime
  handler       = "hello.handler"
  filename      = "codes/axum.zip"

  environment {
    variables = {
      ServerName  = var.server_name
      ENVIRONMENT = var.environment
    }
  }
}

// Function Url
resource "aws_lambda_function_url" "release_url" {
  function_name      = aws_lambda_function.lambda.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = var.cors_allow_origins
    allow_methods     = ["*"]
    allow_headers     = var.cors_allow_headers
    expose_headers    = var.cors_expose_headers
    max_age           = 86400
  }
}

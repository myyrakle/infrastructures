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
  region = local.region
}

resource "aws_lambda_function" "lambda" {
  description   = "A lambda connect function for ${local.resource_id}"
  function_name = local.resource_id
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

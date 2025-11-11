# Dynamo 테이블 - sync_library_clothes
resource "aws_dynamodb_table" "queue" {
  name           = local.queue_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  stream_enabled = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Environment = var.environment
    Application = var.service_name
  }
}

// ECR for Lambda
resource "aws_ecr_repository" "lambda_repo" {
  name = "${local.lambda_name}"

  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }

  tags = {
    Environment = var.environment
    Application = var.service_name
  }
}
  

# Lambda Function (Docker version)
resource "aws_lambda_function" "lambda_function" {
  function_name = local.lambda_name
  role          = aws_iam_role.lambda_role.arn
  memory_size   = 512
  timeout       = 60 * 15
  package_type  = "Image"

  image_uri = "start image here"
  // image_uri = "${aws_ecr_repository.lambda_repo.repository_url}:latest"

  vpc_config {
    subnet_ids         = [var.subnet_id]
    security_group_ids = [var.security_group_id]
  }

  lifecycle {
    ignore_changes = [image_uri, memory_size, timeout]
  }

  tags = {
    Environment = var.environment
    Application = var.service_name
  }
}

// Lambda <> DynamoDB 매핑입니다.
// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping
resource "aws_lambda_event_source_mapping" "stream" {
  event_source_arn  = aws_dynamodb_table.queue.stream_arn
  function_name     = aws_lambda_function.lambda_function.arn
  starting_position = "LATEST"
  batch_size = var.batch_size
  bisect_batch_on_function_error = var.bisect_batch_on_function_error
  maximum_retry_attempts = var.maximum_retry_attempts
  maximum_record_age_in_seconds = -1 # -1이면 수명이 무한대
  maximum_batching_window_in_seconds = var.batch_window_seconds
  parallelization_factor = var.parallelization_factor

  filter_criteria {
   filter {
      pattern = "{\"eventName\": [\"INSERT\"]}"
    }
  }

  lifecycle {
    ignore_changes = [ function_name ]
  }
}

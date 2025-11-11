# Lambda 역할을 위한 Assume Role 정책
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# DynamoDB 권한을 위한 정책
data "aws_iam_policy_document" "lambda_permissions" {
  // DynamoDB와 DynamoDB Streams에 대한 권한을 부여합니다.
  statement {
    actions = [
      "dynamodb:*"
    ]

    resources = [
      aws_dynamodb_table.queue.arn,
      "${aws_dynamodb_table.queue.arn}/stream/*"
    ]
  }

   # CloudWatch Logs 관련 권한 추가
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    
    resources = ["arn:aws:logs:*:*:*"]
  }
}

# Lambda IAM Role
resource "aws_iam_role" "lambda_role" {
  name               = "${local.queue_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = {
    Environment = var.environment
    Application = local.queue_name
  }
}

# Lambda IAM Role Policy
resource "aws_iam_role_policy" "lambda_policy" {
  name   = "${local.lambda_name}-policy"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_permissions.json
}

# Attach AWSLambdaVPCAccessExecutionRole policy
resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

// Lambda Role
resource "aws_iam_role" "lambda_role" {
  name = "${local.resource_id}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : ["lambda.amazonaws.com"]
        },
        "Action" : [
          "sts:AssumeRole"
        ]
      }
    ]
  })

  inline_policy {
    name = "root"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          "Sid" : "SpecificTable",
          "Effect" : "Allow",
          "Action" : [
            "dynamodb:BatchGet*",
            "dynamodb:DescribeStream",
            "dynamodb:DescribeTable",
            "dynamodb:Get*",
            "dynamodb:Query",
            "dynamodb:Scan",
            "dynamodb:BatchWrite*",
            "dynamodb:CreateTable",
            "dynamodb:Delete*",
            "dynamodb:Update*",
            "dynamodb:PutItem"
          ],
          "Resource" : [
            // 테이블을 추가할 때마다 여기에도 리소스를 추가해줍니다.
            "arn:aws:dynamodb:*:*:table/${local.resource_id}_connection"
          ]
        }
      ]
    })
  }
}

resource "aws_iam_role_policy_attachment" "lambda-basic-attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "update_code_policy_data" {
  statement {
    actions = [
      "lambda:UpdateFunctionCode",
    ]
    effect = "Allow"
    resources = [
      aws_lambda_function.connect_lambda.arn,
      aws_lambda_function.disconnect_lambda.arn,
      aws_lambda_function.default_lambda.arn
    ]
  }
}

resource "aws_iam_policy" "update_code_policy" {
  name   = "${local.resource_id}-update-code-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.update_code_policy_data.json
}

// Code Build에 사용할 role
resource "aws_iam_role" "codebuild_role" {
  name = join("-", [local.resource_id, "codebuild-role"])

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codebuild.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  path = "/"

  inline_policy {
    name = "codebuild"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          "Effect" : "Allow",
          "Action" : "*",
          "Resource" : "*"
        }
      ]
    })
  }

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "update-code-attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.update_code_policy.arn
}

// Code Pipeline에 사용할 role
resource "aws_iam_role" "codepipeline_role" {
  name = join("-", [local.resource_id, "codepipeline-role"])

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codepipeline.amazonaws.com"
        },
        "Action" : ["sts:AssumeRole"]
      }
    ]
  })

  path = "/"

  inline_policy {
    name = "root"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          "Resource" : "${aws_s3_bucket.artifact_bucket.arn}/*",
          "Effect" : "Allow",
          "Action" : [
            "s3:PutObject",
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:GetBucketVersioning"
          ]
        },
        {
          "Resource" : "*",
          "Effect" : "Allow",
          "Action" : [
            "ecs:DescribeServices",
            "ecs:DescribeTaskDefinition",
            "ecs:DescribeTasks",
            "ecs:ListTasks",
            "ecs:RegisterTaskDefinition",
            "ecs:UpdateService",
            "codebuild:StartBuild",
            "codebuild:BatchGetBuilds",
            "iam:PassRole",
            "codestar-connections:*"
          ]
        }
      ]
    })
  }

  tags = local.tags
}

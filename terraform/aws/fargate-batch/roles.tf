resource "aws_iam_role" "task_execution_role" {
  name = join("-", [var.system_name, var.environment, "task-execution-role"])

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : ["ecs-tasks.amazonaws.com"]
        },
        "Action" : [
          "sts:AssumeRole"
        ]
      }
    ]
  })

  path = "/"

  inline_policy {
    name = "root"
    policy = jsonencode({
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

// Code Build에 사용할 role
resource "aws_iam_role" "codebuild_role" {
  name = join("-", [var.system_name, var.environment, "codebuild-role"])

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

// Code Pipeline에 사용할 role
resource "aws_iam_role" "codepipeline_role" {
  name = join("-", [var.system_name, var.environment, "codepipeline-role"])

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

resource "aws_iam_role" "aws_batch_service_role" {
  name = join("-", [var.system_name, var.environment, "batch-role"])

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "batch.amazonaws.com"
        },
        "Action" : ["sts:AssumeRole"]
      }
    ]
  })

  inline_policy {
    name = "root"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          "Resource" : "*",
          "Effect" : "Allow",
          "Action" : [
            "logs:*",
            "ecs:*"
          ]
        }
      ]
    })
  }
}

resource "aws_iam_role_policy_attachment" "batch_attach" {
  role       = aws_iam_role.aws_batch_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}


// event에 사용할 role
resource "aws_iam_role" "event_role" {
  name = join("-", [var.system_name, var.environment, "event-role"])

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "events.amazonaws.com"
        },
        "Action" : ["sts:AssumeRole"]
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "scheduler.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
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
          "Resource" : "*",
          "Effect" : "Allow",
          "Action" : [
            "batch:SubmitJob"
          ]
        }
      ]
    })
  }

  tags = local.tags
}

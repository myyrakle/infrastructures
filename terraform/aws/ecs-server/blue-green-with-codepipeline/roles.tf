resource "aws_iam_role" "task_execution_role" {
  name = join("-", [var.server_name, var.environment, "task-execution-role"])

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

// 오토스케일링에 사용할 role
resource "aws_iam_role" "scalable_target_role" {
  name = join("-", [var.server_name, var.environment, "scalable-target-role"])

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : ["application-autoscaling.amazonaws.com"]
        },
        "Action" : ["sts:AssumeRole"]
      }
    ]
  })

  path = "/"

  inline_policy {
    name = "root"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          "Effect" : "Allow",
          "Action" : [
            "application-autoscaling:*",
            "cloudwatch:DescribeAlarms",
            "cloudwatch:PutMetricAlarm",
            "ecs:DescribeServices",
            "ecs:UpdateService"
          ],
          "Resource" : "*"
        }
      ]
    })


  }

  tags = local.tags
}

// ECS Service에 사용할 role
resource "aws_iam_role" "ecs_service_role" {
  name = join("-", [var.server_name, var.environment, "ecs-service-role"])

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : ["ecs.amazonaws.com"]
        },
        "Action" : ["sts:AssumeRole"]
      }
    ]
  })

  path = "/"

  inline_policy {
    name = "ecs-service"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          "Effect" : "Allow",
          "Action" : [
            "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
            "elasticloadbalancing:DeregisterTargets",
            "elasticloadbalancing:Describe*",
            "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
            "elasticloadbalancing:RegisterTargets",
            "ec2:Describe*",
            "ec2:AuthorizeSecurityGroupIngress"
          ],
          "Resource" : "*"
        }
      ]
    })
  }

  tags = local.tags
}

// Code Build에 사용할 role
resource "aws_iam_role" "codebuild_role" {
  name = join("-", [var.server_name, var.environment, "codebuild-role"])

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

// Code Deploy에 사용할 role
resource "aws_iam_role" "codedeploy_role" {
  name = join("-", [var.server_name, var.environment, "codedeploy-role"])

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : ["codedeploy.amazonaws.com"]
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  path = "/"

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "codedeploy_role-attach" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

// Code Pipeline에 사용할 role
resource "aws_iam_role" "codepipeline_role" {
  name = join("-", [var.server_name, var.environment, "codepipeline-role"])

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
            "codedeploy:GetApplication",
            "iam:PassRole"
          ]
        }
      ]
    })
  }

  tags = local.tags
}


resource "aws_iam_role_policy_attachment" "codepipeline_role-attach" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployDeployerAccess"
}

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



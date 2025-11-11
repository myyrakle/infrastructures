// Batch 작업 정의
resource "aws_batch_job_definition" "test" {
  name = join(":", ["test"])
  type = "container"

  platform_capabilities = [
    "FARGATE",
  ]

  container_properties = jsonencode({
    command = ["sh", "/home/run.sh", "TEST_PROCESSOR"],
    image   = join(":", [var.ecr_url, "latest"])

    resourceRequirements = [
      {
        type  = "VCPU"
        value = "0.25"
      },
      {
        type  = "MEMORY"
        value = "512"
      }
    ]

    environment = [
      {
        name  = "Key"
        value = "Value"
      }
    ]

    networkConfiguration = {
      "assignPublicIp" : "ENABLED"
    }

    executionRoleArn = var.task_execution_role
  })

  // AWS 내부 장애시에만 재시도
  retry_strategy {
    attempts = 2

    evaluate_on_exit {
      action           = "EXIT"
      on_status_reason = "Essential container in task exited"
    }
  }
}


resource "aws_scheduler_schedule" "test" {
  name = "test"

  flexible_time_window {
    mode = "OFF"
  }

  state = "ENABLED"

  // cron 식
  // schedule_expression = "cron(15 10 ? * 6L 2022-2023)" 

  // 한시간마다 동작
  // schedule_expression = "rate(1 hour)" 

  schedule_expression = "cron(* * ? * * *)"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:batch:submitJob"
    role_arn = var.event_role_arn

    input = jsonencode({
      JobDefinition = aws_batch_job_definition.test.arn,
      JobName       = "test",
      JobQueue      = var.job_queue_arn
    })
  }
}

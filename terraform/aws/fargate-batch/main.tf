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

// Batch 컴퓨팅 환경
resource "aws_batch_compute_environment" "compute_env" {
  compute_environment_name = local.resource_id

  compute_resources {
    max_vcpus = var.max_vcpu

    security_group_ids = [
      aws_security_group.batch_security_group.id
    ]

    subnets = var.subnet_ids
    type    = "FARGATE"
  }

  service_role = aws_iam_role.aws_batch_service_role.arn
  type         = "MANAGED"

  depends_on = [aws_iam_role_policy_attachment.batch_attach]
}

// Batch 작업 큐
resource "aws_batch_job_queue" "job_queue" {
  name     = local.resource_id
  state    = "ENABLED"
  priority = 1

  compute_environments = [
    aws_batch_compute_environment.compute_env.arn,
  ]
}

// ECR
// 서버 프로지버닝에 사용할 docker image를 관리합니다.
resource "aws_ecr_repository" "ecr" {
  name                 = local.resource_id
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.tags
}

// ECS 
// 서버를 배포할 ECS 클러스터입니다. 
resource "aws_ecs_cluster" "ecs_cluster" {
  name = local.resource_id

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = local.tags
}

module "processors" {
  source = "./processors"

  task_execution_role = aws_iam_role.task_execution_role.arn
  ecr_url             = aws_ecr_repository.ecr.repository_url
  job_queue_arn       = aws_batch_job_queue.job_queue.arn
  event_role_arn      = aws_iam_role.event_role.arn
}

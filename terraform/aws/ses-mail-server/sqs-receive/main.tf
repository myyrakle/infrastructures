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

# SES Domain Identity (도메인 인증)
resource "aws_ses_domain_identity" "main" {
  domain = var.mail_server_domain
}

# SES Domain DKIM (이메일 인증)
resource "aws_ses_domain_dkim" "main" {
  domain = aws_ses_domain_identity.main.domain
}

# SES Receipt Rule Set (활성화된 규칙 세트)
resource "aws_ses_receipt_rule_set" "main" {
  rule_set_name = "${var.service_name}-rule-set"
}

# SES Active Receipt Rule Set (규칙 세트 활성화)
resource "aws_ses_active_receipt_rule_set" "main" {
  rule_set_name = aws_ses_receipt_rule_set.main.rule_set_name
}

# SNS Topic (SES에서 이메일을 받을 토픽)
resource "aws_sns_topic" "ses_notifications" {
  name              = "${var.service_name}-ses-notifications"
  kms_master_key_id = var.sns_kms_key_id

  tags = {
    Name        = "${var.service_name}-ses-notifications"
    Application = var.service_name
    Environment = var.environment
  }
}

# SNS Topic Policy (SES가 메시지를 publish할 수 있도록 허용)
resource "aws_sns_topic_policy" "ses_notifications" {
  arn = aws_sns_topic.ses_notifications.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ses.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.ses_notifications.arn
        Condition = {
          StringEquals = {
            "AWS:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# SQS Queue (표준 큐)
resource "aws_sqs_queue" "email_queue" {
  name                       = "${var.service_name}-email-queue"
  visibility_timeout_seconds = 300
  message_retention_seconds  = 1209600 # 14일
  receive_wait_time_seconds  = 20      # Long polling

  # 암호화 설정 (KMS 키가 지정되지 않으면 AWS 관리형 SSE 사용)
  sqs_managed_sse_enabled = var.sqs_kms_key_id == null ? true : null
  kms_master_key_id       = var.sqs_kms_key_id
  kms_data_key_reuse_period_seconds = var.sqs_kms_key_id != null ? 300 : null

  tags = {
    Name        = "${var.service_name}-email-queue"
    Application = var.service_name
    Environment = var.environment
  }
}

# SQS Queue Policy (SNS가 메시지를 전송할 수 있도록 허용)
resource "aws_sqs_queue_policy" "email_queue" {
  queue_url = aws_sqs_queue.email_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action   = "SQS:SendMessage"
        Resource = aws_sqs_queue.email_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.ses_notifications.arn
          }
        }
      }
    ]
  })
}

# SNS -> SQS Subscription (SNS 토픽을 SQS 큐에 연결)
resource "aws_sns_topic_subscription" "email_queue" {
  topic_arn = aws_sns_topic.ses_notifications.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.email_queue.arn
}

# SES Receipt Rule (이메일을 SNS로 전달)
resource "aws_ses_receipt_rule" "sns_forward" {
  name          = "${var.service_name}-sns-forward"
  rule_set_name = aws_ses_receipt_rule_set.main.rule_set_name
  recipients    = var.receipt_rule_recipients
  enabled       = true
  scan_enabled  = true

  sns_action {
    topic_arn = aws_sns_topic.ses_notifications.arn
    position  = 1
  }

  depends_on = [aws_sns_topic_policy.ses_notifications]
}

# 현재 AWS 계정 정보
data "aws_caller_identity" "current" {}

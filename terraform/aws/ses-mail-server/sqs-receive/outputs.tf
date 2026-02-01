# SES Domain Identity
output "ses_domain_identity_arn" {
  description = "ARN of the SES domain identity"
  value       = aws_ses_domain_identity.main.arn
}

output "ses_domain_verification_token" {
  description = "Verification token for the SES domain"
  value       = aws_ses_domain_identity.main.verification_token
}

# SES DKIM
output "ses_dkim_tokens" {
  description = "DKIM tokens for domain verification"
  value       = aws_ses_domain_dkim.main.dkim_tokens
}

# SNS Topic
output "sns_topic_arn" {
  description = "ARN of the SNS topic for SES notifications"
  value       = aws_sns_topic.ses_notifications.arn
}

output "sns_topic_name" {
  description = "Name of the SNS topic"
  value       = aws_sns_topic.ses_notifications.name
}

# SQS Queue
output "sqs_queue_url" {
  description = "URL of the SQS queue"
  value       = aws_sqs_queue.email_queue.url
}

output "sqs_queue_arn" {
  description = "ARN of the SQS queue"
  value       = aws_sqs_queue.email_queue.arn
}

output "sqs_queue_name" {
  description = "Name of the SQS queue"
  value       = aws_sqs_queue.email_queue.name
}

# SES Receipt Rule Set
output "ses_rule_set_name" {
  description = "Name of the SES receipt rule set"
  value       = aws_ses_receipt_rule_set.main.rule_set_name
}

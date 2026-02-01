// 리전
variable "region" {
  description = "region"
  type        = string
}

// 서버명 (server_name-environment 형태로 구성됩니다.)
variable "service_name" {
  description = "The name of the service you want to create."
  type        = string
}

// 환경
variable "environment" {
  description = "The environment of the service (e.g., development, production)."
  type        = string
}

// 도메인
variable "mail_server_domain" {
  description = "mail server domain (example: mail.example.com)"
  type        = string
}

// 수신할 이메일 주소 목록 (빈 리스트면 모든 이메일 수신)
variable "receipt_rule_recipients" {
  description = "List of email addresses to receive (empty list = receive all emails)"
  type        = list(string)
  default     = []
}

// SNS KMS 키 ID (null이면 AWS 관리형 키 사용)
variable "sns_kms_key_id" {
  description = "KMS key ID for SNS topic encryption (default: alias/aws/sns)"
  type        = string
  default     = "alias/aws/sns"
}

// SQS KMS 키 ID (null이면 AWS 관리형 SSE 사용)
variable "sqs_kms_key_id" {
  description = "KMS key ID for SQS queue encryption (default: null = AWS managed SSE)"
  type        = string
  default     = null
}
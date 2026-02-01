# SES Email Receive Pipeline (SES -> SNS -> SQS)

AWS SES에서 이메일을 수신하여 SNS를 거쳐 SQS 큐로 전달하는 파이프라인 구성입니다.

## 아키텍처

```
이메일 수신 → AWS SES → SNS Topic → SQS Queue
```

## 구성 요소

1. **AWS SES (Simple Email Service)**
   - Domain Identity: 도메인 인증
   - DKIM: 이메일 서명 인증
   - Receipt Rule Set: 이메일 수신 규칙
   - Receipt Rule: SNS로 이메일 전달

2. **AWS SNS (Simple Notification Service)**
   - Topic: SES에서 받은 이메일 알림
   - Topic Policy: SES가 메시지를 publish할 수 있도록 권한 설정

3. **AWS SQS (Simple Queue Service)**
   - Standard Queue: 이메일 메시지 저장
   - Queue Policy: SNS가 메시지를 전송할 수 있도록 권한 설정

## 사용 방법

### 1. 변수 설정

`terraform.tfvars` 파일을 생성하여 변수를 설정합니다.

```hcl
region              = "ap-northeast-2"
service_name        = "my-email-service"
environment         = "production"
mail_server_domain  = "mail.example.com"

# 특정 이메일 주소만 수신하려면 (선택사항)
receipt_rule_recipients = ["support@mail.example.com", "contact@mail.example.com"]

# 모든 이메일을 수신하려면 (기본값)
# receipt_rule_recipients = []
```

### 2. Terraform 초기화 및 적용

```bash
terraform init
terraform plan
terraform apply
```

### 3. DNS 설정

Terraform 적용 후, 다음 DNS 레코드를 도메인에 추가해야 합니다.

#### 도메인 인증 (TXT 레코드)
```bash
# Terraform output에서 확인
terraform output ses_domain_verification_token

# DNS에 추가할 레코드
_amazonses.mail.example.com TXT "verification_token_here"
```

#### DKIM 인증 (CNAME 레코드)
```bash
# Terraform output에서 확인
terraform output ses_dkim_tokens

# 3개의 CNAME 레코드를 추가 (각 DKIM 토큰마다)
token1._domainkey.mail.example.com CNAME token1.dkim.amazonses.com
token2._domainkey.mail.example.com CNAME token2.dkim.amazonses.com
token3._domainkey.mail.example.com CNAME token3.dkim.amazonses.com
```

#### MX 레코드 (이메일 수신)
```
mail.example.com MX 10 inbound-smtp.ap-northeast-2.amazonaws.com
```

### 4. 도메인 인증 확인

AWS SES 콘솔에서 도메인이 "verified" 상태가 될 때까지 기다립니다 (보통 10분~48시간).

### 5. SQS에서 이메일 메시지 확인

SQS 큐에서 메시지를 읽어 처리할 수 있습니다.

```bash
# 큐 URL 확인
terraform output sqs_queue_url

# AWS CLI로 메시지 확인
aws sqs receive-message --queue-url <queue-url> --region ap-northeast-2
```

## Outputs

- `ses_domain_identity_arn`: SES 도메인 Identity ARN
- `ses_domain_verification_token`: 도메인 인증 토큰
- `ses_dkim_tokens`: DKIM 인증 토큰 (3개)
- `sns_topic_arn`: SNS 토픽 ARN
- `sns_topic_name`: SNS 토픽 이름
- `sqs_queue_url`: SQS 큐 URL
- `sqs_queue_arn`: SQS 큐 ARN
- `sqs_queue_name`: SQS 큐 이름
- `ses_rule_set_name`: SES 규칙 세트 이름

## 메시지 형식

SQS 큐에 저장되는 메시지는 다음과 같은 형식입니다.

```json
{
  "Type": "Notification",
  "MessageId": "...",
  "TopicArn": "arn:aws:sns:...",
  "Message": "{\"notificationType\":\"Received\",\"mail\":{...},\"receipt\":{...}}",
  "Timestamp": "2024-01-01T00:00:00.000Z",
  "SignatureVersion": "1",
  "Signature": "...",
  "SigningCertURL": "...",
  "UnsubscribeURL": "..."
}
```

`Message` 필드를 파싱하면 실제 이메일 내용을 확인할 수 있습니다.

## 주의사항

1. **SES Sandbox**: AWS 계정이 SES Sandbox 모드인 경우, 인증된 이메일 주소에서만 이메일을 보낼 수 있습니다. Production 사용을 위해서는 SES의 Sandbox 해제를 신청해야 합니다.

2. **Region**: SES는 모든 리전에서 사용 가능하지 않습니다. 사용 가능한 리전인지 확인하세요.

3. **비용**: SQS 메시지 보관 기간은 14일로 설정되어 있습니다. 필요에 따라 조정하세요.

4. **보안**: 실제 운영 환경에서는 SQS 큐에 대한 접근 권한을 적절히 제한해야 합니다.

## 정리

```bash
terraform destroy
```

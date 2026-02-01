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

# 암호화 설정 (선택사항)
# sns_kms_key_id = "alias/aws/sns"  # SNS용 AWS 관리형 KMS 키 (기본값)
# sqs_kms_key_id = null              # SQS용 AWS 관리형 SSE (기본값)
# 커스텀 KMS 키를 사용하려면:
# sns_kms_key_id = "arn:aws:kms:ap-northeast-2:123456789012:key/your-key-id"
# sqs_kms_key_id = "arn:aws:kms:ap-northeast-2:123456789012:key/your-key-id"
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

SQS 큐에 저장되는 메시지는 원시 메시지 전송(Raw Message Delivery)이 활성화되어 있어, SES에서 받은 원본 메시지가 직접 전달됩니다.

```json
{
  "notificationType": "Received",
  "mail": {
    "timestamp": "2024-01-01T00:00:00.000Z",
    "source": "sender@example.com",
    "messageId": "...",
    "destination": ["receiver@mail.example.com"],
    "headersTruncated": false,
    "headers": [
      {
        "name": "From",
        "value": "sender@example.com"
      },
      {
        "name": "To",
        "value": "receiver@mail.example.com"
      },
      {
        "name": "Subject",
        "value": "Email Subject"
      }
    ],
    "commonHeaders": {
      "from": ["sender@example.com"],
      "to": ["receiver@mail.example.com"],
      "subject": "Email Subject"
    }
  },
  "receipt": {
    "timestamp": "2024-01-01T00:00:00.000Z",
    "processingTimeMillis": 100,
    "recipients": ["receiver@mail.example.com"],
    "spamVerdict": {
      "status": "PASS"
    },
    "virusVerdict": {
      "status": "PASS"
    },
    "spfVerdict": {
      "status": "PASS"
    },
    "dkimVerdict": {
      "status": "PASS"
    },
    "action": {
      "type": "SNS",
      "topicArn": "arn:aws:sns:...",
      "encoding": "UTF8"
    }
  }
}
```

원시 메시지 전송이 활성화되어 있어 SNS 메타데이터 래핑 없이 SES 이메일 알림이 직접 전달됩니다.

## 보안

### 암호화

이 구성은 기본적으로 다음과 같은 암호화를 적용합니다.

1. **SNS Topic 암호화**
   - 기본값: AWS 관리형 KMS 키 (`alias/aws/sns`)
   - 이메일 데이터가 SNS를 통해 전달될 때 암호화됩니다.

2. **SQS Queue 암호화**
   - 기본값: AWS 관리형 SSE (Server-Side Encryption)
   - 큐에 저장되는 메시지가 암호화됩니다.

3. **커스텀 KMS 키 사용**
   - 더 강력한 제어가 필요한 경우 커스텀 KMS 키를 생성하여 사용할 수 있습니다.
   - `terraform.tfvars`에서 `sns_kms_key_id`와 `sqs_kms_key_id`를 설정하세요.

### IAM 권한

SQS 큐와 SNS 토픽에 접근하려면 적절한 IAM 권한이 필요합니다.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ],
      "Resource": "arn:aws:sqs:REGION:ACCOUNT_ID:QUEUE_NAME"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": "arn:aws:kms:REGION:ACCOUNT_ID:key/KEY_ID"
    }
  ]
}
```

## 주의사항

1. **SES Sandbox**: AWS 계정이 SES Sandbox 모드인 경우, 인증된 이메일 주소에서만 이메일을 보낼 수 있습니다. Production 사용을 위해서는 SES의 Sandbox 해제를 신청해야 합니다.

2. **Region**: SES는 모든 리전에서 사용 가능하지 않습니다. 사용 가능한 리전인지 확인하세요.

3. **비용**: SQS 메시지 보관 기간은 14일로 설정되어 있습니다. 필요에 따라 조정하세요.

4. **KMS 비용**: KMS 키를 사용하면 암호화/복호화 작업마다 추가 비용이 발생합니다. AWS 관리형 키는 무료이지만, 커스텀 키는 월별 요금과 API 호출 요금이 부과됩니다.

## 정리

```bash
terraform destroy
```

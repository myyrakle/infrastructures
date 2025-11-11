# 테이블을 여기에서 정의합니다.

// 커넥션 정보 테이블
resource "aws_dynamodb_table" "connection_table" {
  name         = "${local.resource_id}_connection"
  billing_mode = "PAY_PER_REQUEST" # 온디맨드 요금
  hash_key     = "connection_id"
  # range_key    = ""

  attribute {
    name = "connection_id"
    type = "S"
  }

  attribute {
    name = "user_id"
    type = "S"
  }

  // 글로벌 보조 인덱스
  global_secondary_index {
    name     = "user_id-index"
    hash_key = "user_id"
    // range_key          = ""
    projection_type = "ALL"
  }

  tags = local.tags
}

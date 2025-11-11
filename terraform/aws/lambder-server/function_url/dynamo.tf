# 테이블을 여기에서 정의합니다.

// 유저 테이블
resource "aws_dynamodb_table" "user-table" {
  name         = "${local.resource_id}-user"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "uuid"
  # range_key    = ""

  attribute {
    name = "uuid"
    type = "S"
  }

  attribute {
    name = "email"
    type = "S"
  }

  // 글로벌 보조 인덱스
  global_secondary_index {
    name     = "email-index"
    hash_key = "email"
    // range_key          = ""
    projection_type = "ALL"
  }

  tags = local.tags
}

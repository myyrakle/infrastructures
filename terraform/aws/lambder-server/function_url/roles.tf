// Lambda Role
resource "aws_iam_role" "lambda_role" {
  name = local.resource_id
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : ["lambda.amazonaws.com"]
        },
        "Action" : [
          "sts:AssumeRole"
        ]
      }
    ]
  })

  inline_policy {
    name = "root"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          "Sid" : "SpecificTable",
          "Effect" : "Allow",
          "Action" : [
            "dynamodb:BatchGet*",
            "dynamodb:DescribeStream",
            "dynamodb:DescribeTable",
            "dynamodb:Get*",
            "dynamodb:Query",
            "dynamodb:Scan",
            "dynamodb:BatchWrite*",
            "dynamodb:CreateTable",
            "dynamodb:Delete*",
            "dynamodb:Update*",
            "dynamodb:PutItem"
          ],
          "Resource" : [
            // 테이블을 추가할 때마다 여기에도 리소스를 추가해줍니다.
            "arn:aws:dynamodb:*:*:table/${local.resource_id}_user"
          ]
        }
      ]
    })
  }
}

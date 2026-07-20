data "aws_caller_identity" "current" {}

locals {
  region = "us-east-1"

  tags = {
    Environment = var.environment
    Application = var.server_name
  }

  resource_id = join("-", [var.system_name, var.environment])

  account_id = data.aws_caller_identity.current.account_id
}

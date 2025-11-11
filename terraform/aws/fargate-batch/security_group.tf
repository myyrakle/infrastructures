// Batch Security Group
resource "aws_security_group" "batch_security_group" {
  name        = "${local.resource_id}-batch-sg"
  description = "batch sg"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

// 로드밸런서 보안그룹
resource "aws_security_group" "loadbalancer_sg" {
  name        = "${local.resource_id}-lb-sg"
  description = "loadbalancer sg"
  vpc_id      = var.vpc_id

  ingress {
    description      = "allow all"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description      = "allow all"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = local.tags
}

// ECS Service 보안그룹
resource "aws_security_group" "ecs_service_sg" {
  name        = "${local.resource_id}-ecs-service-sg"
  description = "ecs service sg"
  vpc_id      = var.vpc_id

  egress {
    description      = "allow all TCP"
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = ""
    from_port        = var.portforward_host_port
    to_port          = var.portforward_host_port
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = local.tags
}


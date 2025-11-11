# security group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "${var.service_name}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  # 인바운드 규칙 - HTTP(80) 포트 모든 IP에서 허용
  ingress {
    description      = "HTTP from anywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # 아웃바운드 규칙 - 모든 트래픽 허용
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"  # 모든 프로토콜
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.service_name}-alb-sg"
    Environment = var.environment
    Application = var.service_name
  }
}

# Application Load Balancer
resource "aws_lb" "service_alb" {
  name               = "${local.resource_name}-alb"
  internal           = false # Set to true if you need an internal ALB
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false # Set to true for production environments

  lifecycle {
    create_before_destroy = true

    ignore_changes = [ enable_deletion_protection ]
  }

  tags = {
    Environment = var.environment
    Application = var.service_name
  }
}

# ALB Target Group
resource "aws_lb_target_group" "service_tg" {
  name = "${local.resource_name}-tg"
  port        = tonumber(var.health_check_port) # Ensure this is a number
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance" # Can be 'ip' or 'lambda' as well

  health_check {
    enabled             = true
    path                = var.health_check_path
    port                = var.health_check_port
    protocol            = "HTTP"
    matcher             = "200-399" # Successful HTTP codes
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Environment = var.environment
    Application = var.service_name
  }
}

# ALB Listener
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.service_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service_tg.arn
  }

  tags = {
    Environment = var.environment
    Application = var.service_name
  }
}

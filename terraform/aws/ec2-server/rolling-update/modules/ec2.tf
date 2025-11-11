# IAM Role for EC2 instances
resource "aws_iam_role" "ec2_role" {
  name = "${local.resource_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Application = var.service_name
  }
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ec2_cloudwatch_agent_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${local.resource_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name

  tags = {
    Environment = var.environment
    Application = var.service_name
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "service_log_group" {
  name              = "/aws/ec2/${local.resource_name}"
  retention_in_days = var.log_retention_in_days

  tags = {
    Environment = var.environment
    Application = var.service_name
  }
}

# Launch Template for Auto Scaling Group
resource "aws_launch_template" "start_service_launch_template" {
  name   =  "${local.resource_name}-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false # Private subnets, so no public IP
    security_groups             = var.ec2_security_group_ids
  }

  # User data to install CloudWatch agent and other necessary software
  user_data = base64encode(<<-EOF
              #!/bin/bash
              # Install CloudWatch Agent
              wget https://s3.${var.region}.amazonaws.com/amazoncloudwatch-agent-${var.region}/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
              dpkg -i -E ./amazon-cloudwatch-agent.deb
              
              # Configure CloudWatch Agent for memory and disk metrics
              cat <<'EOT' > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
              {
                "agent": {
                  "metrics_collection_interval": 60,
                  "run_as_user": "root"
                },
                "metrics": {
                  "append_dimensions": {
                    "AutoScalingGroupName": "$${aws:AutoScalingGroupName}",
                    "ImageId": "$${aws:ImageId}",
                    "InstanceId": "$${aws:InstanceId}",
                    "InstanceType": "$${aws:InstanceType}"
                  },
                  "metrics_collected": {
                    "disk": {
                      "measurement": [
                        "used_percent"
                      ],
                      "metrics_collection_interval": 60,
                      "resources": [
                        "*"
                      ]
                    },
                    "mem": {
                      "measurement": [
                        "mem_used_percent"
                      ],
                      "metrics_collection_interval": 60
                    }
                  }
                }
              }
              EOT
              /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
              
              # Start CloudWatch Agent
              systemctl start amazon-cloudwatch-agent
              systemctl enable amazon-cloudwatch-agent

              # Example: Install a simple web server (e.g., nginx)
              # apt-get update -y
              # apt-get install -y nginx
              # systemctl start nginx
              # systemctl enable nginx
              # echo "<h1>Hello from $(hostname -f)</h1>" > /var/www/html/index.html
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Environment = var.environment
      Application = var.service_name
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Environment = var.environment
      Application = var.service_name
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Environment = var.environment
    Application = var.service_name
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "service_asg" {
  name         = "${local.resource_name}-asg"
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = var.private_subnet_ids

  # 인스턴스 유지 관리 정책 - 가용성 우선
  instance_maintenance_policy {
    min_healthy_percentage = 100
    max_healthy_percentage = 110
  }

  # 로드밸런서로도 상태 확인을 함
  health_check_type = "ELB"

  # 상태 확인 유예 기간 (초 단위)
  # 이 기간에는 인스턴스가 초기화를 완료할 때까지 첫 번째 상태 확인을 지연시킵니다. 실행 중이 아닌 상태로 전환될 때 인스턴스가 종료되는 것을 방지하지 않습니다.
  health_check_grace_period = 180

  launch_template {
    id      = aws_launch_template.start_service_launch_template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.service_tg.arn]

  # Ensure instances are replaced if the launch template changes
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = local.resource_name
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [ desired_capacity, launch_template, min_size, max_size ]
  }
}

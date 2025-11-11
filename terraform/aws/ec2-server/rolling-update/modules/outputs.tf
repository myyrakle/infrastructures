output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.service_alb.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.service_alb.zone_id
}

output "ec2_role_arn" {
  description = "ARN of the IAM role for EC2 instances"
  value       = aws_iam_role.ec2_role.arn
}

output "log_group_name" {
  description = "Name of the CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.service_log_group.name
}

output "launch_template_id" {
  description = "ID of the Launch Template"
  value       = aws_launch_template.start_service_launch_template.id
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.service_asg.name
}

output "target_group_arn" {
  description = "ARN of the ALB Target Group"
  value       = aws_lb_target_group.service_tg.arn
}

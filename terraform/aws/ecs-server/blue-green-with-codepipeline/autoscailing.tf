// 오토스케일링 구성
resource "aws_appautoscaling_target" "auto_scaling" {
  max_capacity       = var.auto_scaling_max
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_service.ecs_service.name}/${aws_ecs_service.ecs_service.name}"
  role_arn           = aws_iam_role.scalable_target_role.arn
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

// CPU 스케일링 정책 구성입니다.
resource "aws_appautoscaling_policy" "scaling_policy_cpu" {
  name               = "${local.resource_id}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.auto_scaling.resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = var.cpu_scail_out_percent
    scale_in_cooldown  = 300
    scale_out_cooldown = 120
  }
}

// 메모리 스케일링 정책 구성입니다.
resource "aws_appautoscaling_policy" "scaling_policy_memory" {
  name               = "${local.resource_id}-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.auto_scaling.resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = var.memory_scail_out_percent
    scale_in_cooldown  = 300
    scale_out_cooldown = 120
  }
}

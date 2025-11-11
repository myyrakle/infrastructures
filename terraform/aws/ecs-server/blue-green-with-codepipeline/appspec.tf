locals {
  appspec = jsonencode({
    version = "1"
    Resources = [
      {
        "TargetService" : {
          "Type" : "AWS::ECS::Service",
          "Properties" : {
            "TaskDefinition" : "${aws_ecs_task_definition.task_definition.arn}",
            "LoadBalancerInfo" : {
              "ContainerName" : local.resource_id,
              "ContainerPort" : var.portforward_container_port
            },
            "PlatformVersion" : "1.3.0"
          }
        }
      }
    ]
  })
}

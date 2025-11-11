// 아티팩트 버킷
resource "aws_s3_bucket" "artifact_bucket" {
  bucket = "${local.resource_id}-artifact-bucket"

  tags = local.tags
}

// 빌드 캐시용 버킷
resource "aws_s3_bucket" "cache_bucket" {
  bucket = "${local.resource_id}-cache-bucket"

  tags = local.tags
}

// code build
resource "aws_codebuild_project" "codebuild" {
  name          = local.resource_id
  description   = "code build"
  build_timeout = "30"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type     = "S3"
    location = aws_s3_bucket.artifact_bucket.bucket
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.cache_bucket.bucket
  }

  environment {
    compute_type                = var.codebuild_compute_type
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = aws_ecr_repository.ecr.name
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = var.docker_release_tag
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = local.account_id
    }

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }

    environment_variable {
      name  = "EnvironmentName"
      value = local.resource_id
    }

    environment_variable {
      name  = "TaskDefinition"
      value = local.taskdef
    }

    environment_variable {
      name  = "AppSpec"
      value = local.appspec
    }
  }

  source {
    type      = "S3"
    location  = "${aws_s3_bucket.artifact_bucket.arn}/source.zip"
    buildspec = var.buildspec_path
  }

  tags = local.tags
}

// code deploy
resource "aws_codedeploy_app" "deploy" {
  name             = local.resource_id
  compute_platform = "ECS"

  tags = local.tags
}

resource "aws_codedeploy_deployment_config" "config_deploy" {
  deployment_config_name = local.resource_id
  compute_platform       = "ECS"

  traffic_routing_config {
    type = "AllAtOnce"
  }
}

// blue-green 배포를 위한 code deploy group
resource "aws_codedeploy_deployment_group" "deployment_group" {
  app_name               = aws_codedeploy_app.deploy.name
  deployment_config_name = aws_codedeploy_deployment_config.config_deploy.deployment_config_name
  deployment_group_name  = local.resource_id
  service_role_arn       = aws_iam_role.codedeploy_role.arn

  // 실패시 롤백
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = "CONTINUE_DEPLOYMENT"
      wait_time_in_minutes = 0
    }

    // green 배포 성공시 blue 인스턴스를 5분 후에 삭제합니다.
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.ecs_cluster.name
    service_name = aws_ecs_service.ecs_service.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.https_listener.arn]
      }

      test_traffic_route {
        listener_arns = [aws_lb_listener.http_test_listener.arn]
      }

      target_group {
        name = aws_lb_target_group.target_group_blue.name
      }

      target_group {
        name = aws_lb_target_group.target_group_green.name
      }
    }
  }
}

// code pipeline
resource "aws_codepipeline" "codepipeline" {
  name     = local.resource_id
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.artifact_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      configuration = {
        Owner      = var.github_user
        Repo       = var.github_repository
        Branch     = var.github_branch
        OAuthToken = var.github_oauth_token
      }

      name     = "Source"
      category = "Source"
      owner    = "ThirdParty"
      provider = "GitHub"
      version  = "1"

      output_artifacts = ["Source"]
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["Source"]
      output_artifacts = ["Build"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.codebuild.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      input_artifacts = ["Build"]
      version         = "1"
      run_order       = 1

      configuration = {
        ApplicationName                = aws_codedeploy_app.deploy.name
        DeploymentGroupName            = aws_codedeploy_deployment_group.deployment_group.deployment_group_name
        TaskDefinitionTemplateArtifact = "Build"
        TaskDefinitionTemplatePath     = "taskdef.json"
        AppSpecTemplateArtifact        = "Build"
        AppSpecTemplatePath            = "appspec.json"
      }
    }
  }

  tags = local.tags
}

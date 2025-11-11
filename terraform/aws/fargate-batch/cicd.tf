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
      name  = "ECR_NAME"
      value = aws_ecr_repository.ecr.name
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
  }

  source {
    type      = "S3"
    location  = "${aws_s3_bucket.artifact_bucket.arn}/source.zip"
    buildspec = var.buildspec_path
  }

  tags = local.tags
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
        ConnectionArn : var.codestar_arn
        FullRepositoryId : join("/", [var.github_user, var.github_repository])
        BranchName : var.github_branch
      }

      name     = "Source"
      category = "Source"
      owner    = "AWS"
      provider = "CodeStarSourceConnection"
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

  tags = local.tags
}

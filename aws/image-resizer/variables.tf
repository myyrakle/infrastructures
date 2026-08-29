// 리전
variable "region" {
  description = "region"
  type        = string
}

// tag 및 리소스 이름 구성에 사용됨
variable "environment" {
  description = "environment info. (e.g: prod, dev, stage, test)"
  type        = string
}

// 서버명 (server_name-environment 형태로 구성됩니다.)
variable "system_name" {
  description = "The name of the server machine you want to create."
  type        = string
}

// Lambda runtime 
// https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime 참조
// 커스텀 런타임은 provided.al2, provided
// nodejs | nodejs4.3 | nodejs6.10 | nodejs8.10 | nodejs10.x | nodejs12.x | nodejs14.x | nodejs16.x | java8 | java8.al2 | java11 | python2.7 | python3.6 | python3.7 | python3.8 | python3.9 | dotnetcore1.0 | dotnetcore2.0 | dotnetcore2.1 | dotnetcore3.1 | dotnet6 | nodejs4.3-edge | go1.x | ruby2.5 | ruby2.7 | provided | provided.al2 | nodejs18.x | python3.10 | java17
variable "lambda_runtime" {
  description = "lambda runtime"
  type        = string
  default     = "nodejs16.x"
}

// Lambda layers 
variable "lambda_layers" {
  description = "layer arn list"
  type        = list(string)
  default     = []
}

variable "codestar_arn" {
  description = "CodeStarConnection ARN"
  type        = string
}

// 빌드에 사용할 buildspec.yml 위치입니다.
variable "buildspec_path" {
  description = "BuildSpec file path (e.g: \"/prod/buildspec.yml\")"
  type        = string
  default     = "buildspec.yml"
}

// code build 컴퓨팅 타입입니다.
// 다음 문서를 참고합니다. https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html
variable "codebuild_compute_type" {
  description = "The compute type of the codebuild. (e.g: BUILD_GENERAL1_SMALL)"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "github_user" {
  description = "The username of the github repository."
  type        = string
}

variable "github_repository" {
  description = "The name of the github repository."
  type        = string
}

variable "github_branch" {
  description = "The name of the github branch."
  type        = string
}

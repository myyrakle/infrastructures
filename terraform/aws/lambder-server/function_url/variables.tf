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
variable "server_name" {
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
  default     = "provided.al2"
}

// Lambda layers 
variable "lambda_layers" {
  description = "layer arn list"
  type        = list(string)
  default     = []
}

// cors 설정
// Frontend(브라우저)와 연동할 경우 와일드카드(*)를 삭제하고 해당 호스트 주소를 추가합니다.
variable "cors_allow_origins" {
  description = "cors allow origins"
  type        = list(string)
  default     = ["*"]
}

// cors 설정
variable "cors_allow_headers" {
  description = "cors allow headers"
  type        = list(string)
  default     = ["date", "keep-alive", "content-type", "authorization"]
}

// cors 설정
variable "cors_expose_headers" {
  description = "cors expose headers"
  type        = list(string)
  default     = ["date", "keep-alive"]
}


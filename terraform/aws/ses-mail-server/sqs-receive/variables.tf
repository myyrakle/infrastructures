// 리전
variable "region" {
  description = "region"
  type        = string
}

// 서버명 (server_name-environment 형태로 구성됩니다.)
variable "service_name" {
  description = "The name of the service you want to create."
  type        = string
}
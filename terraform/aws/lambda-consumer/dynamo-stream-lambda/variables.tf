// 리전
variable "region" {
  description = "AWS Region. (e.g: us-west-1)"
  type        = string
  default     = "us-west-1"
}

// tag 및 리소스 이름 구성에 사용됨
variable "environment" {
  description = "environment info. (e.g: prod, dev, qa, test)"
  type        = string
}

// 서비스 이름
variable "service_name" {
  description = "service name. (e.g: sync_library_clothes)"
  type        = string
}

// 메세지 배치 사이즈 
variable "batch_size" {
  description = "Batch size"
  type        = number
  default     = 8
}

// 실패 후 재시도를 할때 반으로 나눠서 재시도할지 여부입니다.
variable "bisect_batch_on_function_error" {
  description = "Bisect batch on function error"
  type        = bool
  default     = false
}

// 최대 재시도 횟수입니다. (-1면 무한대)
variable "maximum_retry_attempts" {
  description = "Maximum retry attempts"
  type        = number
  default     = -1
}

// Lambda를 실행하기 전에 메세지를 수집하는 대기시간 
variable "batch_window_seconds" {
  description = "Batch window seconds"
  type        = number
  default     = 1
}

// 동시에 실행할 수 있는 Lambda의 개수입니다. (1-10)
variable "parallelization_factor" {
  description = "Parallelization factor"
  type        = number
  default     = 1
}

// Lambda의 Subnet ID
variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

// Lambda의 Security Group ID
variable "security_group_id" {
  description = "Security Group ID"
  type        = string
}
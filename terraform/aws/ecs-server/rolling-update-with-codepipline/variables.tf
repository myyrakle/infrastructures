// 리전
variable "region" {
  description = "region"
  type        = string
}

// 서버 구성에 사용할 VPC입니다.
variable "vpc_id" {
  description = "VPC ID. That VPC must have at least 2 subnets for availability. (e.g: vpc-053f9aaabecf3b6bc)"
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

// 로그 삭제 대기일수. (14=14일, 0=삭제하지않음)
variable "log_retention_in_days" {
  description = "The name of the server machine you want to create."
  type        = number
  default     = 0
}

// 컨테이너 포트포워딩 설정입니다.
// portforward_host_port를 1000, portforward_container_port를 2000으로 하면 1000->2000으로 포워딩됩니다.
variable "portforward_host_port" {
  description = "host port"
  type        = number
  default     = 80
}

// 컨테이너 포트포워딩 설정입니다.
variable "portforward_container_port" {
  description = "container port"
  type        = number
  default     = 80
}

// 배포에 사용할 docker 태그입니다. 
variable "docker_release_tag" {
  description = "value of docker release tag. (e.g: latest, 1.0.0, 1.0.0-rc1)"
  type        = string
  default     = "latest"
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

variable "github_oauth_token" {
  description = "The oauth token for github. (e.g: ghp_KZymx3mI6f3x*****5GN3W5RItAB1fzlyi)"
  type        = string
}

// 서브넷 목록
variable "subnet_ids" {
  description = "Subnet IDs. (e.g: [subnet-0a9b8c7d6e5f4a3b2, subnet-0a9b8c7d6e5f4a3b2])"
  type        = list(string)
}

// ACM SSL 인증서 ARN
variable "certificate_arn" {
  description = "The ARN of the certificate to use for SSL. (e.g: arn:aws:acm:ap-northeast-2:210706881319:certificate/6a0b3a8b-bcb1-491d-a814-078739105983)"
  type        = string
}

// docker container entrypoint
variable "docker_entrypoint" {
  description = "The entrypoint of the docker image. (e.g: \"sh\", \"run.sh\")"
  type        = list(string)
  default     = ["sh", "run.sh"]
}

// 헬스체크 api 경로
variable "healthcheck_uri" {
  description = "The uri of the healthcheck. (e.g: \"/health\")"
  type        = string
  default     = "/"
}

// 헬스체크 시간 간격 (초 단위)
variable "healthcheck_interval" {
  description = "The interval of the healthcheck. (e.g: 30)"
  type        = number
  default     = 30
}

// 빌드에 사용할 buildspec.yml 위치입니다.
variable "buildspec_path" {
  description = "BuildSpec file path (e.g: \"/prod/buildspec.yml\")"
  type        = string
  default     = "buildspec.yml"
}

// 컨테이너 메모리입니다. 메가바이트 단위입니다.
variable "container_memory" {
  description = "The memory of the container. It is in megabytes. (e.g: 2048)"
  type        = string
  default     = "2048"
}

// 컨테이너에 할당할 vcpu 개수입니다. 1024가 1vcpu입니다.
variable "container_cpu" {
  description = "The cpu of the container. 1024 is one vcpu. (e.g: 1024)"
  type        = string
  default     = "1024"
}

// target group 포트입니다. 
variable "target_group_port" {
  description = "The port of the target group. (e.g: 80)"
  type        = number
  default     = 80
}

// GENEVE, HTTP, HTTPS, TCP, TCP_UDP, TLS이 사용 가능합니다.
variable "target_group_protocol" {
  description = "value of target group port protocol. (e.g: HTTP, HTTPS, TCP)"
  type        = string
  default     = "HTTP"
}

// target group 프로토콜 버전입니다. 
// GRPC, HTTP2, HTTP1이 선택 가능합니다.
variable "target_group_protocol_version" {
  description = "value of target group port protocol version. (e.g: GRPC, HTTP2, HTTP1)"
  type        = string
  default     = "HTTP1"
}

// 오토스케일링 최대 개수입니다.
variable "auto_scaling_max" {
  description = "The max capacity of the auto scaling. (e.g: 10)"
  type        = number
  default     = 16
}

// 스케일아웃을 트리거할 cpu 수치입니다.
variable "cpu_scail_out_percent" {
  description = "The percent of the cpu scail out. (e.g: 80)"
  type        = number
  default     = 70
}

// 스케일아웃을 트리거할 메모리 수치입니다.
variable "memory_scail_out_percent" {
  description = "The percent of the cpu scail out. (e.g: 80)"
  type        = number
  default     = 70
}

// code build 컴퓨팅 타입입니다.
// 다음 문서를 참고합니다. https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html
variable "codebuild_compute_type" {
  description = "The compute type of the codebuild. (e.g: BUILD_GENERAL1_SMALL)"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

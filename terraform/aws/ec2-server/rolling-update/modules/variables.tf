// 리전
variable "region" {
  description = "AWS Region. (e.g: us-west-1)"
  type        = string
  default     = "us-east-1"
}

// 서비스 이름
variable "service_name" {
  description = "Name of the service, used for tagging and naming resources"
  type        = string
}

// 환경 스테이지
variable "environment" {
  description = "environment info. (e.g: prod, dev, qa, test)"
  type        = string
}

// EC2의 인스턴스 타입
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

// EC2에 할당할 PEM Key
variable "key_name" {
  description = "Name of the EC2 key pair"
  type        = string
}

// 리소스들이 할당될 VPC
variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

// ALB에 할당할 보안 그룹
variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

// EC2에 할당할 보안 그룹
variable "private_subnet_ids" {
  description = "List of private subnet IDs for EC2 instances"
  type        = list(string)
}

variable "ec2_security_group_ids" {
  description = "List of security group IDs for the EC2 instances"
  type        = list(string)
}

// 오토스케일링 기본 개수
variable "desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

// 오토 스케일링 최소 개수
variable "min_size" {
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

// 오토 스케일링 최대 개수
variable "max_size" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
  default     = 3
}

// 로드밸런서 - 헬스체크 경로
variable "health_check_path" {
  description = "Health check path for the ALB target group"
  type        = string
  default     = "/"
}

// 로드밸런서 - 헬스체크 포트
variable "health_check_port" {
  description = "Health check port for the ALB target group"
  type        = string
  default     = "80"
}

// Cloudwatch - 로그 보관 기간
variable "log_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group."
  type        = number
  default     = 7
}

// EC2 부팅에 사용할 기준 AMI ID
variable "ami_id" {
  description = "AMI ID for EC2 instances (Ubuntu 22.04)"
  type        = string
  default     = "ami-0a91cd9eb650de472"
}

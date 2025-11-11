variable "task_execution_role" {
  description = "task_execution_role"
  type        = string
}

variable "ecr_url" {
  description = "ecr_url"
  type        = string
}

variable "job_queue_arn" {
  description = "job_queue_arn"
  type        = string
}

variable "event_role_arn" {
  description = "event_role_arn"
  type        = string
}

variable "name_prefix" {
  description = "Lambda function name."
  type        = string
}

variable "lambda_role_arn" {
  description = "IAM role ARN for Lambda."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for environment variables, logs, and DLQ."
  type        = string
}

variable "artifact_s3_bucket" {
  description = "S3 bucket containing Lambda artifact."
  type        = string
}

variable "artifact_s3_key" {
  description = "S3 key containing Lambda artifact."
  type        = string
}

variable "environment_variables" {
  description = "Environment variables injected into Lambda."
  type        = map(string)
}

variable "memory_size" {
  description = "Lambda memory in MB."
  type        = number
  default     = 512
}

variable "timeout_seconds" {
  description = "Lambda timeout in seconds."
  type        = number
  default     = 15
}

variable "log_retention_days" {
  description = "CloudWatch log retention."
  type        = number
  default     = 30
}

variable "reserved_concurrent_executions" {
  description = "Concurrency cap to protect downstream systems and cost."
  type        = number
  default     = 10
}

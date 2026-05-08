variable "name_prefix" {
  description = "Prefix used for API resources."
  type        = string
}

variable "stage_name" {
  description = "API Gateway stage name."
  type        = string
}

variable "lambda_function_name" {
  description = "Lambda function name for alias-scoped invoke permission."
  type        = string
}

variable "lambda_invoke_arn" {
  description = "Lambda invoke ARN for AWS_PROXY integration."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for API access log encryption."
  type        = string
}

variable "throttle_rate_limit" {
  description = "Steady-state API requests per second."
  type        = number
}

variable "throttle_burst_limit" {
  description = "Short burst request capacity."
  type        = number
}

variable "access_log_retention_days" {
  description = "API access log retention."
  type        = number
  default     = 30
}

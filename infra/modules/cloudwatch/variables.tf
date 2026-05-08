variable "name_prefix" {
  description = "Prefix used for alarm names."
  type        = string
}

variable "lambda_function_name" {
  description = "Lambda function name."
  type        = string
}

variable "api_name" {
  description = "API Gateway REST API name."
  type        = string
}

variable "stage_name" {
  description = "API Gateway stage name."
  type        = string
}

variable "alarm_sns_topic_arn" {
  description = "Optional SNS topic ARN for alarm notifications."
  type        = string
  default     = null
}

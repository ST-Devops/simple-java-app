variable "name_prefix" {
  description = "Prefix used for IAM resource names."
  type        = string
}

variable "dynamodb_arn" {
  description = "ARN of the DynamoDB table accessed by Lambda."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN used by the application."
  type        = string
}

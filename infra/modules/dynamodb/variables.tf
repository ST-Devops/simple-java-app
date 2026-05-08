variable "name_prefix" {
  description = "Prefix used for table names."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for DynamoDB encryption."
  type        = string
}

variable "billing_mode" {
  description = "DynamoDB billing mode. PAY_PER_REQUEST is simple and cost-effective for spiky serverless workloads."
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "point_in_time_recovery" {
  description = "Enable PITR for data recovery."
  type        = bool
  default     = true
}

variable "deletion_protection_enabled" {
  description = "Prevent accidental table deletion."
  type        = bool
  default     = false
}

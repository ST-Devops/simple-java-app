variable "aws_region" {
  description = "AWS region for this environment."
  type        = string
  default     = "ap-south-1"
}

variable "artifact_s3_bucket" {
  description = "S3 bucket containing the Lambda deployment artifact. Managed by the deployment pipeline, not Terraform."
  type        = string
  default = "devops-test-iac-leambda"
}

variable "artifact_s3_key" {
  description = "S3 key for the Lambda deployment artifact."
  type        = string
  default     = "bootstrap/serverless-java-api-placeholder.zip"
}

variable "alarm_sns_topic_arn" {
  description = "Optional SNS topic ARN for alarms."
  type        = string
  default     = null
}

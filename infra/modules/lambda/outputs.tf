output "function_name" {
  description = "Lambda function name."
  value       = aws_lambda_function.this.function_name
}

output "function_arn" {
  description = "Lambda live alias ARN."
  value       = aws_lambda_alias.live.arn
}

output "invoke_arn" {
  description = "Lambda live alias invoke ARN for API Gateway."
  value       = aws_lambda_alias.live.invoke_arn
}

output "dlq_arn" {
  description = "Dead letter queue ARN."
  value       = aws_sqs_queue.dlq.arn
}

output "log_group_arn" {
  description = "CloudWatch log group ARN."
  value       = aws_cloudwatch_log_group.lambda.arn
}

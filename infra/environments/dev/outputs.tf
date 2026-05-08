output "api_endpoint" {
  description = "Base URL for the API Gateway stage."
  value       = module.api_gateway.api_endpoint
}

output "lambda_function_name" {
  description = "Lambda function name used by deployment scripts."
  value       = module.lambda.function_name
}

output "dynamodb_table_name" {
  description = "DynamoDB table name."
  value       = module.dynamodb.table_name
}

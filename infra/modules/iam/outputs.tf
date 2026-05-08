output "lambda_role_arn" {
  description = "IAM role ARN for Lambda."
  value       = aws_iam_role.lambda.arn
}

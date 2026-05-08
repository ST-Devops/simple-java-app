resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.name_prefix}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn
}

resource "aws_sqs_queue" "dlq" {
  name                              = "${var.name_prefix}-dlq"
  kms_master_key_id                 = var.kms_key_arn
  message_retention_seconds         = 1209600
  kms_data_key_reuse_period_seconds = 300
}

resource "aws_lambda_function" "this" {
  function_name = var.name_prefix
  role          = var.lambda_role_arn
  handler       = "com.example.serverless.ItemHandler::handleRequest"
  runtime       = "java21"

  s3_bucket = var.artifact_s3_bucket
  s3_key    = var.artifact_s3_key

  memory_size = var.memory_size
  timeout     = var.timeout_seconds
  publish     = true
  kms_key_arn = var.kms_key_arn

  reserved_concurrent_executions = var.reserved_concurrent_executions

  environment {
    variables = var.environment_variables
  }

  dead_letter_config {
    target_arn = aws_sqs_queue.dlq.arn
  }

  tracing_config {
    mode = "Active"
  }

  depends_on = [aws_cloudwatch_log_group.lambda]

  lifecycle {
    ignore_changes = [
      s3_bucket,
      s3_key
    ]
  }
}

resource "aws_lambda_alias" "live" {
  name             = "live"
  description      = "Stable alias used by API Gateway and deployment rollbacks."
  function_name    = aws_lambda_function.this.function_name
  function_version = aws_lambda_function.this.version

  lifecycle {
    ignore_changes = [function_version]
  }
}

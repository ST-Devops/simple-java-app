resource "aws_api_gateway_rest_api" "this" {
  name        = "${var.name_prefix}-rest-api"
  description = "REST API for ${var.name_prefix}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

data "aws_iam_policy_document" "api_gateway_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cloudwatch" {
  name               = "${var.name_prefix}-apigw-cloudwatch-role"
  assume_role_policy = data.aws_iam_policy_document.api_gateway_assume_role.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_account" "this" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

resource "aws_api_gateway_request_validator" "body" {
  name                        = "validate-body"
  rest_api_id                 = aws_api_gateway_rest_api.this.id
  validate_request_body       = true
  validate_request_parameters = true
}

resource "aws_api_gateway_model" "item" {
  rest_api_id  = aws_api_gateway_rest_api.this.id
  name         = "ItemRequest"
  content_type = "application/json"

  schema = jsonencode({
    type     = "object"
    required = ["name"]
    properties = {
      name = {
        type      = "string"
        minLength = 1
        maxLength = 120
      }
      description = {
        type      = "string"
        maxLength = 500
      }
      status = {
        type = "string"
        enum = ["ACTIVE", "ARCHIVED"]
      }
    }
    additionalProperties = false
  })
}

resource "aws_api_gateway_resource" "items" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "items"
}

resource "aws_api_gateway_resource" "item" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.items.id
  path_part   = "{id}"
}

locals {
  routes = {
    "GET /items" = {
      resource_id = aws_api_gateway_resource.items.id
      http_method = "GET"
      validate    = false
      has_id      = false
    }
    "POST /items" = {
      resource_id = aws_api_gateway_resource.items.id
      http_method = "POST"
      validate    = true
      has_id      = false
    }
    "GET /items/{id}" = {
      resource_id = aws_api_gateway_resource.item.id
      http_method = "GET"
      validate    = false
      has_id      = true
    }
    "PUT /items/{id}" = {
      resource_id = aws_api_gateway_resource.item.id
      http_method = "PUT"
      validate    = true
      has_id      = true
    }
    "DELETE /items/{id}" = {
      resource_id = aws_api_gateway_resource.item.id
      http_method = "DELETE"
      validate    = false
      has_id      = true
    }
  }
}

resource "aws_api_gateway_method" "routes" {
  for_each = local.routes

  rest_api_id          = aws_api_gateway_rest_api.this.id
  resource_id          = each.value.resource_id
  http_method          = each.value.http_method
  authorization        = "NONE"
  api_key_required     = false
  request_validator_id = each.value.validate ? aws_api_gateway_request_validator.body.id : null

  request_models = each.value.validate ? {
    "application/json" = aws_api_gateway_model.item.name
  } : {}

  request_parameters = each.value.has_id ? {
    "method.request.path.id" = true
  } : {}
}

resource "aws_api_gateway_integration" "routes" {
  for_each = local.routes

  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = each.value.resource_id
  http_method             = aws_api_gateway_method.routes[each.key].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.items.id,
      aws_api_gateway_resource.item.id,
      aws_api_gateway_method.routes,
      aws_api_gateway_integration.routes
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id
  stage_name    = var.stage_name

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_access.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      routeKey       = "$context.resourcePath"
      status         = "$context.status"
      responseLength = "$context.responseLength"
      integrationLatency = "$context.integrationLatency"
    })
  }
}

resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled        = true
    logging_level          = "INFO"
    throttling_rate_limit  = var.throttle_rate_limit
    throttling_burst_limit = var.throttle_burst_limit
  }

  depends_on = [aws_api_gateway_account.this]
}

resource "aws_cloudwatch_log_group" "api_access" {
  name              = "/aws/apigateway/${var.name_prefix}"
  retention_in_days = var.access_log_retention_days
  kms_key_id        = var.kms_key_arn
}

resource "aws_lambda_permission" "api" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  qualifier     = "live"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}

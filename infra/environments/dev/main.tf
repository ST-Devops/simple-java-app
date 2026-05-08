terraform {
  required_version = "~> 1.8"

  cloud {
    organization = "st-learn-devops"

    workspaces {
      name = "serverless-java-dev"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.47"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

locals {
  service_name = "serverless-java-api"
  environment  = "dev"

  common_tags = {
    Application = local.service_name
    Environment = local.environment
    ManagedBy   = "Terraform"
    Owner       = "platform"
    CostCenter  = "learning"
  }
}

module "kms" {
  source      = "../../modules/kms"
  name_prefix = "${local.service_name}-${local.environment}"
}

module "dynamodb" {
  source      = "../../modules/dynamodb"
  name_prefix = "${local.service_name}-${local.environment}"
  kms_key_arn = module.kms.key_arn

  billing_mode = "PAY_PER_REQUEST"
}

module "iam" {
  source       = "../../modules/iam"
  name_prefix  = "${local.service_name}-${local.environment}"
  dynamodb_arn = module.dynamodb.table_arn
  kms_key_arn  = module.kms.key_arn
}

module "lambda" {
  source = "../../modules/lambda"

  name_prefix        = "${local.service_name}-${local.environment}"
  lambda_role_arn    = module.iam.lambda_role_arn
  kms_key_arn        = module.kms.key_arn
  artifact_s3_bucket = var.artifact_s3_bucket
  artifact_s3_key    = var.artifact_s3_key

  environment_variables = {
    TABLE_NAME  = module.dynamodb.table_name
    ENVIRONMENT = local.environment
    LOG_LEVEL   = "INFO"
  }
}

module "api_gateway" {
  source = "../../modules/api-gateway"

  name_prefix         = "${local.service_name}-${local.environment}"
  stage_name          = local.environment
  lambda_function_name = module.lambda.function_name
  lambda_invoke_arn   = module.lambda.invoke_arn
  kms_key_arn         = module.kms.key_arn
  throttle_rate_limit = 50
  throttle_burst_limit = 100
}

module "cloudwatch" {
  source = "../../modules/cloudwatch"

  name_prefix          = "${local.service_name}-${local.environment}"
  lambda_function_name = module.lambda.function_name
  api_name             = module.api_gateway.api_name
  stage_name           = local.environment
  alarm_sns_topic_arn  = var.alarm_sns_topic_arn
}

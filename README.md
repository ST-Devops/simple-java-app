# Serverless Java API on AWS

Production-grade learning project for a Java Lambda REST API deployed on AWS with API Gateway, DynamoDB, CloudWatch, IAM least privilege, KMS encryption, Terraform Cloud remote state, and separated application deployment.

## Architecture

Request flow:

1. API Gateway REST API receives `/items` requests and applies request validation and throttling.
2. Lambda runs Java 21 code behind a stable `live` alias.
3. Lambda reads and writes item records in DynamoDB.
4. CloudWatch stores structured JSON logs and alarms on API and Lambda failures.
5. KMS encrypts DynamoDB data, Lambda environment variables, logs, and the dead letter queue.

## Repository Layout

```text
infra/
  backend/                 Terraform Cloud notes
  environments/dev/         Dev composition layer
  environments/prod/        Prod composition layer
  modules/                  Reusable Terraform modules
app/
  src/main/java/            Java Lambda source
  src/test/java/            Unit tests
cicd/
  github-actions/           Copyable workflow examples
.github/workflows/          Runnable GitHub Actions examples
scripts/                    Build, deploy, rollback, Terraform helper scripts
docs/                       Design and operations notes
```

## Why These AWS Services

- API Gateway: managed REST entry point, request validation, throttling, access logs, and Lambda proxy integration.
- Lambda: serverless compute for a Java API without managing hosts.
- DynamoDB: low-latency NoSQL storage that fits serverless scaling and pay-per-request capacity.
- CloudWatch: logs, metrics, alarms, and operational visibility.
- KMS: customer-managed encryption key for production data protection.
- SQS DLQ: captures failed asynchronous Lambda events. For API requests, errors are returned synchronously, but the DLQ is still useful if async invokes are added later.

## Infrastructure Setup

Create Terraform Cloud workspaces:

- `serverless-java-dev`
- `serverless-java-prod`

Update `infra/environments/*/main.tf` with your Terraform Cloud organization.

Set Terraform Cloud variables:

- `artifact_s3_bucket`: artifact bucket for the initial Lambda object.
- `artifact_s3_key`: optional bootstrap artifact key.
- `alarm_sns_topic_arn`: optional alert topic.
- AWS credentials or OIDC federation variables.

Run:

```powershell
cd infra/environments/dev
terraform init
terraform plan
terraform apply
```

Repeat from `infra/environments/prod` for production.

## Application Build

```powershell
./scripts/build.ps1
```

The build creates `app/target/serverless-java-api.jar`, a shaded deployment artifact.

## Lambda Deployment

Terraform provisions the Lambda function once. Application releases are handled separately:

```powershell
./scripts/deploy-lambda.ps1 `
  -FunctionName serverless-java-api-dev `
  -ArtifactPath app/target/serverless-java-api.jar
```

The script publishes a new Lambda version and moves the `live` alias to it.

Rollback:

```powershell
./scripts/rollback-lambda.ps1 `
  -FunctionName serverless-java-api-dev `
  -Version 3
```

## API Examples

```bash
curl -X POST "$API_URL/items" \
  -H "Content-Type: application/json" \
  -d '{"name":"demo","description":"first item","status":"ACTIVE"}'

curl "$API_URL/items"
curl "$API_URL/items/{id}"

curl -X PUT "$API_URL/items/{id}" \
  -H "Content-Type: application/json" \
  -d '{"name":"updated","description":"changed","status":"ARCHIVED"}'

curl -X DELETE "$API_URL/items/{id}"
```

## Testing

```powershell
cd app
mvn test
```

Terraform checks:

```powershell
./scripts/terraform-plan.ps1 -Environment dev
```

## Production Recommendations

- Add API authentication with Cognito, Lambda authorizers, IAM auth, or a private API.
- Use AWS WAF on API Gateway for public internet APIs.
- Use GitHub OIDC instead of long-lived AWS access keys.
- Add canary or linear alias traffic shifting through CodeDeploy for safer releases.
- Add dashboards for latency, errors, throttles, DynamoDB consumed capacity, and p95 duration.
- Use DynamoDB TTL for disposable records if business rules allow it.
- Load test before selecting reserved concurrency and throttling values.
- Keep secrets in Secrets Manager or SSM Parameter Store, never in Terraform variables or source code.

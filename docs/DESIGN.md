# Design Notes

## Terraform Structure

The infrastructure is split into reusable modules:

- `kms`: customer-managed encryption key.
- `dynamodb`: encrypted item table with PITR.
- `iam`: Lambda execution role with scoped DynamoDB, KMS, log, and DLQ access.
- `lambda`: function, alias, log group, and DLQ.
- `api-gateway`: REST API resources, validation, Lambda proxy integration, throttling, and access logs.
- `cloudwatch`: alarms for Lambda and API health.

Environment folders compose those modules with environment-specific settings. This keeps shared infrastructure patterns consistent while allowing prod to use stricter defaults such as deletion protection, longer log retention, and higher throttles.

## DynamoDB Schema

Table: `${service}-${environment}-items`

Primary key:

- `pk`: static value `ITEM`
- `sk`: item id UUID

Attributes:

- `id`
- `name`
- `description`
- `status`
- `createdAt`
- `updatedAt`

GSI:

- `status-index`: supports future queries like "all ACTIVE items".

This is intentionally simple for learning. In a real multi-entity system, use entity-prefixed keys such as `USER#123` and `ITEM#456`, document access patterns first, and avoid relational-style ad hoc querying.

## API Design

Routes:

- `GET /items`
- `POST /items`
- `GET /items/{id}`
- `PUT /items/{id}`
- `DELETE /items/{id}`

API Gateway validates create and update payload shape before invoking Lambda. The Java handler still validates input because validation belongs at trust boundaries and should not rely on one upstream control.

## Versioning and Rollback

Terraform creates the Lambda and the `live` alias. Deployment scripts publish new versions and repoint the alias. API Gateway integrates with the alias, so rollback only changes alias routing and does not require Terraform.

The Lambda module ignores later changes to deployment artifact fields and alias version. That is deliberate: infrastructure applies should not undo an application release. Terraform owns the function shell, IAM, logging, encryption, and integration; the deployment pipeline owns code versions.

Alternative: AWS CodeDeploy can shift alias traffic gradually and automatically roll back on CloudWatch alarms. That is better for high-risk production releases but adds more moving parts for a learning project.

## Tradeoffs

REST API Gateway is more feature-rich than HTTP API and supports request models and validators. HTTP API is cheaper and lower latency, but has fewer REST API management features.

DynamoDB `PAY_PER_REQUEST` is simpler and usually cost-effective for spiky or unknown traffic. Provisioned capacity can be cheaper for predictable high-volume workloads.

Java Lambda gives strong typing and enterprise familiarity. Cold starts are higher than Node.js or Python. SnapStart can reduce Java cold starts, but is not enabled here to keep the example broadly understandable.

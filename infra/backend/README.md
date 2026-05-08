# Terraform Cloud Backend

This project uses the `cloud` block in each environment to store Terraform state in Terraform Cloud.

Terraform Cloud provides:

- Remote encrypted state storage
- State locking
- Run history and policy checks
- Workspace-level variables
- Separation between `dev` and `prod`

Create workspaces named:

- `serverless-java-dev`
- `serverless-java-prod`

Set workspace variables:

- `AWS_ACCESS_KEY_ID` or OIDC-backed credentials
- `AWS_SECRET_ACCESS_KEY` if not using OIDC
- `artifact_s3_bucket`
- Optional `alarm_sns_topic_arn`

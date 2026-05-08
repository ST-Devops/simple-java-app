# Operations Runbook

## Deploy

1. Build with `./scripts/build.ps1`.
2. Deploy with `./scripts/deploy-lambda.ps1`.
3. Smoke test `GET /items`.
4. Watch Lambda errors and API 5xx alarms.

## Rollback

1. Find the last known good Lambda version:

   ```bash
   aws lambda list-versions-by-function --function-name serverless-java-api-prod
   ```

2. Move the alias:

   ```powershell
   ./scripts/rollback-lambda.ps1 -FunctionName serverless-java-api-prod -Version <version>
   ```

## Incident Checks

- Lambda `Errors`, `Throttles`, and `Duration`
- API Gateway `5XXError`, `4XXError`, and latency
- DynamoDB throttles and successful request latency
- Recent deployment version behind the `live` alias

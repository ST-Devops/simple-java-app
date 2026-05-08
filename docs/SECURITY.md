# Security Best Practices

- Prefer GitHub Actions OIDC to assume an AWS deployment role.
- Keep Terraform Cloud variables sensitive when they contain secrets.
- Store application secrets in AWS Secrets Manager or SSM Parameter Store.
- Enable API authentication before public production use.
- Apply AWS WAF for internet-facing APIs.
- Use least privilege IAM policies and avoid `*` resources except where AWS service behavior requires broad access.
- Enable KMS key rotation.
- Use DynamoDB point-in-time recovery in production.
- Use deletion protection for production DynamoDB tables.
- Avoid logging request bodies if they may contain sensitive data.
- Add CloudTrail and AWS Config at the account level.

The sample app has no authentication so it remains easy to test. That is acceptable for learning, but not for a real public API.

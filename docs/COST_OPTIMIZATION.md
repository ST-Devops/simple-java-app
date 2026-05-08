# Cost Optimization

- DynamoDB `PAY_PER_REQUEST` avoids paying for idle capacity in dev and small production workloads.
- CloudWatch log retention is finite to prevent unbounded storage growth.
- Lambda reserved concurrency caps runaway cost and protects downstream systems.
- API Gateway throttling limits accidental or abusive traffic.
- Use smaller Lambda memory after profiling. More memory can reduce duration, so benchmark cost per request rather than memory alone.
- Use separate dev and prod environments so experiments do not affect production.
- Consider HTTP API instead of REST API if request models and advanced REST API features are not required.

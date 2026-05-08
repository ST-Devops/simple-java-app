output "api_endpoint" {
  description = "Invoke URL for the API stage."
  value       = "${aws_api_gateway_stage.this.invoke_url}"
}

output "api_name" {
  description = "API Gateway REST API name."
  value       = aws_api_gateway_rest_api.this.name
}

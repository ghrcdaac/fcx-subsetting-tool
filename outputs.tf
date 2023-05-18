output "api_endpoint" {
  description = "api endpoint to invoke subset_trigger_api."

  value = "${aws_api_gateway_stage.subset_trigger_api_stage.invoke_url}${aws_api_gateway_resource.subset_trigger_api_resource.path}"
}

output "api_key" {
  description = "key required to invoke subset_trigger_api endpoint."

  value = aws_api_gateway_api_key.subset_trigger_api_key.value
  sensitive = true
}

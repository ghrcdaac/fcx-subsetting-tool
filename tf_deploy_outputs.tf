output "SUBSET_TRIGGER_API" {
  description = "api endpoint to invoke subset_trigger_api. Refer postman collection."

  value = "${aws_api_gateway_stage.subset_trigger_api_stage.invoke_url}${aws_api_gateway_resource.subset_trigger_api_resource.path}"
}

output "SUBSETTING_TOOL_API_KEY" {
  description = "key required to invoke subset_trigger_api endpoint and subset_filenames_endpoint."

  value = aws_api_gateway_api_key.subset_trigger_api_key.value
  sensitive = true
}

output "WS_ENDPOINT" {
  description = "WS endpoint to start websocket connection. especially needed for Progressbar"

  value = "${aws_apigatewayv2_stage.subsetting_ws.invoke_url}"
}

output "SUBSET_FILENAMES_LIST_API" {
  description = "Api endpoint to get the list of subsets file names and their location. Refer postman collection."

  value = "${aws_api_gateway_stage.subset_trigger_api_stage.invoke_url}${aws_api_gateway_resource.subsets_filename.path}"
}

output "SUBSET_OUTPUT_BUCKET" {
  description = "Bucket to hold subsets-output"

  value = "${aws_s3_bucket.fcx_subset_output.id}"
}

output "SUBSET_CLOUDFRONT_URL" {
  description = "Cloudfront URL to subset output. Use cloudfront url + path to bucket object to get/download the subset objects"

  value = "https://${aws_cloudfront_distribution.fcx_subset_output_distribution.domain_name}"
}
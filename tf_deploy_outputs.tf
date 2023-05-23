output "api_endpoint" {
  description = "api endpoint to invoke subset_trigger_api."

  value = "${aws_api_gateway_stage.subset_trigger_api_stage.invoke_url}${aws_api_gateway_resource.subset_trigger_api_resource.path}"
}

output "api_key" {
  description = "key required to invoke subset_trigger_api endpoint."

  value = aws_api_gateway_api_key.subset_trigger_api_key.value
  sensitive = true
}

output "ws_endpoint" {
  description = "ws endpoint to start websocket connection."

  value = "${aws_apigatewayv2_stage.subsetting_ws.invoke_url}"
}

output "get_subset_filenames_api_endpoint" {
  description = "api endpoint to get the list of subsets file names and their location."

  value = "${aws_api_gateway_stage.subset_trigger_api_stage.invoke_url}${aws_api_gateway_resource.subsets_filename.path}"
}

output "subset_output_bucket" {
  description = "Bucket to hold subsets-output"

  value = "${aws_s3_bucket.fcx_subset_output.id}"
}

output "cloudfront_url_to_access_subset_output" {
  description = "Cloudfront URL to subset output. Use cloudfront url + path to bucket object to get/download the subset objects"

  value = "https://${aws_cloudfront_distribution.fcx_subset_output_distribution.id}.cloudfront.net"
}
### LAMBDA LAYER :: websocket-client

# name for lambda layer object
variable "lambda_layer_ws_client" {
  type    = string
  default = "websocket-client"
}

# zip the lambda code
data "archive_file" "lambda_ws_client" {
  type = "zip"
  source_dir  = "${path.module}/lambda_layers/websocket_client"
  output_path = "${path.module}/dist/${var.lambda_layer_ws_client}.zip"
}

# upload the zipped lambda code to the s3 bucket created
resource "aws_s3_object" "lambda_ws_client" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "${var.lambda_layer_ws_client}.zip"
  source = data.archive_file.lambda_ws_client.output_path
  etag = filemd5(data.archive_file.lambda_ws_client.output_path)
}

# create layer
resource "aws_lambda_layer_version" "ws_client" {
  layer_name = "fcx-${var.lambda_layer_ws_client}"
  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key = aws_s3_object.lambda_ws_client.key
  compatible_runtimes = ["python3.8"]
  source_code_hash = data.archive_file.lambda_ws_client.output_base64sha256
}
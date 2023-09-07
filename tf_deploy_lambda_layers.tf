### LAMBDA LAYER :: websocket-client

# name for lambda layer object
variable "lambda_layer_ws_client" {
  type    = string
  default = "websocket_client"
}

# upload the zipped lambda code to the s3 bucket created
resource "aws_s3_object" "lambda_ws_client" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "${var.lambda_layer_ws_client}.zip"
  source = "${path.module}/lambda_layers/${var.lambda_layer_ws_client}/${var.lambda_layer_ws_client}.zip"
  etag = filemd5("${path.module}/lambda_layers/${var.lambda_layer_ws_client}/${var.lambda_layer_ws_client}.zip")
}

# create layer
resource "aws_lambda_layer_version" "ws_client" {
  layer_name = "fcx-${var.lambda_layer_ws_client}"
  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key = aws_s3_object.lambda_ws_client.key
  compatible_runtimes = ["python3.8"]
  source_code_hash = "${filebase64sha256("${path.module}/lambda_layers/${var.lambda_layer_ws_client}/${var.lambda_layer_ws_client}.zip")}"
}




### LAMBDA LAYER :: marshmallow_json

# name for lambda layer object
variable "lambda_layer_marshmallow_json" {
  type    = string
  default = "marshmallow_json"
}

# upload the zipped lambda code to the s3 bucket created
resource "aws_s3_object" "lambda_marshmallow_json" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "${var.lambda_layer_marshmallow_json}.zip"
  source = "${path.module}/lambda_layers/${var.lambda_layer_marshmallow_json}/${var.lambda_layer_marshmallow_json}.zip"
  etag = filemd5("${path.module}/lambda_layers/${var.lambda_layer_marshmallow_json}/${var.lambda_layer_marshmallow_json}.zip")
}

# create layer
resource "aws_lambda_layer_version" "marshmallow_json" {
  layer_name = "fcx-${var.lambda_layer_marshmallow_json}"
  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key = aws_s3_object.lambda_marshmallow_json.key
  compatible_runtimes = ["python3.8"]
  source_code_hash = "${filebase64sha256("${path.module}/lambda_layers/${var.lambda_layer_marshmallow_json}/${var.lambda_layer_marshmallow_json}.zip")}"
}




### LAMBDA LAYER :: xarr_s3fs_h5ncf

# name for lambda layer object
variable "lambda_layer_xarr_s3fs_h5ncf" {
  type    = string
  default = "xarr_s3fs_h5ncf"
}

# upload the zipped lambda code to the s3 bucket created
resource "aws_s3_object" "lambda_xarr_s3fs_h5ncf" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "${var.lambda_layer_xarr_s3fs_h5ncf}.zip"
  source = "${path.module}/lambda_layers/${var.lambda_layer_xarr_s3fs_h5ncf}/${var.lambda_layer_xarr_s3fs_h5ncf}.zip"
  etag = filemd5("${path.module}/lambda_layers/${var.lambda_layer_xarr_s3fs_h5ncf}/${var.lambda_layer_xarr_s3fs_h5ncf}.zip")
}

# create layer
resource "aws_lambda_layer_version" "xarr_s3fs_h5ncf" {
  layer_name = "fcx-${var.lambda_layer_xarr_s3fs_h5ncf}"
  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key = aws_s3_object.lambda_xarr_s3fs_h5ncf.key
  compatible_runtimes = ["python3.8"]
  source_code_hash = "${filebase64sha256("${path.module}/lambda_layers/${var.lambda_layer_xarr_s3fs_h5ncf}/${var.lambda_layer_xarr_s3fs_h5ncf}.zip")}"
}




### LAMBDA LAYER :: xarr_scipy

# name for lambda layer object
variable "lambda_layer_xarr_scipy" {
  type    = string
  default = "xarr_scipy"
}

# upload the zipped lambda code to the s3 bucket created
resource "aws_s3_object" "lambda_xarr_scipy" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "${var.lambda_layer_xarr_scipy}.zip"
  source = "${path.module}/lambda_layers/${var.lambda_layer_xarr_scipy}/${var.lambda_layer_xarr_scipy}.zip"
  etag = filemd5("${path.module}/lambda_layers/${var.lambda_layer_xarr_scipy}/${var.lambda_layer_xarr_scipy}.zip")
}

# create layer
resource "aws_lambda_layer_version" "xarr_scipy" {
  layer_name = "fcx-${var.lambda_layer_xarr_scipy}"
  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key = aws_s3_object.lambda_xarr_scipy.key
  compatible_runtimes = ["python3.8"]
  source_code_hash = "${filebase64sha256("${path.module}/lambda_layers/${var.lambda_layer_xarr_scipy}/${var.lambda_layer_xarr_scipy}.zip")}"
}
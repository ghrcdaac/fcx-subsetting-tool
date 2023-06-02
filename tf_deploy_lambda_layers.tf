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




### LAMBDA LAYER :: marshmallow_json

# name for lambda layer object
variable "lambda_layer_marshmallow_json" {
  type    = string
  default = "marshmallow_json"
}

# zip the lambda code
data "archive_file" "lambda_marshmallow_json" {
  type = "zip"
  source_dir  = "${path.module}/lambda_layers/marshmallow_json"
  output_path = "${path.module}/dist/${var.lambda_layer_marshmallow_json}.zip"
}

# upload the zipped lambda code to the s3 bucket created
resource "aws_s3_object" "lambda_marshmallow_json" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "${var.lambda_layer_marshmallow_json}.zip"
  source = data.archive_file.lambda_marshmallow_json.output_path
  etag = filemd5(data.archive_file.lambda_marshmallow_json.output_path)
}

# create layer
resource "aws_lambda_layer_version" "marshmallow_json" {
  layer_name = "fcx-${var.lambda_layer_marshmallow_json}"
  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key = aws_s3_object.lambda_marshmallow_json.key
  compatible_runtimes = ["python3.8"]
  source_code_hash = data.archive_file.lambda_marshmallow_json.output_base64sha256
}




### LAMBDA LAYER :: xarr_s3fs_h5ncf

# name for lambda layer object
variable "lambda_layer_xarr_s3fs_h5ncf" {
  type    = string
  default = "xarr_s3fs_h5ncf"
}

# zip the lambda code
data "archive_file" "lambda_xarr_s3fs_h5ncf" {
  type = "zip"
  source_dir  = "${path.module}/lambda_layers/xarr_s3fs_h5ncf"
  output_path = "${path.module}/dist/${var.lambda_layer_xarr_s3fs_h5ncf}.zip"
}

# upload the zipped lambda code to the s3 bucket created
resource "aws_s3_object" "lambda_xarr_s3fs_h5ncf" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "${var.lambda_layer_xarr_s3fs_h5ncf}.zip"
  source = data.archive_file.lambda_xarr_s3fs_h5ncf.output_path
  etag = filemd5(data.archive_file.lambda_xarr_s3fs_h5ncf.output_path)
}

# create layer
resource "aws_lambda_layer_version" "xarr_s3fs_h5ncf" {
  layer_name = "fcx-${var.lambda_layer_xarr_s3fs_h5ncf}"
  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key = aws_s3_object.lambda_xarr_s3fs_h5ncf.key
  compatible_runtimes = ["python3.8"]
  source_code_hash = data.archive_file.lambda_xarr_s3fs_h5ncf.output_base64sha256
}




# ### LAMBDA LAYER :: xarr_scipy

# # name for lambda layer object
# variable "lambda_layer_xarr_scipy" {
#   type    = string
#   default = "xarr_scipy"
# }

# # zip the lambda code
# data "archive_file" "lambda_xarr_scipy" {
#   type = "zip"
#   source_dir  = "${path.module}/lambda_layers/xarr_scipy"
#   output_path = "${path.module}/dist/${var.lambda_layer_xarr_scipy}.zip"
# }

# # upload the zipped lambda code to the s3 bucket created
# resource "aws_s3_object" "lambda_xarr_scipy" {
#   bucket = aws_s3_bucket.lambda_bucket.id
#   key    = "${var.lambda_layer_xarr_scipy}.zip"
#   source = data.archive_file.lambda_xarr_scipy.output_path
#   etag = filemd5(data.archive_file.lambda_xarr_scipy.output_path)
# }

# # create layer
# resource "aws_lambda_layer_version" "xarr_scipy" {
#   layer_name = "fcx-${var.lambda_layer_xarr_scipy}"
#   s3_bucket = aws_s3_bucket.lambda_bucket.id
#   s3_key = aws_s3_object.lambda_xarr_scipy.key
#   compatible_runtimes = ["python3.8"]
#   source_code_hash = data.archive_file.lambda_xarr_scipy.output_base64sha256
# }
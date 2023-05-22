########## COMMON DECLARATIONS ##########

## 1.1. CREATE ROLE AND ATTACH IAM ROLE POLICY ##

resource "aws_iam_role" "subsets_direct_download_lambdas_subsetting_tool" {
  name = "subsets_direct_download_subsetting_tool"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "subsets_s3_access_policy" {
  name        = "s3_access"
  path        = "/"
  description = "Policy that allows read and write access to s3"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["s3:*"]
        Effect   = "Allow"
        Resource = "*" # TODO: change the resource to specific arn later
      },
    ]
  })
}

# attach IAM role to the lambda function

resource "aws_iam_role_policy_attachment" "subsets_lambda_policy_basic" {
  role       = aws_iam_role.subsets_direct_download_lambdas_subsetting_tool.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "subsets_s3_access_policy" {
  role       = aws_iam_role.subsets_direct_download_lambdas_subsetting_tool.name
  policy_arn = aws_iam_policy.subsets_s3_access_policy.arn
}




########## LAMBDA SPECIFIC DECLARATIONS ##########

## 2.1. CREATE BUCKET ##

# already exists: aws_s3_bucket.lambda_bucket


########## LAMBDA SPECIFIC DECLARATIONS ##########


## 2.2. ZIP AND UPLOAD THE WS LAMBDA WORKER CODES ##

# ZIP

# zip onconnect
data "archive_file" "get_subsets_filename" {
  type = "zip"
  source_dir  = "${path.module}/subsets_direct_download_lambdas/get_subsets_filename"
  output_path = "${path.module}/dist/get_subsets_filename.zip"
}


# UPLOAD

# upload ws_on_disconnect_worker zip
resource "aws_s3_object" "get_subsets_filename" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "get_subsets_filename.zip"
  source = data.archive_file.get_subsets_filename.output_path

  etag = filemd5(data.archive_file.get_subsets_filename.output_path)
}



## 2.3. CREATE LAMBDA FUNCTION ##

# Lambda get_subsets_filename worker
resource "aws_lambda_function" "get_subsets_filename_worker" {
  function_name = "fcx-subsetting-get_subsets_filename_worker"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.get_subsets_filename.key

  runtime = "python3.8"
  handler = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.get_subsets_filename.output_base64sha256

  role = aws_iam_role.subsets_direct_download_lambdas_subsetting_tool.arn

  environment {
    variables = {
      BUCKET_AWS_REGION = var.BUCKET_AWS_REGION
      SOURCE_BUCKET_NAME = var.DESTINATION_BUCKET_NAME
      CLOUD_FRONT_URL = var.CLOUD_FRONT_URL
    }
  }
}



## 2.4. CREATE CLOUDWATCH LOG GROUP ##

# log ws_on_connect_worker
resource "aws_cloudwatch_log_group" "get_subsets_filename_worker" {
  name = "/aws/lambda/${aws_lambda_function.get_subsets_filename_worker.function_name}"

  retention_in_days = 3
}




## 3. REST API GATEWAY

# API Gateway name
# Resuse from aws_api_gateway_rest_api.subset_trigger_api


## create resource
resource "aws_api_gateway_resource" "subsets_filename" {
  path_part   = "subset_files"
  parent_id   = aws_api_gateway_rest_api.subset_trigger_api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.subset_trigger_api.id
}

## create method
resource "aws_api_gateway_method" "subsets_filename" {
  rest_api_id   = aws_api_gateway_rest_api.subset_trigger_api.id
  resource_id   = aws_api_gateway_resource.subsets_filename.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = true # need api key
}

## INTEGRATION OF GATEWAY AND LAMBDA TRIGGER

resource "aws_api_gateway_integration" "subsets_filename_api_integration" {
  rest_api_id             = aws_api_gateway_rest_api.subset_trigger_api.id
  resource_id             = aws_api_gateway_resource.subsets_filename.id
  http_method             = aws_api_gateway_method.subsets_filename.http_method
  integration_http_method = aws_api_gateway_method.subsets_filename.http_method
  type                    = "AWS"
  uri                     = aws_lambda_function.get_subsets_filename_worker.invoke_arn
}

## PERMISSIONS to trigger lamba from api gateway
resource "aws_lambda_permission" "subsets_filename_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_subsets_filename_worker.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.accountId}:${aws_api_gateway_rest_api.subset_trigger_api.id}/*/${aws_api_gateway_method.subsets_filename.http_method}${aws_api_gateway_resource.subsets_filename.path}"
}

## SET RESPONSE HANDLERS FOR API-GATEWAY

# Success response handler
resource "aws_api_gateway_method_response" "subsets_filename_api_response_200" {
  rest_api_id = aws_api_gateway_rest_api.subset_trigger_api.id
  resource_id = aws_api_gateway_resource.subsets_filename.id
  http_method = aws_api_gateway_method.subsets_filename.http_method
  status_code = "200"
  depends_on = [ aws_api_gateway_rest_api.subset_trigger_api ]
}

# Integration response handler
resource "aws_api_gateway_integration_response" "subsets_filename_api_IntegrationResponse" {
  rest_api_id = aws_api_gateway_rest_api.subset_trigger_api.id
  resource_id = aws_api_gateway_resource.subsets_filename.id
  http_method = aws_api_gateway_method.subsets_filename.http_method
  status_code = aws_api_gateway_method_response.subset_trigger_api_response_200.status_code
  depends_on = [ aws_api_gateway_rest_api.subset_trigger_api ]
}



## Create deployment for subsets_filename_api
# already deployed using: resource `aws_api_gateway_deployment.subset_trigger_api_deployment`



## create stage for the subsets_filename_api
# already deployed using: resource "aws_api_gateway_stage.subset_trigger_api_stage"



## to enable api key and its usage plan for subsets_filename_api

# create api key
# reuse the one created using resource "aws_api_gateway_api_key.subsets_filename_api_key"
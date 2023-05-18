########## COMMON DECLARATIONS ##########

## 0. CONFIGURE AWS PROVIDER ##
provider "aws" {
  shared_credentials_files = [var.aws_creds_path]
  region = var.aws_region
}


## 1.1. CREATE ROLE AND ATTACH IAM ROLE POLICY ##

resource "aws_iam_role" "websocket_lambdas_subsetting_tool" {
  name = "websocket_lambdas_subsetting_tool"

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

resource "aws_iam_policy" "dynamodb_access_policy" {
  name        = "dynamoDB_Access"
  path        = "/"
  description = "Policy that allows read and write access to dynamodb"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
           "dynamodb:GetItem",
            "dynamodb:DeleteItem",
            "dynamodb:PutItem",
            "dynamodb:Scan",
            "dynamodb:Query",
            "dynamodb:UpdateItem",
            "dynamodb:BatchWriteItem",
            "dynamodb:BatchGetItem",
            "dynamodb:DescribeTable",
            "dynamodb:ConditionCheckItem"
        ]
        Effect   = "Allow"
        Resource = "*" # TODO: change the resource to specific arn later
      },
    ]
  })
}

# attach IAM role to the lambda function

resource "aws_iam_role_policy_attachment" "lambda_policy_basic" {
  role       = aws_iam_role.websocket_lambdas_subsetting_tool.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_access_dynamodb" {
  role       = aws_iam_role.websocket_lambdas_subsetting_tool.name
  policy_arn = aws_iam_policy.dynamodb_access_policy.arn
}



## 2.1. CREATE BUCKET ##

# already exists: aws_s3_bucket.lambda_bucket


########## LAMBDA SPECIFIC DECLARATIONS ##########


## 2.2. ZIP AND UPLOAD THE WS LAMBDA WORKER CODES ##

# ZIP

# zip onconnect
data "archive_file" "ws_on_connect_worker" {
  type = "zip"
  source_dir  = "${path.module}/websocket_lambdas/onconnect"
  output_path = "${path.module}/dist/ws_on_connect_worker.zip"
}

# zip afterconnect
data "archive_file" "ws_after_connect_worker" {
  type = "zip"
  source_dir  = "${path.module}/websocket_lambdas/afterconnect"
  output_path = "${path.module}/dist/ws_after_connect_worker.zip"
}

# zip sendmessage
data "archive_file" "ws_on_send_message_worker" {
  type = "zip"
  source_dir  = "${path.module}/websocket_lambdas/sendmessage"
  output_path = "${path.module}/dist/ws_on_send_message_worker.zip"
}

# zip ws_on_disconnect_worker
data "archive_file" "ws_on_disconnect_worker" {
  type = "zip"
  source_dir  = "${path.module}/websocket_lambdas/ondisconnect"
  output_path = "${path.module}/dist/ws_on_disconnect_worker.zip"
}


# UPLOAD

# upload ws_on_connect_worker zip
resource "aws_s3_object" "ws_on_connect_worker" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "ws_on_connect_worker.zip"
  source = data.archive_file.ws_on_connect_worker.output_path

  etag = filemd5(data.archive_file.ws_on_connect_worker.output_path)
}

# upload ws_after_connect_worker zip
resource "aws_s3_object" "ws_after_connect_worker" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "ws_after_connect_worker.zip"
  source = data.archive_file.ws_after_connect_worker.output_path

  etag = filemd5(data.archive_file.ws_after_connect_worker.output_path)
}

# upload ws_on_send_message_worker zip
resource "aws_s3_object" "ws_on_send_message_worker" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "ws_on_send_message_worker.zip"
  source = data.archive_file.ws_on_send_message_worker.output_path

  etag = filemd5(data.archive_file.ws_on_send_message_worker.output_path)
}

# upload ws_on_disconnect_worker zip
resource "aws_s3_object" "ws_on_disconnect_worker" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "ws_on_disconnect_worker.zip"
  source = data.archive_file.ws_on_disconnect_worker.output_path

  etag = filemd5(data.archive_file.ws_on_disconnect_worker.output_path)
}



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

#   runtime =  "nodejs14.x"
#   handler = "app.handler"

#   source_code_hash = data.archive_file.ws_on_connect_worker.output_base64sha256

#   role = aws_iam_role.websocket_lambdas_subsetting_tool.arn

#   environment {
#     variables = {
#       TABLE_NAME = var.WS_TABLE_NAME
#     }
#   }

  runtime = "python3.8"
  handler = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.get_subsets_filename.output_base64sha256

  role = aws_iam_role.subsets_direct_download_lambdas_subsetting_tool.arn

  environment {
    variables = {
      BUCKET_AWS_REGION = var.BUCKET_AWS_REGION
      SOURCE_BUCKET_NAME = var.SOURCE_BUCKET_NAME
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

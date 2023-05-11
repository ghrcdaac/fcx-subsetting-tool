## 0. CONFIGURE AWS PROVIDER ##
provider "aws" {
  shared_credentials_files = [var.aws_creds_path]
  region = var.aws_region
}



## 1.1. CREATE BUCKET ##
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "fcx-subsetting-tool-terraform"
}


## 1.2. ZIP AND UPLOAD THE LAMBDA CODES ##

# zip FEGS
data "archive_file" "lambda_FEGS_subset_worker" {
  type = "zip"

  source_dir  = "${path.module}/FEGS_subsetting"
  output_path = "${path.module}/dist/FEGS_subsetting.zip"
}

# upload FEGS zip
resource "aws_s3_object" "lambda_FEGS_subset_worker" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "FEGS_subsetting.zip"
  source = data.archive_file.lambda_FEGS_subset_worker.output_path

  etag = filemd5(data.archive_file.lambda_FEGS_subset_worker.output_path)
}


## 1.3. CREATE LAMBDA FUNCTION ##

# Lambda FEGS
resource "aws_lambda_function" "FEGS_Subset_Worker" {
  function_name = "fcx-subsetting-FEGS-worker"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_FEGS_subset_worker.key

  runtime = "python3.8"
  handler = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.lambda_FEGS_subset_worker.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
  ## TODO: Add more roles

  ## TODO: Create layers first, then use their arn.
  layers = ["arn:aws:lambda:us-east-1:307493436926:layer:XarrS3fsH5ncf:1", "arn:aws:lambda:us-east-1:307493436926:layer:websocket-client:2"]

  environment {
    variables = {
      BUCKET_AWS_REGION = var.BUCKET_AWS_REGION
      SOURCE_BUCKET_NAME = var.SOURCE_BUCKET_NAME
      WS_URL = var.WS_URL
    }
  }
}


## 1.4. CREATE CLOUDWATCH LOG GROUP ##
resource "aws_cloudwatch_log_group" "FEGS_Subset_Worker" {
  name = "/aws/lambda/${aws_lambda_function.FEGS_Subset_Worker.function_name}"

  retention_in_days = 5
}



## 2.1. CREATE AND ATTACH IAM ROLE POLICY ##

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda_subsetting_workers"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
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

# attach IAM role to the lambda function

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
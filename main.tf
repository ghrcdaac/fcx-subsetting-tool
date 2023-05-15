########## COMMON DECLARATIONS ##########

## 0. CONFIGURE AWS PROVIDER ##
provider "aws" {
  shared_credentials_files = [var.aws_creds_path]
  region = var.aws_region
}


## 1.1. CREATE ROLE AND ATTACH IAM ROLE POLICY ##

# FOR WORKERS
resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda_subsetting_workers"

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

data "aws_iam_policy_document" "lamda_s3_access" {
  statement {
    effect = "Allow"
    actions = [
                "s3:*",
                "s3-object-lambda:*"
              ]
    resources = ["*"]
    # TODO: make resource specific
  }
}

resource "aws_iam_policy" "lamda_s3_access" {
  name        = "lambda_s3_access"
  path        = "/"
  description = "IAM policy for rd wr access to s3 data from a lambda"
  policy      = data.aws_iam_policy_document.lamda_s3_access.json
}

# attach IAM role to the lambda function

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_s3_access" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lamda_s3_access.arn
}


# FOR TRIGGER
resource "aws_iam_role" "lambda_trigger" {
  name = "serverless_lambda_subsetting_trigger"

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

data "aws_iam_policy_document" "lambda_invoke_lambda" {
  statement {
    effect = "Allow"
    actions = ["lambda:InvokeFunction"]
    resources = ["*"]
    # TODO: make resource specific
  }
}

resource "aws_iam_policy" "lambda_invoke_lambda" {
  name        = "lambda_invoke_lambda"
  path        = "/"
  description = "IAM policy that allows a lambda to invoke another lambda"
  policy      = data.aws_iam_policy_document.lambda_invoke_lambda.json
}

# attach IAM role to the lambda function

resource "aws_iam_role_policy_attachment" "lambda_policy_basic" {
  role       = aws_iam_role.lambda_trigger.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_invoke_lambda" {
  role       = aws_iam_role.lambda_trigger.name
  policy_arn = aws_iam_policy.lambda_invoke_lambda.arn
}


## 2.1. CREATE BUCKET ##

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "fcx-subsetting-tool-terraform"
}


########## LAMBDA SPECIFIC DECLARATIONS ##########

## 2.2. ZIP AND UPLOAD THE LAMBDA CODES ##

# ZIP
# zip CRS
data "archive_file" "lambda_CRS_subset_worker" {
  type = "zip"

  source_dir  = "${path.module}/CRS_subsetting"
  output_path = "${path.module}/dist/CRS_subsetting.zip"
}

# zip FEGS
data "archive_file" "lambda_FEGS_subset_worker" {
  type = "zip"

  source_dir  = "${path.module}/FEGS_subsetting"
  output_path = "${path.module}/dist/FEGS_subsetting.zip"
}

# zip GLM
data "archive_file" "lambda_GLM_subset_worker" {
  type = "zip"

  source_dir  = "${path.module}/GLM_subsetting"
  output_path = "${path.module}/dist/GLM_subsetting.zip"
}

# zip LIP
data "archive_file" "lambda_LIP_subset_worker" {
  type = "zip"

  source_dir  = "${path.module}/LIP_subsetting"
  output_path = "${path.module}/dist/LIP_subsetting.zip"
}

# zip LIS
data "archive_file" "lambda_LIS_subset_worker" {
  type = "zip"

  source_dir  = "${path.module}/LIS_subsetting"
  output_path = "${path.module}/dist/LIS_subsetting.zip"
}

# zip LMA
data "archive_file" "lambda_LMA_subset_worker" {
  type = "zip"

  source_dir  = "${path.module}/LMA_subsetting"
  output_path = "${path.module}/dist/LMA_subsetting.zip"
}

# zip TRIGGER
data "archive_file" "lambda_subset_trigger" {
  type = "zip"

  source_dir  = "${path.module}/trigger_subsetting"
  output_path = "${path.module}/dist/trigger_subsetting.zip"
}

# UPLOAD
# upload CRS zip
resource "aws_s3_object" "lambda_CRS_subset_worker" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "CRS_subsetting.zip"
  source = data.archive_file.lambda_CRS_subset_worker.output_path

  etag = filemd5(data.archive_file.lambda_CRS_subset_worker.output_path)
}

# upload FEGS zip
resource "aws_s3_object" "lambda_FEGS_subset_worker" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "FEGS_subsetting.zip"
  source = data.archive_file.lambda_FEGS_subset_worker.output_path

  etag = filemd5(data.archive_file.lambda_FEGS_subset_worker.output_path)
}

# upload GLM zip
resource "aws_s3_object" "lambda_GLM_subset_worker" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "GLM_subsetting.zip"
  source = data.archive_file.lambda_GLM_subset_worker.output_path

  etag = filemd5(data.archive_file.lambda_GLM_subset_worker.output_path)
}

# upload LIP zip
resource "aws_s3_object" "lambda_LIP_subset_worker" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "LIP_subsetting.zip"
  source = data.archive_file.lambda_LIP_subset_worker.output_path

  etag = filemd5(data.archive_file.lambda_LIP_subset_worker.output_path)
}

# upload LIS zip
resource "aws_s3_object" "lambda_LIS_subset_worker" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "LIS_subsetting.zip"
  source = data.archive_file.lambda_LIS_subset_worker.output_path

  etag = filemd5(data.archive_file.lambda_LIS_subset_worker.output_path)
}

# upload LMA zip
resource "aws_s3_object" "lambda_LMA_subset_worker" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "LMA_subsetting.zip"
  source = data.archive_file.lambda_LMA_subset_worker.output_path

  etag = filemd5(data.archive_file.lambda_LMA_subset_worker.output_path)
}

# upload TRIGGER zip
resource "aws_s3_object" "lambda_subset_trigger" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "trigger_subsetting.zip"
  source = data.archive_file.lambda_subset_trigger.output_path

  etag = filemd5(data.archive_file.lambda_subset_trigger.output_path)
}



## 2.3. CREATE LAMBDA FUNCTION ##

# Lambda CRS
resource "aws_lambda_function" "CRS_Subset_Worker" {
  function_name = "fcx-subsetting-CRS-worker"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_CRS_subset_worker.key

  runtime = "python3.8"
  handler = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.lambda_CRS_subset_worker.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  ## TODO: Create layers first, then use their arn.
  layers = [var.XarrScipy, var.websocket-client]

  memory_size = var.lambda_execution_memory
  timeout = var.lambda_execution_timeout

  ephemeral_storage {
    size = var.lambda_execution_ephimeral_storage
  }

  environment {
    variables = {
      BUCKET_AWS_REGION = var.BUCKET_AWS_REGION
      SOURCE_BUCKET_NAME = var.SOURCE_BUCKET_NAME
      WS_URL = var.WS_URL
    }
  }
}

# Lambda FEGS
resource "aws_lambda_function" "FEGS_Subset_Worker" {
  function_name = "fcx-subsetting-FEGS-worker"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_FEGS_subset_worker.key

  runtime = "python3.8"
  handler = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.lambda_FEGS_subset_worker.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  ## TODO: Create layers first, then use their arn.
  layers = [var.XarrS3fsH5ncf, var.websocket-client]

  memory_size = var.lambda_execution_memory
  timeout = var.lambda_execution_timeout

  ephemeral_storage {
    size = var.lambda_execution_ephimeral_storage
  }

  environment {
    variables = {
      BUCKET_AWS_REGION = var.BUCKET_AWS_REGION
      SOURCE_BUCKET_NAME = var.SOURCE_BUCKET_NAME
      WS_URL = var.WS_URL
    }
  }
}

# Lambda GLM
resource "aws_lambda_function" "GLM_Subset_Worker" {
  function_name = "fcx-subsetting-GLM-worker"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_GLM_subset_worker.key

  runtime = "python3.8"
  handler = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.lambda_GLM_subset_worker.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  ## TODO: Create layers first, then use their arn.
  layers = [var.XarrS3fsH5ncf, var.websocket-client]

  memory_size = var.lambda_execution_memory
  timeout = var.lambda_execution_timeout

  ephemeral_storage {
    size = var.lambda_execution_ephimeral_storage
  }

  environment {
    variables = {
      BUCKET_AWS_REGION = var.BUCKET_AWS_REGION
      SOURCE_BUCKET_NAME = var.SOURCE_BUCKET_NAME
      WS_URL = var.WS_URL
    }
  }
}

# Lambda LIP
resource "aws_lambda_function" "LIP_Subset_Worker" {
  function_name = "fcx-subsetting-LIP-worker"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_LIP_subset_worker.key

  runtime = "python3.8"
  handler = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.lambda_LIP_subset_worker.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  ## TODO: Create layers first, then use their arn.
  layers = [var.XarrS3fsH5ncf, var.websocket-client]

  memory_size = var.lambda_execution_memory
  timeout = var.lambda_execution_timeout

  ephemeral_storage {
    size = var.lambda_execution_ephimeral_storage
  }

  environment {
    variables = {
      BUCKET_AWS_REGION = var.BUCKET_AWS_REGION
      SOURCE_BUCKET_NAME = var.SOURCE_BUCKET_NAME
      WS_URL = var.WS_URL
    }
  }
}

# Lambda LIS
resource "aws_lambda_function" "LIS_Subset_Worker" {
  function_name = "fcx-subsetting-LIS-worker"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_LIS_subset_worker.key

  runtime = "python3.8"
  handler = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.lambda_LIS_subset_worker.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  ## TODO: Create layers first, then use their arn.
  layers = [var.XarrS3fsH5ncf, var.websocket-client]

  memory_size = var.lambda_execution_memory
  timeout = var.lambda_execution_timeout

  ephemeral_storage {
    size = var.lambda_execution_ephimeral_storage
  }

  environment {
    variables = {
      BUCKET_AWS_REGION = var.BUCKET_AWS_REGION
      SOURCE_BUCKET_NAME = var.SOURCE_BUCKET_NAME
      WS_URL = var.WS_URL
    }
  }
}

# Lambda LMA
resource "aws_lambda_function" "LMA_Subset_Worker" {
  function_name = "fcx-subsetting-LMA-worker"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_LMA_subset_worker.key

  runtime = "python3.8"
  handler = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.lambda_LMA_subset_worker.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  ## TODO: Create layers first, then use their arn.
  layers = [var.XarrS3fsH5ncf, var.websocket-client]

  memory_size = var.lambda_execution_memory
  timeout = var.lambda_execution_timeout

  ephemeral_storage {
    size = var.lambda_execution_ephimeral_storage
  }

  environment {
    variables = {
      BUCKET_AWS_REGION = var.BUCKET_AWS_REGION
      SOURCE_BUCKET_NAME = var.SOURCE_BUCKET_NAME
      WS_URL = var.WS_URL
    }
  }
}

# Lambda TRIGGER
resource "aws_lambda_function" "subset_trigger" {
  function_name = "fcx-subsetting-trigger"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_subset_trigger.key

  runtime = "python3.8"
  handler = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.lambda_subset_trigger.output_base64sha256

  role = aws_iam_role.lambda_trigger.arn

  ## TODO: Create layers first, then use their arn.
  layers = [var.fcx-sst-marshmallow_json]
}



## 2.4. CREATE CLOUDWATCH LOG GROUP ##

# log CRS worker
resource "aws_cloudwatch_log_group" "CRS_Subset_Worker" {
  name = "/aws/lambda/${aws_lambda_function.CRS_Subset_Worker.function_name}"

  retention_in_days = 5
}

# log FEGS worker
resource "aws_cloudwatch_log_group" "FEGS_Subset_Worker" {
  name = "/aws/lambda/${aws_lambda_function.FEGS_Subset_Worker.function_name}"

  retention_in_days = 5
}

# log GLM worker
resource "aws_cloudwatch_log_group" "GLM_Subset_Worker" {
  name = "/aws/lambda/${aws_lambda_function.GLM_Subset_Worker.function_name}"

  retention_in_days = 5
}

# log LIP worker
resource "aws_cloudwatch_log_group" "LIP_Subset_Worker" {
  name = "/aws/lambda/${aws_lambda_function.LIP_Subset_Worker.function_name}"

  retention_in_days = 5
}

# log LIS worker
resource "aws_cloudwatch_log_group" "LIS_Subset_Worker" {
  name = "/aws/lambda/${aws_lambda_function.LIS_Subset_Worker.function_name}"

  retention_in_days = 5
}

# log LMA worker
resource "aws_cloudwatch_log_group" "LMA_Subset_Worker" {
  name = "/aws/lambda/${aws_lambda_function.LMA_Subset_Worker.function_name}"

  retention_in_days = 5
}

# log trigger main
resource "aws_cloudwatch_log_group" "Subset_Trigger" {
  name = "/aws/lambda/${aws_lambda_function.subset_trigger.function_name}"

  retention_in_days = 5
}



## REST API GATEWAY

resource "aws_api_gateway_rest_api" "subset_trigger_api" {
  name = "fcx-subsetting-trigger-api"
}

resource "aws_api_gateway_resource" "resource" {
  path_part = aws_lambda_function.subset_trigger.function_name #/name
  parent_id   = aws_api_gateway_rest_api.subset_trigger_api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.subset_trigger_api.id
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.subset_trigger_api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.subset_trigger_api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.subset_trigger.invoke_arn
}
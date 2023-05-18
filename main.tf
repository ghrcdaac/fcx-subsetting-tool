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

# API Gateway name
resource "aws_api_gateway_rest_api" "subset_trigger_api" {
  name = "fcx-subsetting-trigger-api"
}


## create resource
resource "aws_api_gateway_resource" "subset_trigger_api_resource" {
  path_part   = aws_lambda_function.subset_trigger.function_name
  parent_id   = aws_api_gateway_rest_api.subset_trigger_api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.subset_trigger_api.id
}

## create method
resource "aws_api_gateway_method" "subset_trigger_api_method" {
  rest_api_id   = aws_api_gateway_rest_api.subset_trigger_api.id
  resource_id   = aws_api_gateway_resource.subset_trigger_api_resource.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = true # need api key
}

## INTEGRATION OF GATEWAY AND LAMBDA TRIGGER

resource "aws_api_gateway_integration" "subset_trigger_api_integration" {
  rest_api_id             = aws_api_gateway_rest_api.subset_trigger_api.id
  resource_id             = aws_api_gateway_resource.subset_trigger_api_resource.id
  http_method             = aws_api_gateway_method.subset_trigger_api_method.http_method
  integration_http_method = aws_api_gateway_method.subset_trigger_api_method.http_method
  type                    = "AWS"
  uri                     = aws_lambda_function.subset_trigger.invoke_arn
}

## PERMISSIONS to trigger lamba from api gateway
resource "aws_lambda_permission" "subset_trigger_api_gateway_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.subset_trigger.function_name
  principal     = "apigateway.amazonaws.com"
  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.accountId}:${aws_api_gateway_rest_api.subset_trigger_api.id}/*/${aws_api_gateway_method.subset_trigger_api_method.http_method}${aws_api_gateway_resource.subset_trigger_api_resource.path}"
}

## SET RESPONSE HANDLERS FOR API-GATEWAY

# Success response handler
resource "aws_api_gateway_method_response" "subset_trigger_api_response_200" {
  rest_api_id = aws_api_gateway_rest_api.subset_trigger_api.id
  resource_id = aws_api_gateway_resource.subset_trigger_api_resource.id
  http_method = aws_api_gateway_method.subset_trigger_api_method.http_method
  status_code = "200"
}

# Integration response handler
resource "aws_api_gateway_integration_response" "subset_trigger_api_IntegrationResponse" {
  rest_api_id = aws_api_gateway_rest_api.subset_trigger_api.id
  resource_id = aws_api_gateway_resource.subset_trigger_api_resource.id
  http_method = aws_api_gateway_method.subset_trigger_api_method.http_method
  status_code = aws_api_gateway_method_response.subset_trigger_api_response_200.status_code
}

## Create deployment for subset_trigger_api
resource "aws_api_gateway_deployment" "subset_trigger_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.subset_trigger_api.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.subset_trigger_api_resource.id,
      aws_api_gateway_method.subset_trigger_api_method.id,
      aws_api_gateway_integration.subset_trigger_api_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

## create stage for the subset_trigger_api
resource "aws_api_gateway_stage" "subset_trigger_api_stage" {
  deployment_id = aws_api_gateway_deployment.subset_trigger_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.subset_trigger_api.id
  stage_name    = var.stage_name
  depends_on = [aws_cloudwatch_log_group.subset_trigger_api]
}


### to enable api key and its usage plan for subset_trigger_api

# create api key
resource "aws_api_gateway_api_key" "subset_trigger_api_key" {
  name = "subset_trigger_api-key"
}

# create usage plans
resource "aws_api_gateway_usage_plan" "subset_trigger_api_usagePlan" {
  name         = "subset_trigger_api-usagePlan"
  description  = "Usage plan for the subset_trigger_api key"

  api_stages {
    api_id = aws_api_gateway_rest_api.subset_trigger_api.id
    stage  = aws_api_gateway_stage.subset_trigger_api_stage.stage_name
  }

  quota_settings {
    limit  = 1000
    offset = 1
    period = "WEEK"
  }

  throttle_settings {
    burst_limit = 100
    rate_limit  = 1000
  }
}

resource "aws_api_gateway_usage_plan_key" "usagePlan_with_key" {
  key_id        = aws_api_gateway_api_key.subset_trigger_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.subset_trigger_api_usagePlan.id
}


## add and enable cloudwatch logs for subset_trigger_api

resource "aws_cloudwatch_log_group" "subset_trigger_api" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.subset_trigger_api.id}/${var.stage_name}"
  retention_in_days = 3
}

resource "aws_api_gateway_method_settings" "subset_trigger_api_method" {
  rest_api_id = aws_api_gateway_rest_api.subset_trigger_api.id
  stage_name  = aws_api_gateway_stage.subset_trigger_api_stage.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}
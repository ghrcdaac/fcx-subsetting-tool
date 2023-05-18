########## COMMON DECLARATIONS ##########

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

resource "aws_iam_role_policy_attachment" "ws_lambda_policy_basic" {
  role       = aws_iam_role.websocket_lambdas_subsetting_tool.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "ws_lambda_access_dynamodb" {
  role       = aws_iam_role.websocket_lambdas_subsetting_tool.name
  policy_arn = aws_iam_policy.dynamodb_access_policy.arn
}


########## LAMBDA SPECIFIC DECLARATIONS ##########

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



## 2.3. CREATE LAMBDA FUNCTION ##

# Lambda ws_on_connect_worker
resource "aws_lambda_function" "ws_on_connect_worker" {
  function_name = "fcx-subsetting-ws_on_connect_worker"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.ws_on_connect_worker.key

  runtime =  "nodejs14.x"
  handler = "app.handler"

  source_code_hash = data.archive_file.ws_on_connect_worker.output_base64sha256

  role = aws_iam_role.websocket_lambdas_subsetting_tool.arn

  environment {
    variables = {
      TABLE_NAME = var.TABLE_NAME
    }
  }
}

# Lambda ws_after_connect_worker
resource "aws_lambda_function" "ws_after_connect_worker" {
  function_name = "fcx-subsetting-ws_after_connect_worker"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.ws_after_connect_worker.key

  runtime =  "nodejs14.x"
  handler = "app.handler"

  source_code_hash = data.archive_file.ws_after_connect_worker.output_base64sha256

  role = aws_iam_role.websocket_lambdas_subsetting_tool.arn

  environment {
    variables = {
      TABLE_NAME = var.TABLE_NAME
    }
  }
}

# Lambda ws_on_send_message_worker
resource "aws_lambda_function" "ws_on_send_message_worker" {
  function_name = "fcx-subsetting-ws_on_send_message_worker"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.ws_on_send_message_worker.key

  runtime =  "nodejs14.x"
  handler = "app.handler"

  source_code_hash = data.archive_file.ws_on_send_message_worker.output_base64sha256

  role = aws_iam_role.websocket_lambdas_subsetting_tool.arn

  environment {
    variables = {
      TABLE_NAME = var.TABLE_NAME
    }
  }
}

# Lambda ws_on_disconnect_worker
resource "aws_lambda_function" "ws_on_disconnect_worker" {
  function_name = "fcx-subsetting-ws_on_disconnect_worker"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.ws_on_disconnect_worker.key

  runtime =  "nodejs14.x"
  handler = "app.handler"

  source_code_hash = data.archive_file.ws_on_disconnect_worker.output_base64sha256

  role = aws_iam_role.websocket_lambdas_subsetting_tool.arn

  environment {
    variables = {
      TABLE_NAME = var.TABLE_NAME
    }
  }
}



## 2.4. CREATE CLOUDWATCH LOG GROUP ##

# log ws_on_connect_worker
resource "aws_cloudwatch_log_group" "ws_on_connect_worker" {
  name = "/aws/lambda/${aws_lambda_function.ws_on_connect_worker.function_name}"

  retention_in_days = 3
}

# log ws_after_connect_worker
resource "aws_cloudwatch_log_group" "ws_after_connect_worker" {
  name = "/aws/lambda/${aws_lambda_function.ws_after_connect_worker.function_name}"

  retention_in_days = 3
}

# log ws_on_send_message_worker
resource "aws_cloudwatch_log_group" "ws_on_send_message_worker" {
  name = "/aws/lambda/${aws_lambda_function.ws_on_send_message_worker.function_name}"

  retention_in_days = 3
}

# log ws_on_disconnect_worker
resource "aws_cloudwatch_log_group" "ws_on_disconnect_worker" {
  name = "/aws/lambda/${aws_lambda_function.ws_on_disconnect_worker.function_name}"

  retention_in_days = 3
}


## WS API GATEWAY

# stage
# deployment

## routes
# route selection expression [Done]
# route request
# integration request


# API Gateway name
resource "aws_apigatewayv2_api" "subsetting_ws" {
  name                       = "subsetting_ws"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}



## INTEGRATION OF GATEWAY AND LAMBDA TRIGGER

resource "aws_apigatewayv2_integration" "connect" {
  api_id           = aws_apigatewayv2_api.subsetting_ws.id
  integration_type = "AWS_PROXY"

  content_handling_strategy = "CONVERT_TO_TEXT"
  integration_method        = "POST"
  integration_uri           = aws_lambda_function.ws_on_connect_worker.invoke_arn
}

resource "aws_apigatewayv2_integration" "afterconnect" {
  api_id           = aws_apigatewayv2_api.subsetting_ws.id
  integration_type = "AWS_PROXY"

  content_handling_strategy = "CONVERT_TO_TEXT"
  integration_method        = "POST"
  integration_uri           = aws_lambda_function.ws_after_connect_worker.invoke_arn
}

resource "aws_apigatewayv2_integration" "sendmessage" {
  api_id           = aws_apigatewayv2_api.subsetting_ws.id
  integration_type = "AWS_PROXY"

  content_handling_strategy = "CONVERT_TO_TEXT"
  integration_method        = "POST"
  integration_uri           = aws_lambda_function.ws_on_send_message_worker.invoke_arn
}

resource "aws_apigatewayv2_integration" "disconnect" {
  api_id           = aws_apigatewayv2_api.subsetting_ws.id
  integration_type = "AWS_PROXY"

  content_handling_strategy = "CONVERT_TO_TEXT"
  integration_method        = "POST"
  integration_uri           = aws_lambda_function.ws_on_disconnect_worker.invoke_arn
}



## Create Routes

resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.subsetting_ws.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.connect.id}"
}

resource "aws_apigatewayv2_route" "connect" {
  api_id    = aws_apigatewayv2_api.subsetting_ws.id
  route_key = "$connect"
  target    = "integrations/${aws_apigatewayv2_integration.connect.id}"
}

resource "aws_apigatewayv2_route" "disconnect" {
  api_id    = aws_apigatewayv2_api.subsetting_ws.id
  route_key = "$disconnect"
  target    = "integrations/${aws_apigatewayv2_integration.disconnect.id}"
}

resource "aws_apigatewayv2_route" "afterconnect" {
  api_id    = aws_apigatewayv2_api.subsetting_ws.id
  route_key = "afterconnect"
  target    = "integrations/${aws_apigatewayv2_integration.afterconnect.id}"
}

resource "aws_apigatewayv2_route" "sendmessage" {
  api_id    = aws_apigatewayv2_api.subsetting_ws.id
  route_key = "sendmessage"
  target    = "integrations/${aws_apigatewayv2_integration.sendmessage.id}"
}



## Create deployment for subsetting_ws

resource "aws_apigatewayv2_deployment" "subsetting_ws" {
  api_id      = aws_apigatewayv2_api.subsetting_ws.id
  description = "deployment of websocket for subsetting progressbar"

  triggers = {
    redeployment = sha1(join(",", tolist([
      jsonencode(aws_apigatewayv2_integration.connect),
      jsonencode(aws_apigatewayv2_integration.afterconnect),
      jsonencode(aws_apigatewayv2_integration.sendmessage),
      jsonencode(aws_apigatewayv2_integration.disconnect),
      jsonencode(aws_apigatewayv2_route.default),
      jsonencode(aws_apigatewayv2_route.connect),
      jsonencode(aws_apigatewayv2_route.afterconnect),
      jsonencode(aws_apigatewayv2_route.sendmessage),
      jsonencode(aws_apigatewayv2_route.disconnect)
    ])))
  }

  lifecycle {
    create_before_destroy = true
  }
}



## create stage for the subsetting_ws

resource "aws_apigatewayv2_stage" "subsetting_ws" {
  api_id = aws_apigatewayv2_api.subsetting_ws.id
  name   = "development"
}
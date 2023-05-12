## variables for aws provider

variable "aws_creds_path" {
  description = "The path to aws credentials file"

  type    = string
  default = "/home/sanjog/.aws/credentials"
}

variable "aws_region" {
  description = "AWS region for all resources."

  type    = string
  default = "us-east-1"
}


## variables for worker lambdas code

variable "BUCKET_AWS_REGION" {
  description = "AWS regions for each subset-worker"

  type    = string
  default = "us-east-1"
}

variable "SOURCE_BUCKET_NAME" {
  description = "Bucket with raw data files required for the subset-worker"

  type    = string
  default = "fcx-raw-data"
}

variable "WS_URL" {
  description = "WS URL needed for communication between subset-worker and frontend; for the progressbar "

  type    = string
  default = "wss://97cwyclmwd.execute-api.us-east-1.amazonaws.com/development"
}


## variables for worker lambda configuration

variable "lambda_execution_timeout" {
  description = "lambda execution time limit in seconds"

  type    = number
  default = 603
}

variable "lambda_execution_memory" {
  description = "Maximum memory that the lambda execution can use (in MB). Processing power is directly proportional to the memory size"

  type    = number
  default = 1024
}

variable "lambda_execution_ephimeral_storage" {
  description = "Maximum storage of /tmp that the lambda execution can use (in MB)."

  type    = number
  default = 5120
}


## variables for layers arns requried by lambda functions

variable "XarrS3fsH5ncf" {
  description = "includes xarray, h5.py and s3fs"

  type    = string
  default = "arn:aws:lambda:us-east-1:307493436926:layer:XarrS3fsH5ncf:1"
}

variable "XarrScipy" {
  description = "includes xarray and scipy"

  type    = string
  default = "arn:aws:lambda:us-east-1:307493436926:layer:XarrScipy:1"
}

variable "websocket-client" {
  description = "includes websocket-client package"

  type    = string
  default = "arn:aws:lambda:us-east-1:307493436926:layer:websocket-client:2"
}

variable "fcx-sst-marshmallow_json" {
  description = "includes marshmallow_json package"

  type    = string
  default = "arn:aws:lambda:us-east-1:307493436926:layer:fcx-sst-marshmallow_json:3"
}

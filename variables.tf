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


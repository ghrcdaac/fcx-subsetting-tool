variable "CLOUD_FRONT_URL" {
  type    = string
  default = "https://d1q93ngquhxm63.cloudfront.net" # TODO: get it from cloudwatch resource attributes
}

variable "DESTINATION_BUCKET_NAME" {
  type    = string
  default = "ghrc-fcx-subset-output"
}
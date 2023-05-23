## CREATE BUCKET for subsets output

resource "aws_s3_bucket" "fcx_subset_output" {
  bucket = var.DESTINATION_BUCKET_NAME

  tags = {
    Name = "fcx-subset-outputs"
  }
}



## ADD POLICY TO S3 BUCKET

# create policy document
data "aws_iam_policy_document" "allow_access_from_cloudfront" {
  statement {
    sid = "AllowCloudFrontServicePrincipal"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      aws_s3_bucket.fcx_subset_output.arn,
      "${aws_s3_bucket.fcx_subset_output.arn}/*",
    ]

    condition {
        test = "StringEquals"
        variable = "AWS:SourceArn"
        values = [
            "arn:aws:cloudfront::${var.accountId}:distribution/${aws_cloudfront_distribution.fcx_subset_output_distribution.id}"
        ]
    }
  }
}

# attach policy to bucket
resource "aws_s3_bucket_policy" "allow_access_from_cloudfront" {
  bucket = aws_s3_bucket.fcx_subset_output.id
  policy = data.aws_iam_policy_document.allow_access_from_cloudfront.json
}



## CLOUDFRONT SETUP

locals {
  s3_origin_id = "ghrc-fcx-subset-outputS3Origin"
}

# create OAC, for cloudwatch to get origin access to s3 
resource "aws_cloudfront_origin_access_control" "fcx_subset_output" {
  name                              = "ghrc-fcx-subset-output"
  description                       = "Allow the cloudfront to access the subsets output that is in s3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# create cloudfront distribution, with OAC attached
resource "aws_cloudfront_distribution" "fcx_subset_output_distribution" {
  origin {
    domain_name              = aws_s3_bucket.fcx_subset_output.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.fcx_subset_output.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Distributes the subsets output publicly which are stored in private bucket"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  tags = {
    Environment = var.stage_name
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
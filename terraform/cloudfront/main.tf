resource "aws_s3_bucket" "web_app_bucket" {
  bucket = var.domain_name

  tags = {
    Name        = "s3 bucket for ${var.domain_name}"
  }
  force_destroy = true
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "s3public" {
  bucket = aws_s3_bucket.web_app_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


# Static website configuration
resource "aws_s3_bucket_website_configuration" "web_app_bucket_config" {
  bucket = aws_s3_bucket.web_app_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}


# Origin Access Control resource
resource "aws_cloudfront_origin_access_control" "static_app_policy" {
  name                              = "static app 2 OAC"
  description                       = "static app 2 OAC policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Default cache policy for Cloudfront
resource "aws_cloudfront_cache_policy" "static_app_default_cache_policy" {
  name        = "staticapp2-cache-policy"
  comment     = "staticapp2-cache-policy"
  default_ttl = 50
  max_ttl     = 100
  min_ttl     = 1

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "all"
    }

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "all"
    }
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip =  true
  }
}

#  Cloudfront Distribution for S3
resource "aws_cloudfront_distribution" "static_app_cf" {
  origin {
    domain_name = aws_s3_bucket.web_app_bucket.bucket_regional_domain_name
    origin_id   = var.cf_s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.static_app_policy.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.domain_name
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.cf_s3_origin_id
    cache_policy_id = aws_cloudfront_cache_policy.static_app_default_cache_policy.id

    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations = []
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# Bucket policy for S3 bucket, only allow from cloudfront distribution
data "aws_iam_policy_document" "web_app_s3_bucket_policy" {
  statement {
    effect = "Allow"
    sid = "CloudFrontAllowRead"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.web_app_bucket.arn}/*"]

    principals {
      type        = "Service"
      identifiers = [ "cloudfront.amazonaws.com"]
    }
    condition {
      test = "ArnEquals"
      values = [ aws_cloudfront_distribution.static_app_cf.arn ]
      variable = "aws:SourceArn"
    }
  }
}

# Associate bucket policy to S3 bucket
resource "aws_s3_bucket_policy" "web_app_policy" {
  bucket = aws_s3_bucket.web_app_bucket.id
  policy = data.aws_iam_policy_document.web_app_s3_bucket_policy.json
}

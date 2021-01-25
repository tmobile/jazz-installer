#
# Resource aws_cloudfront_origin_access_identity
#
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "${var.envPrefix}-origin_access_identity"
}
resource "aws_cloudfront_distribution" "jazz" {
  origin {
    domain_name = "${aws_s3_bucket.jazz-web.bucket_domain_name}"
    origin_id   = "${var.envPrefix}-prod-static-website-origin-jazz_ui"
    origin_path = "/prod"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    }
  }
  origin {
    domain_name = "${aws_s3_bucket.jazz_s3_api_doc.bucket_domain_name}"
    origin_id   = "${var.envPrefix}-s3-api-doc-origin"
    origin_path = ""

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    }
  }
  comment             = "Some comment"
  default_root_object = "index.html"
  enabled             = true
  is_ipv6_enabled     = true

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.envPrefix}-prod-static-website-origin-jazz_ui"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 3600
    default_ttl            = 3600
    max_ttl                = 86400
    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior  {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.envPrefix}-s3-api-doc-origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 3600
    default_ttl            = 3600
    max_ttl                = 86400
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_All"

  tags = "${merge(var.additional_tags, local.common_tags)}"

  custom_error_response{
    error_caching_min_ttl = "300"
    error_code = "404"
    response_code = "200"
    response_page_path = "/index.html"
  }
  custom_error_response{
    error_caching_min_ttl = "300"
    error_code = "403"
    response_code = "200"
    response_page_path = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "${var.envPrefix}-origin_access_identity"
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} CLOUDFRONT_ORIGIN_ID ${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path} ${var.jenkinspropsfile}"
  }
}
resource "aws_cloudfront_distribution" "jazz" {
  origin {
    domain_name = "${aws_s3_bucket.jazz-web.bucket_domain_name}"
    origin_id   = "${var.envPrefix}-originid"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    }
  }
  comment             = "Some comment"
  default_root_object = "index.html"
  enabled             = true
  is_ipv6_enabled     = true

  logging_config {
    include_cookies = true
    bucket          = "${aws_s3_bucket.cloudfrontlogs.bucket_domain_name}"
    prefix          = ""
  }


  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.envPrefix}-originid"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 3600
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_All"


  tags {
    Application = "${var.envPrefix}"
    Environment = "production"
  }

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

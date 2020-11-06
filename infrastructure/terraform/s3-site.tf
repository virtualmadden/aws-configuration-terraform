resource "aws_cloudfront_origin_access_identity" "origin" {
  comment = local.domain_name
}

resource "aws_s3_bucket" "origin" {
  bucket = local.domain_name
  acl    = "private"

  website {
    index_document = "index.html"
    error_document = "404.html"
  }

  tags          = {}
  force_destroy = true
}

resource "aws_cloudfront_distribution" "origin" {
  enabled         = true
  is_ipv6_enabled = true

  origin {
    origin_id   = "S3-${aws_s3_bucket.origin.id}"
    domain_name = aws_s3_bucket.origin.bucket_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin.cloudfront_access_identity_path
    }
  }

  default_root_object = "index.html"
  custom_error_response {
    error_code = "404"

    response_code      = "200"
    response_page_path = "/index.html"
  }

  default_cache_behavior {
    allowed_methods   = ["GET", "HEAD"]
    cached_methods    = ["GET", "HEAD"]

    forwarded_values {
      query_string = "false"

      cookies {
        forward = "none"
      }
    }

    target_origin_id  = "S3-${aws_s3_bucket.origin.id}"

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn       = aws_acm_certificate_validation.cert.certificate_arn
    ssl_support_method        = "sni-only"
    minimum_protocol_version  = "TLSv1.1_2016"
  }

  aliases = [local.domain_name, "www.${local.domain_name}"]

  lifecycle {
    ignore_changes = [tags]
  }
}

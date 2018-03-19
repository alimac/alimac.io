# ACM certificate has to be in us-east-1, but S3 buckets are in us-west-2
provider "aws" {
  region = "us-east-1"
}

# Region-specific provider for S3 buckets
provider "aws" {
  region = "us-west-2"
  alias  = "west"
}

# SSL certificate covering apex and www domains
resource "aws_acm_certificate" "cert" {
  domain_name       = "alimac.io"
  validation_method = "DNS"

  subject_alternative_names = ["www.alimac.io"]

  tags {
    Name = "alimac.io"
  }
}

# Domain validation record - alimac.io
resource "aws_route53_record" "alimac_io" {
  zone_id = "${aws_route53_zone.alimac_io.zone_id}"
  name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type    = "CNAME"
  ttl     = "60"
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
}

# Domain validation record - www.alimac.io
resource "aws_route53_record" "www_alimac_io" {
  zone_id = "${aws_route53_zone.alimac_io.zone_id}"
  name    = "${aws_acm_certificate.cert.domain_validation_options.1.resource_record_name}"
  type    = "CNAME"
  ttl     = "60"
  records = ["${aws_acm_certificate.cert.domain_validation_options.1.resource_record_value}"]
}

# wait for domain validation to complete
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.alimac_io.fqdn}", "${aws_route53_record.www_alimac_io.fqdn}"]
}

# Hosted zone in Route53
resource "aws_route53_zone" "alimac_io" {
  name = "alimac.io."
}

# S3 bucket for hosting static website
resource "aws_s3_bucket" "alimac_io" {
  bucket   = "alimac.io"
  provider = "aws.west"

  website {
    index_document = "index.html"
  }
}

# S3 bucket for redirecting www to apex domain
resource "aws_s3_bucket" "www_alimac_io" {
  bucket   = "www.alimac.io"
  provider = "aws.west"

  website {
    redirect_all_requests_to = "https://alimac.io"
  }
}

# CloudFront distribution - alimac.io
resource "aws_cloudfront_distribution" "alimac_io" {
  aliases             = ["alimac.io"]
  default_root_object = "index.html"
  enabled             = true
  http_version        = "http1.1"
  price_class         = "PriceClass_100"

  origin {
    domain_name = "${aws_s3_bucket.alimac_io.website_endpoint}"
    origin_id   = "S3-alimac.io"

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "${aws_acm_certificate.cert.arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000

    viewer_protocol_policy = "redirect-to-https"
    target_origin_id       = "S3-alimac.io"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }
}

# CloudFront distribution - www.alimac.io
resource "aws_cloudfront_distribution" "www_alimac_io" {
  aliases             = ["www.alimac.io"]
  default_root_object = "index.html"
  enabled             = true
  price_class         = "PriceClass_100"

  origin {
    domain_name = "${aws_s3_bucket.www_alimac_io.website_endpoint}"
    origin_id   = "S3-www.alimac.io"

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "${aws_acm_certificate.cert.arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000

    viewer_protocol_policy = "redirect-to-https"
    target_origin_id       = "S3-www.alimac.io"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }
}

# DNS - www.alimac.io
resource "aws_route53_record" "www" {
  zone_id = "${aws_route53_zone.alimac_io.zone_id}"
  name    = "www.alimac.io"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.www_alimac_io.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.www_alimac_io.hosted_zone_id}"
    evaluate_target_health = false
  }
}

# DNS - alimac.io
resource "aws_route53_record" "apex" {
  zone_id = "${aws_route53_zone.alimac_io.zone_id}"
  name    = "alimac.io"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.alimac_io.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.alimac_io.hosted_zone_id}"
    evaluate_target_health = false
  }
}

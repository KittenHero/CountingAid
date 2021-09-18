provider "aws" {
  region = "ap-southeast-2"
}

provider "aws" {
  alias = "us_east"
  region = "us-east-1"
}

variable root_domain {
    default = "kittenhero.zone"
}

variable site_domain {
    default = "counting-aid.kittenhero.zone"
}

resource "aws_s3_bucket" "counting_aid_site" {
    bucket = var.site_domain
    acl = "public-read"
    website {
        index_document = "index.html"
        error_document = "index.html"
    }
}

resource "aws_s3_bucket_policy" "public_read" {
    bucket = aws_s3_bucket.counting_aid_site.id
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid = "PublicReadGetObject"
                Effect = "Allow"
                Principal = "*"
                Action = "s3:GetObject"
                Resource = [
                    aws_s3_bucket.counting_aid_site.arn,
                    "${aws_s3_bucket.counting_aid_site.arn}/*",
                ]
            },
        ]
    })
}

data "aws_acm_certificate" "cloudfront_cert" {
    domain = var.root_domain
    types = ["AMAZON_ISSUED"]
    most_recent = true
    provider = aws.us_east
}

resource "aws_cloudfront_distribution" "counting_aid_cloudfront" {
    aliases = [var.site_domain]
    origin {
        domain_name = aws_s3_bucket.counting_aid_site.bucket_regional_domain_name
        origin_id = aws_s3_bucket.counting_aid_site.id
    }
    enabled = true
    default_root_object = "index.html"
    default_cache_behavior {
        target_origin_id = aws_s3_bucket.counting_aid_site.id
        viewer_protocol_policy = "redirect-to-https"
        compress = true
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
        min_ttl = 0
        default_ttl = 31536000
        max_ttl = 31536000

        forwarded_values {
            query_string = false
            cookies {
                forward = "none"
            }
        }
    }
    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }
    viewer_certificate {
        acm_certificate_arn = data.aws_acm_certificate.cloudfront_cert.arn
        ssl_support_method = "sni-only"
        minimum_protocol_version = "TLSv1.1_2016"
    }
}

data "aws_route53_zone" "zone" {
    name = var.root_domain
}

resource "aws_route53_record" "counting_aid_record" {
    zone_id = data.aws_route53_zone.zone.zone_id
    name = var.site_domain
    type = "A"
    alias {
        name = aws_cloudfront_distribution.counting_aid_cloudfront.domain_name
        zone_id = aws_cloudfront_distribution.counting_aid_cloudfront.hosted_zone_id
        evaluate_target_health = false
    }
}

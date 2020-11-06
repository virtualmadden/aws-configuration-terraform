provider "aws" {
  region = "us-east-1"
  alias  = "certs"
}

resource "aws_acm_certificate" "cert" {
  domain_name               = local.domain_name
  subject_alternative_names = ["www.${local.domain_name}"]
  validation_method         = "DNS"
  
  lifecycle {
    create_before_destroy = true
  }

  provider = aws.certs
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      type    = dvo.resource_record_type
      zone_id = aws_route53_zone.origin.zone_id
      record  = dvo.resource_record_value
    }
  }

  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  zone_id         = each.value.zone_id
  ttl             = 60
  allow_overwrite = true
  provider = aws.certs
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

  provider = aws.certs
}

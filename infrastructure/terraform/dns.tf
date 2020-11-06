resource "aws_route53_zone" "origin" {
  name = local.domain_name
}

resource "aws_route53_record" "apex" {
  name    = local.domain_name
  zone_id = aws_route53_zone.origin.zone_id
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.origin.domain_name
    zone_id                = aws_cloudfront_distribution.origin.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  name    = "www.${local.domain_name}"
  zone_id = aws_route53_zone.origin.zone_id
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.origin.domain_name
    zone_id                = aws_cloudfront_distribution.origin.hosted_zone_id
    evaluate_target_health = false
  }
}

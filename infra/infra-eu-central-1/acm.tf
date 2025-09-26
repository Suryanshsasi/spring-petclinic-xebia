resource "aws_acm_certificate" "alb_regional" {
  domain_name = local.app_fqdn
  validation_method = "DNS"
}

resource "aws_route53_record" "alb_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.alb_regional.domain_validation_options :
    dvo.domain_name => {
      name = dvo.resource_record_name
      type = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }
  zone_id = data.aws_route53_zone.root.zone_id
  name = each.value.name
  type = each.value.type
  ttl = 60
  records = [each.value.value]
}

resource "aws_acm_certificate_validation" "alb_regional" {
  certificate_arn = aws_acm_certificate.alb_regional.arn
  validation_record_fqdns = [for r in aws_route53_record.alb_cert_validation : r.fqdn]
}

# us-east-1 ACM for CloudFront
resource "aws_acm_certificate" "cf_use1" {
  provider = aws.use1
  domain_name = local.app_fqdn
  validation_method = "DNS"
}

resource "aws_route53_record" "cf_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cf_use1.domain_validation_options :
    dvo.domain_name => {
      name = dvo.resource_record_name
      type = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }
  zone_id = data.aws_route53_zone.root.zone_id
  name = each.value.name
  type = each.value.type
  ttl = 60
  records = [each.value.value]
}

resource "aws_acm_certificate_validation" "cf_use1" {
  provider = aws.use1
  certificate_arn = aws_acm_certificate.cf_use1.arn
  validation_record_fqdns = [for r in aws_route53_record.cf_cert_validation : r.fqdn]
}

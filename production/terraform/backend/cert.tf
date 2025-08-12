# Make a certificate for people visiting the frontend website.

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

resource "aws_acm_certificate" "backend_cert" {
  provider          = aws.us_east_1
  domain_name       = var.backend_domain
  validation_method = "DNS"

  subject_alternative_names = ["www.${var.backend_domain}"]
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.backend_cert.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }
  zone_id = var.r53_hz_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "backend_cert_validation" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.backend_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

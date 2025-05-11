resource "aws_acm_certificate" "ssl_cert" {
  domain_name       = "*.beesh.life"
  validation_method = "DNS"

  tags = {
    Name = "manadey"
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.ssl_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = var.zoneid # Replace with your Route 53 Hosted Zone ID
  name    = each.value.name
  type    = each.value.type
  ttl     = 10
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.ssl_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

resource "aws_ssm_parameter" "cert_arn" {
  name  = "/${var.project_name}/${var.environment}/acm_certificate_arn"
  type  = "String"
  value = aws_acm_certificate.ssl_cert.arn
}

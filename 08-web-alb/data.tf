
data "aws_ssm_parameter" "web_alb" {
  name = "/${var.project_name}/${var.environment}/web_alb_sg_id"
}



data "aws_ssm_parameter" "public_subnets" {
  name = "/${var.project_name}/${var.environment}/public_subnets"
}


data "aws_ssm_parameter" "cert_arn" {
  name = "/${var.project_name}/${var.environment}/acm_certificate_arn"
}

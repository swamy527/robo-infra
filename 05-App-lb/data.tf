
data "aws_ssm_parameter" "app_alb" {
  name = "/${var.project_name}/${var.environment}/app_alb_sg_id"
}



data "aws_ssm_parameter" "private_subnets" {
  name = "/${var.project_name}/${var.environment}/private_subnets"
}

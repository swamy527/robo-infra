

data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.project_name}/${var.environment}/vpc_id"
}


data "aws_ssm_parameter" "sg_id" {
  name = "/${var.project_name}/${var.environment}/web_sg_id"
}

data "aws_ssm_parameter" "subnets" {
  name = "/${var.project_name}/${var.environment}/public_subnets"
}

data "aws_ssm_parameter" "listener_arn" {
  name = "${var.project_name}-${var.environment}-web_alb_listener"
}

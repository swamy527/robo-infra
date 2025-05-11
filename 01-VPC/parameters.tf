resource "aws_ssm_parameter" "vpc_id" {
  name  = "/${var.project_name}/${var.environment}/vpc_id"
  type  = "String"
  value = module.roboshop.vpc_id
}

resource "aws_ssm_parameter" "public_subnets" {
  name  = "/${var.project_name}/${var.environment}/public_subnets"
  type  = "StringList"
  value = join(",", module.roboshop.public_subnets)
}

resource "aws_ssm_parameter" "private_subnets" {
  name  = "/${var.project_name}/${var.environment}/private_subnets"
  type  = "StringList"
  value = join(",", module.roboshop.private_subnets)
}

resource "aws_ssm_parameter" "database_subnets" {
  name  = "/${var.project_name}/${var.environment}/database_subnets"
  type  = "StringList"
  value = join(",", module.roboshop.database_subnets)
}

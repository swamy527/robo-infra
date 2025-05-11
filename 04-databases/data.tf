data "aws_ssm_parameter" "databse_subnets" {
  name = "/${var.project}/${var.environment}/database_subnets"
}

data "aws_ssm_parameter" "mongo_sg" {
  name = "/${var.project}/${var.environment}/mongodb_sg_id"
}

data "aws_ssm_parameter" "redis_sg" {
  name = "/${var.project}/${var.environment}/redis_sg_id"
}

data "aws_ssm_parameter" "mysql_sg" {
  name = "/${var.project}/${var.environment}/mysql_sg_id"
}

data "aws_ssm_parameter" "rabbitmq_sg" {
  name = "/${var.project}/${var.environment}/rabbitmq_sg_id"
}

data "aws_ssm_parameter" "sg_id" {
  name = "/${var.project}/${var.environment}/vpn_sg_id"
}

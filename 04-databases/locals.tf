locals {
  subid = split(",", data.aws_ssm_parameter.databse_subnets.value)
}

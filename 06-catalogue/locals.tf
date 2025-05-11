locals {
  name = split(",", data.aws_ssm_parameter.subnets.value)
}

locals {
  current_time = formatdate("YYYY-MM-DD-hh-mm", timestamp())
}

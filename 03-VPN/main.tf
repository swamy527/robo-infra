provider "aws" {
  region = "us-east-1"
}


resource "aws_instance" "vpn" {
  ami                    = var.centos
  instance_type          = "t2.small"
  vpc_security_group_ids = [data.aws_ssm_parameter.sg_id.value]
  user_data              = file("openvpn.sh")
  tags = {
    Name = "openvpn"
  }
}

output "ip_address" {
  value = aws_instance.vpn.public_ip
}

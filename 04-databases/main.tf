provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "mongodb" {
  ami                    = var.centos
  instance_type          = "t2.medium"
  vpc_security_group_ids = [data.aws_ssm_parameter.mongo_sg.value]
  subnet_id              = local.subid[0]
  tags = {
    Name = "mongodb"
  }
}

resource "aws_instance" "redis" {
  ami                    = var.centos
  instance_type          = "t2.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.redis_sg.value]
  subnet_id              = local.subid[0]
  tags = {
    Name = "redis"
  }
}

resource "aws_instance" "mysql" {
  ami                    = var.centos
  instance_type          = "t2.medium"
  iam_instance_profile   = "Ec2-instances"
  vpc_security_group_ids = [data.aws_ssm_parameter.mysql_sg.value]
  subnet_id              = local.subid[0]
  tags = {
    Name = "mysql"
  }
}

resource "aws_instance" "rabbitmq" {
  ami                    = var.centos
  instance_type          = "t2.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.rabbitmq_sg.value]
  subnet_id              = local.subid[0]
  tags = {
    Name = "rabbitmq"
  }
}

resource "aws_route53_record" "mongodb" {
  zone_id = var.zoneid
  name    = "mongodb"
  type    = "A"
  ttl     = 1
  records = [aws_instance.mongodb.private_ip]
}

resource "aws_route53_record" "redis" {
  zone_id = var.zoneid
  name    = "redis"
  type    = "A"
  ttl     = 1
  records = [aws_instance.redis.private_ip]
}

resource "aws_route53_record" "mysql" {
  zone_id = var.zoneid
  name    = "mysql"
  type    = "A"
  ttl     = 1
  records = [aws_instance.mysql.private_ip]
}

resource "aws_route53_record" "rabbitmq" {
  zone_id = var.zoneid
  name    = "rabbitmq"
  type    = "A"
  ttl     = 1
  records = [aws_instance.rabbitmq.private_ip]
}

resource "null_resource" "mongodb" {
  triggers = {
    instance_id = aws_instance.mongodb.id
  }
  connection {
    type     = "ssh"
    user     = "centos"
    password = "DevOps321"
    host     = aws_instance.mongodb.private_ip
  }
  provisioner "remote-exec" {
    inline = ["sudo yum update -y",
      "sudo yum install ansible -y",
    "ansible-pull -U https://github.com/swamy527/roboshop-ansible-roles-tf.git -e component=mongodb -e env=${var.environment} main-tf.yaml"]
  }

}

resource "null_resource" "redis" {
  triggers = {
    instance_id = aws_instance.redis.id
  }
  connection {
    type     = "ssh"
    user     = "centos"
    password = "DevOps321"
    host     = aws_instance.redis.private_ip
  }
  provisioner "remote-exec" {
    inline = ["sudo yum update -y",
      "sudo yum install ansible -y",
    "ansible-pull -U https://github.com/swamy527/roboshop-ansible-roles-tf.git -e component=redis -e env=${var.environment} main-tf.yaml"]
  }

}

resource "null_resource" "mysql" {
  triggers = {
    instance_id = aws_instance.mysql.id
  }
  connection {
    type     = "ssh"
    user     = "centos"
    password = "DevOps321"
    host     = aws_instance.mysql.private_ip
  }
  provisioner "remote-exec" {
    inline = ["sudo yum update -y",
      "sudo yum install ansible python3.12-pip -y",
      "python3.12 -m pip install boto3 botocore",
    "ansible-pull -U https://github.com/swamy527/roboshop-ansible-roles-tf.git -e component=mysql -e env=${var.environment} main-tf.yaml"]
  }

}


resource "null_resource" "rabbitmq" {
  triggers = {
    instance_id = aws_instance.rabbitmq.id
  }
  connection {
    type     = "ssh"
    user     = "centos"
    password = "DevOps321"
    host     = aws_instance.rabbitmq.private_ip
  }
  provisioner "remote-exec" {
    inline = ["sudo yum update -y",
      "sudo yum install ansible -y",
    "ansible-pull -U https://github.com/swamy527/roboshop-ansible-roles-tf.git -e component=rabbitmq -e env=${var.environment} main-tf.yaml"]
  }

}

provider "aws" {
  region = "us-east-1"
}

resource "aws_lb_target_group" "web" {
  name                 = "${var.project_name}-${var.environment}-web"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = data.aws_ssm_parameter.vpc_id.value
  deregistration_delay = 60 #once deregitration triggered it will stop taking new requests it will terminate after 60 seconds
  health_check {
    healthy_threshold   = 2
    interval            = 10
    unhealthy_threshold = 3
    timeout             = 5
    path                = "/health"
    port                = 80
    matcher             = "200-299"
  }
}

resource "aws_instance" "web" {
  ami                    = var.centos
  instance_type          = "t2.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.sg_id.value]
  subnet_id              = local.public_sub[0]
  tags = {
    Name = "web"
  }
}

resource "null_resource" "web" {
  triggers = {
    instance_id = aws_instance.web.id
  }
  connection {
    type     = "ssh"
    user     = "centos"
    password = "DevOps321"
    host     = aws_instance.web.private_ip
  }
  provisioner "remote-exec" {
    inline = ["sudo yum update -y",
      "sudo yum install ansible -y",
    "ansible-pull -U https://github.com/swamy527/roboshop-ansible-roles-tf.git -e component=web -e env=${var.environment} main-tf.yaml"]
  }

}

resource "aws_ec2_instance_state" "web" {
  instance_id = aws_instance.web.id
  state       = "stopped"
  depends_on  = [null_resource.web]

}

resource "aws_ami_from_instance" "web" {
  name               = "${var.project_name}-${var.environment}-web-${local.current_time}"
  source_instance_id = aws_instance.web.id
  depends_on         = [aws_ec2_instance_state.web]
}

resource "null_resource" "web_delete" {
  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${aws_instance.web.id}"
  }
  depends_on = [aws_ami_from_instance.web]
}

resource "aws_launch_template" "web" {
  name                                 = "${var.project_name}-${var.environment}-web"
  instance_initiated_shutdown_behavior = "terminate"
  image_id                             = aws_ami_from_instance.web.id
  instance_type                        = "t2.micro"
  vpc_security_group_ids               = [data.aws_ssm_parameter.sg_id.value]
  update_default_version               = true
}


resource "aws_autoscaling_group" "web" {
  name                      = "${var.project_name}-${var.environment}-web"
  max_size                  = 4
  min_size                  = 1
  health_check_grace_period = 60
  health_check_type         = "ELB"
  desired_capacity          = 2
  vpc_zone_identifier       = local.public_sub
  target_group_arns         = [aws_lb_target_group.web.arn]

  launch_template {
    id      = aws_launch_template.web.id
    version = aws_launch_template.web.latest_version
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }

  tag {
    key                 = "Name"
    value               = "web"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }
}

resource "aws_lb_listener_rule" "web" {
  listener_arn = data.aws_ssm_parameter.listener_arn.value
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }


  condition {
    host_header {
      values = ["web-${var.environment}.${var.zone_name}"]
    }
  }
}

resource "aws_autoscaling_policy" "web" {
  autoscaling_group_name = aws_autoscaling_group.web.name
  name                   = "${var.project_name}-${var.environment}-web"
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 5.0
  }
}

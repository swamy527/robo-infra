provider "aws" {
  region = "us-east-1"
}

resource "aws_lb_target_group" "catalogue" {
  name                 = "${var.project_name}-${var.environment}"
  port                 = 8080
  protocol             = "HTTP"
  vpc_id               = data.aws_ssm_parameter.vpc_id.value
  deregistration_delay = 60 #once deregitration triggered it will stop taking new requests it will terminate after 60 seconds
  health_check {
    healthy_threshold   = 2
    interval            = 10
    unhealthy_threshold = 3
    timeout             = 5
    path                = "/health"
    port                = 8080
    matcher             = "200-299"
  }
}

resource "aws_instance" "catalogue" {
  ami                    = var.centos
  instance_type          = "t2.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.sg_id.value]
  subnet_id              = local.name[0]
  tags = {
    Name = "catalogue"
  }
}

resource "null_resource" "catalogue" {
  triggers = {
    instance_id = aws_instance.catalogue.id
  }
  connection {
    type     = "ssh"
    user     = "centos"
    password = "DevOps321"
    host     = aws_instance.catalogue.private_ip
  }
  provisioner "remote-exec" {
    inline = ["sudo yum update -y",
      "sudo yum install ansible -y",
    "ansible-pull -U https://github.com/swamy527/roboshop-ansible-roles-tf.git -e component=catalogue -e env=${var.environment} main-tf.yaml"]
  }

}

resource "aws_ec2_instance_state" "catalogue" {
  instance_id = aws_instance.catalogue.id
  state       = "stopped"
  depends_on  = [null_resource.catalogue]

}

resource "aws_ami_from_instance" "catalogue" {
  name               = "${var.project_name}-${var.environment}-${local.current_time}"
  source_instance_id = aws_instance.catalogue.id
  depends_on         = [aws_ec2_instance_state.catalogue]
}

resource "null_resource" "catalogue_delete" {
  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${aws_instance.catalogue.id}"
  }
  depends_on = [aws_ami_from_instance.catalogue]
}

resource "aws_launch_template" "catalogue" {
  name                                 = "${var.project_name}-${var.environment}"
  instance_initiated_shutdown_behavior = "terminate"
  image_id                             = aws_ami_from_instance.catalogue.id
  instance_type                        = "t2.micro"
  vpc_security_group_ids               = [data.aws_ssm_parameter.sg_id.value]
  update_default_version               = true
}


resource "aws_autoscaling_group" "catalogue" {
  name                      = "${var.project_name}-${var.environment}"
  max_size                  = 4
  min_size                  = 1
  health_check_grace_period = 60
  health_check_type         = "ELB"
  desired_capacity          = 2
  vpc_zone_identifier       = split(",", data.aws_ssm_parameter.subnets.value)
  target_group_arns         = [aws_lb_target_group.catalogue.arn]

  launch_template {
    id      = aws_launch_template.catalogue.id
    version = aws_launch_template.catalogue.latest_version
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
    value               = "catalogue"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }
}

resource "aws_lb_listener_rule" "catalogue" {
  listener_arn = data.aws_ssm_parameter.listener_arn.value
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.catalogue.arn
  }


  condition {
    host_header {
      values = ["catalogue.${var.environment}.${var.zone_name}"]
    }
  }
}

resource "aws_autoscaling_policy" "catalogue" {
  autoscaling_group_name = aws_autoscaling_group.catalogue.name
  name                   = "${var.project_name}-${var.environment}"
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 5.0
  }
}

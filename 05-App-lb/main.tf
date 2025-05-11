resource "aws_lb" "app_lb" {
  name               = "${var.project_name}-${var.environment}"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [data.aws_ssm_parameter.app_alb.value]
  subnets            = split(",", data.aws_ssm_parameter.private_subnets.value)
}

resource "aws_lb_listener" "app_lb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "this message from app load balancer"
      status_code  = "200"
    }
  }
}

resource "aws_route53_record" "app_alb_record" {
  zone_id = var.zoneid
  name    = "*.dev"
  type    = "A"
  alias {
    name                   = aws_lb.app_lb.dns_name
    zone_id                = aws_lb.app_lb.zone_id
    evaluate_target_health = true
  }
}

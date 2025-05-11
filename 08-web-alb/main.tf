resource "aws_lb" "web_lb" {
  name               = "${var.project_name}-${var.environment}-web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_ssm_parameter.web_alb.value]
  subnets            = split(",", data.aws_ssm_parameter.public_subnets.value)
}

resource "aws_lb_listener" "web_lb_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06" #always take latest ssl policy
  certificate_arn   = data.aws_ssm_parameter.cert_arn.value
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "this message from web load balancer"
      status_code  = "200"
    }
  }
}

resource "aws_route53_record" "web_alb_record" {
  zone_id = var.zoneid
  name    = "web-${var.environment}"
  type    = "A"
  alias {
    name                   = aws_lb.web_lb.dns_name
    zone_id                = aws_lb.web_lb.zone_id
    evaluate_target_health = true
  }
}

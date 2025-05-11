resource "aws_ssm_parameter" "listener_arn" {
  name  = "${var.project_name}-${var.environment}-web_alb_listener"
  type  = "String"
  value = aws_lb_listener.web_lb_listener.arn
}

resource "aws_ssm_parameter" "listener_arn" {
  name  = "${var.project_name}-${var.environment}-internal_alb_listener"
  type  = "String"
  value = aws_lb_listener.app_lb_listener.arn
}

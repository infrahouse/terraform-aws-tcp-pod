resource "aws_lb" "tcp" {
  name_prefix                = var.nlb_name_prefix
  enable_deletion_protection = var.enable_deletion_protection
  subnets                    = var.subnets
  idle_timeout               = var.nlb_idle_timeout
  load_balancer_type         = "network"
  internal                   = !data.aws_subnet.selected.map_public_ip_on_launch
  security_groups = [
    aws_security_group.nlb.id
  ]

  tags = merge(
    local.default_module_tags,
    local.access_log_tags
  )
}

resource "aws_lb_listener" "tcp" {
  load_balancer_arn = aws_lb.tcp.arn
  port              = var.nlb_listener_port
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tcp.arn
  }
}

resource "aws_lb_target_group" "tcp" {
  port        = var.target_group_port
  protocol    = "TCP"
  target_type = var.target_group_type
  vpc_id      = data.aws_subnet.selected.vpc_id

  health_check {
    enabled             = var.nlb_healthcheck_enabled
    path                = var.nlb_healthcheck_path
    port                = var.nlb_healthcheck_port
    protocol            = var.nlb_healthcheck_protocol
    healthy_threshold   = var.nlb_healthcheck_healthy_threshold
    unhealthy_threshold = var.nlb_healthcheck_uhealthy_threshold
    interval            = var.nlb_healthcheck_interval
    timeout             = var.nlb_healthcheck_timeout
    matcher             = var.nlb_healthcheck_response_code_matcher
  }

  tags = local.default_module_tags
}

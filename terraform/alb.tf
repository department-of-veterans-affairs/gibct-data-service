resource "aws_alb" "main" {
  name               = "${local.name}"
  security_groups    = [aws_security_group.lb.id]
  load_balancer_type = "application"
  internal           = true

  dynamic "subnet_mapping" {
    for_each = data.aws_subnet.selected.*.id
    content {
      subnet_id            = subnet_mapping.value
      # private_ipv4_address = var.ip_addresses[subnet_mapping.key]
    }
  }
}

resource "aws_alb_target_group" "web" {
  name        = "${local.name}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.selected.id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 5
    path                = "/health"
    timeout             = 4
    matcher             = "200"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_alb_listener" "web" {
  load_balancer_arn = aws_alb.main.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.web.id
    type             = "forward"
  }

  lifecycle {
    replace_triggered_by = [aws_alb_target_group.web]
  }
}

output "alb" {
  value = aws_alb.main.dns_name
}

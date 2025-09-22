resource "aws_lb_listener" "front_lb_listener" {
  load_balancer_arn = aws_lb.front_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.proxy_target_group.arn
  }
}

resource "aws_lb_listener" "back_lb_listener" {
  load_balancer_arn = aws_lb.back_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.back_target_group.arn
  }
}
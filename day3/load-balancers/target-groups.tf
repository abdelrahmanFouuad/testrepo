resource "aws_lb_target_group" "proxy_target_group" {
  name     = "proxy-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  
}


resource "aws_lb_target_group" "back_target_group" {
  name     = "back-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

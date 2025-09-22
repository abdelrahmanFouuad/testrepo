resource "aws_lb_target_group_attachment" "proxy_tg_attach_1" {
  target_group_arn =                aws_lb_target_group.proxy_target_group.arn
  target_id =                       var.proxy_1_id
}

resource "aws_lb_target_group_attachment" "proxy_tg_attach_2" {
  target_group_arn =                aws_lb_target_group.proxy_target_group.arn
  target_id =                       var.proxy_2_id
}

resource "aws_lb_target_group_attachment" "back_tg_attach_1" {
  target_group_arn =                aws_lb_target_group.back_target_group.arn
  target_id =                       var.back_instance_1_id
}

resource "aws_lb_target_group_attachment" "back_tg_attach_2" {
  target_group_arn =                aws_lb_target_group.back_target_group.arn
  target_id =                       var.back_instance_2_id
}
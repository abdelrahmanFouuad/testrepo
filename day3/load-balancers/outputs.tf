output "front_lb_sg_id" {
  value         = aws_security_group.front_lb_sg.id
}
output "back_lb_sg_id" {
  value         = aws_security_group.back_lb_sg.id
}
output "front_lb_dns" {
  value = aws_lb.front_lb.dns_name
}
output "back_b_dns" {
  value = aws_lb.back_lb.dns_name
}
output "proxy_1_ip" {
  value = aws_instance.instance_proxy_1.public_ip
}

output "proxy_2_ip" {
  value = aws_instance.instance_proxy_2.public_ip
}

output "proxy_1_id" {
  value = aws_instance.instance_proxy_1.id
}

output "proxy_2_id" {
  value = aws_instance.instance_proxy_2.id
}

output "back_1_id" {
  value = aws_instance.instance_back_1.id
}

output "back_2_id" {
  value = aws_instance.instance_back_2.id
}
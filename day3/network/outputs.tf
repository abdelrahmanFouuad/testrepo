output "vpc_id" {
    value = aws_vpc.iti-vpc.id
}

output "pub_sub_ids" {
    value = [aws_subnet.pub_subnet_1.id, aws_subnet.pub_subnet_2.id]
}

output "pub_subnet_1_id" {
    value = aws_subnet.pub_subnet_1.id
}

output "pub_subnet_2_id" {
    value = aws_subnet.pub_subnet_2.id
}

output "pri_subnet_1_id" {
    value = aws_subnet.pri_subnet_1.id
}

output "pri_subnet_2_id" {
    value = aws_subnet.pri_subnet_2.id
}

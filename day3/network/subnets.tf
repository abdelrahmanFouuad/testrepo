resource "aws_subnet" "pub_subnet_1" {
    vpc_id =                    aws_vpc.iti-vpc.id
    cidr_block =                var.pub_subnet_1_cidr
    availability_zone =         var.az_1
    map_public_ip_on_launch =   true
    tags = {
        Name=                   "Public Subnet 1"
    }
}

resource "aws_subnet" "pub_subnet_2" {
    vpc_id =                    aws_vpc.iti-vpc.id
    cidr_block =                var.pub_subnet_2_cidr
    availability_zone =         var.az_2
    map_public_ip_on_launch =   true
    tags = {
        Name=                   "Public Subnet 2"
    }
}

resource "aws_subnet" "pri_subnet_1" {
    vpc_id =                    aws_vpc.iti-vpc.id
    cidr_block =                var.pri_subnet_1_cidr
    availability_zone =         var.az_1

    tags = {
        Name=                   "Private Subnet 1"
    }
}

resource "aws_subnet" "pri_subnet_2" {
    vpc_id =                    aws_vpc.iti-vpc.id
    cidr_block =                var.pri_subnet_2_cidr
    availability_zone =         var.az_2

    tags = {
        Name=                   "Private Subnet 2"
    }
}
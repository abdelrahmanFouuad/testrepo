resource "aws_route_table" "pub_route_table" {
    vpc_id =                        aws_vpc.iti-vpc.id
    
    route {
        cidr_block =                "10.0.0.0/16"
        gateway_id =                "local"
    }

    route {
        cidr_block =                "0.0.0.0/0"
        gateway_id =                aws_internet_gateway.iti-igw.id
    }
}

resource "aws_route_table" "pri_route_table" {
    vpc_id =                        aws_vpc.iti-vpc.id
    
    route {
        cidr_block =                "10.0.0.0/16"
        gateway_id =                "local"
    }
}

resource "aws_route_table_association" "pub_association_1" {
    subnet_id =                     aws_subnet.pub_subnet_1.id
    route_table_id =                aws_route_table.pub_route_table.id
}

resource "aws_route_table_association" "pub_association_2" {
    subnet_id =                     aws_subnet.pub_subnet_2.id
    route_table_id =                aws_route_table.pub_route_table.id
}

resource "aws_route_table_association" "pri_association_1" {
    subnet_id =                     aws_subnet.pri_subnet_1.id
    route_table_id =                aws_route_table.pri_route_table.id
}

resource "aws_route_table_association" "pri_association_2" {
    subnet_id =                     aws_subnet.pri_subnet_2.id
    route_table_id =                aws_route_table.pri_route_table.id
}
resource "aws_internet_gateway" "iti-igw" {
    vpc_id =                        aws_vpc.iti-vpc.id

    tags = {
        Name=                       "iti-igw"
    }
}
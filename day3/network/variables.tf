variable "vpc_cidr" {
    type =          string
}

variable "pub_subnet_1_cidr" {
    type =          string
}

variable "pub_subnet_2_cidr" {
    type =          string
}

variable "pri_subnet_1_cidr" {
    type =          string
}

variable "public_subnets_cidrs" {
    type =          list
    default =       ["10.0.0.0/24", "10.0.2.0/24"]
}
variable "private_subnets_cidrs" {
    type =          list
    default =       ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "pri_subnet_2_cidr" {
    type =          string
}
variable "az_1" {
    type =          string
}
variable "az_2" {
    type =          string
}

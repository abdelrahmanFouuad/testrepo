variable "vpc_id" {
    type = string
}

variable "vpc_cidr" {
    type = string
}

variable "front_lb_sg_id" {
    type = string
}

variable "back_lb_sg_id" {
    type = string
}
variable "isntance_type" {
    type = string
    default = "t3.micro"
}

variable "pub_subnet_1_id" {
  type = string
}

variable "pub_subnet_2_id" {
  type = string
}

variable "pri_subnet_1_id" {
  type = string
}

variable "pri_subnet_2_id" {
  type = string
}

variable "back_lb_dns" {
  type = string
}
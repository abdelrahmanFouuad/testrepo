variable "pub_subnets_ids" {
    type = list
}
variable "pri_subnets_ids" {
    type = list
}
variable "pub_subnets_ips" {
    type = list
}
variable "vpc_id" {
  type = string
}

variable "proxy_1_id" {
  type = string
}

variable "proxy_2_id" {
  type = string
}

variable "back_instance_1_id" {
  type = string
}

variable "back_instance_2_id" {
  type = string
}
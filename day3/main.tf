module "network" {
  source   = "./network"
  vpc_cidr = var.vpc_cidr

  pub_subnet_1_cidr = var.pub_subnet_1_cidr
  pri_subnet_1_cidr = var.pri_subnet_1_cidr
  pub_subnet_2_cidr = var.pub_subnet_2_cidr
  pri_subnet_2_cidr = var.pri_subnet_2_cidr

  az_1 = var.az_1
  az_2 = var.az_2
}

module "instances" {
    source = "./instances"
    vpc_cidr = var.vpc_cidr
    vpc_id = module.network.vpc_id
    front_lb_sg_id = module.lbs.front_lb_sg_id
    pub_subnet_1_id = module.network.pub_subnet_1_id
    pub_subnet_2_id = module.network.pub_subnet_2_id
    pri_subnet_1_id = module.network.pri_subnet_1_id
    pri_subnet_2_id = module.network.pri_subnet_2_id
    back_lb_sg_id = module.lbs.back_lb_sg_id
    back_lb_dns = module.lbs.back_b_dns
}

module "lbs" {
  source = "./load-balancers"
  pub_subnets_ids = module.network.pub_sub_ids
  pri_subnets_ids = [module.network.pri_subnet_1_id, module.network.pri_subnet_2_id]
  vpc_id = module.network.vpc_id
  proxy_1_id = module.instances.proxy_1_id
  proxy_2_id = module.instances.proxy_2_id
  back_instance_1_id = module.instances.back_1_id
  back_instance_2_id = module.instances.back_2_id
  pub_subnets_ips = [var.pub_subnet_1_cidr, var.pub_subnet_2_cidr]
}

output "proxy_1_ip" {
  value = module.instances.proxy_1_ip
}

output "proxy_2_ip" {
  value = module.instances.proxy_2_ip
}

output "front_lb_dns" {
  value = module.lbs.front_lb_dns
}
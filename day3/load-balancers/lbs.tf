resource "aws_lb" "front_lb" {
  name               = "front-load-balancer"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.pub_subnets_ids
  security_groups    = [aws_security_group.front_lb_sg.id]
  tags = {
    Name = "Front Load Balancer"
  }
}


resource "aws_lb" "back_lb" {
  name                = "back-load-balancer"
  internal            = true
  load_balancer_type  = "application"
  subnets             = var.pri_subnets_ids
  security_groups     = [aws_security_group.back_lb_sg.id]
  tags = {
    Name              = "Back Load Balancer"
  } 
}

resource "aws_security_group" "front_lb_sg" {
  name              = "front-lb-sg"
  vpc_id            = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"] 
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "back_lb_sg" {
  name              = "back-lb-sg"
  vpc_id            = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = var.pub_subnets_ips
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
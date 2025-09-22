resource "aws_instance" "instance_proxy_1" {
  ami                    = data.aws_ami.ubuntu_ami.id
  instance_type          = var.isntance_type
  subnet_id              = var.pub_subnet_1_id
  key_name               = "new-key"
  vpc_security_group_ids = [aws_security_group.proxy_instances_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    cat > /etc/nginx/sites-available/default <<EOL
    server {
        listen 80;

        location / {
            proxy_pass http://${var.back_lb_dns};
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
    EOL
    systemctl restart nginx
EOF

  tags = {
    Name = "Proxy 1 instance"
  }
}

resource "aws_instance" "instance_proxy_2" {
  ami           = data.aws_ami.ubuntu_ami.id
  instance_type = var.isntance_type
  subnet_id     = var.pub_subnet_2_id

  vpc_security_group_ids = [aws_security_group.proxy_instances_sg.id]
  key_name               = "new-key"

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    cat > /etc/nginx/sites-available/default <<EOL
    server {
        listen 80;

        location / {
            proxy_pass http://${var.back_lb_dns};
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
    EOL
    systemctl restart nginx
EOF
  tags = {
    Name = "Proxy 2 instance"
  }
}


resource "aws_instance" "instance_back_1" {
  ami           = data.aws_ami.ubuntu_ami.id
  instance_type = var.isntance_type
  subnet_id     = var.pri_subnet_1_id

  vpc_security_group_ids = [aws_security_group.back_instances_sg.id]
  key_name               = "new-key"

  user_data = <<-EOF
            #!/bin/bash
            apt-get update -y
            apt-get install -y nginx
            
            sudo systemctl start nginx
            sudo systemctl enable nginx
            echo "Hello From Proxy Server 1" | tee /var/www/html/index.html
            sudo systemctl restart nginx
        EOF
  tags = {
    Name = "Back 1 instance"
  }
}

resource "aws_instance" "instance_back_2" {
  ami           = data.aws_ami.ubuntu_ami.id
  instance_type = var.isntance_type
  subnet_id     = var.pri_subnet_2_id

  vpc_security_group_ids = [aws_security_group.back_instances_sg.id]
  key_name               = "new-key"

  user_data = <<-EOF
            #!/bin/bash
            apt-get update -y
            apt-get install -y nginx
            
            sudo systemctl start nginx
            sudo systemctl enable nginx
            echo "Hello From Proxy Server 2" | tee /var/www/html/index.html
            sudo systemctl restart nginx
        EOF
  tags = {
    Name = "Back 2 instance"
  }
}


resource "aws_security_group" "back_instances_sg" {
  vpc_id = var.vpc_id

  ingress {
    #allow http traffic only from back load balancer
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.back_lb_sg_id]
  }
  ingress {
    #allow ssh from within the vpc for debugging
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
}

resource "aws_security_group" "proxy_instances_sg" {
  vpc_id = var.vpc_id
  ingress {
    #allow ssh from anywhere
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    #allow http traffic only from load balancer
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.front_lb_sg_id] #from load balancer security group only
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

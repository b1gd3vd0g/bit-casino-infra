provider "aws" {
  region = "us-west-1"
}

data "aws_vpc" "main" {
  id = var.vpc_id
}

data "aws_subnet" "public_a" {
  id = var.pub_subnet_id
}

resource "tls_private_key" "backend_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096

}

resource "aws_key_pair" "backend_key" {
  key_name   = "bit-casino-backend-ssh-key"
  public_key = tls_private_key.backend_ssh.public_key_openssh
}

resource "local_file" "backend_private_key" {
  content              = tls_private_key.backend_ssh.private_key_pem
  filename             = "${path.module}/backend-ssh-key.pem"
  file_permission      = "0400"
  directory_permission = "0700"
}

resource "aws_security_group" "backend_sg" {
  name        = "bit-casino-backend-sg"
  description = "Allow SSH and app traffic"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App traffic"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "amazon_linux2_arm64" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-arm64-gp2"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "backend" {
  ami                         = data.aws_ami.amazon_linux2_arm64.id
  instance_type               = "t4g.nano"
  key_name                    = aws_key_pair.backend_key.key_name
  subnet_id                   = data.aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.backend_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
            #!/bin/bash
            yum update -y
            amazon-linux-extras install docker -y
            service docker start
            usermod -a -G docker ec2-user
            curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            chmod +x /usr/local/bin/docker-compose
            yum install -y git
            git clone https://github.com/b1gd3vd0g/bit-casino-infra.git /home/ec2-user/bit-casino
            cd /home/ec2-user/bit-casino/production/
            docker-compose up --build -d
            EOF
}

output "backend_ec2_ip" {
  value = aws_instance.backend.public_ip
}

output "backend_private_key_path" {
  value = local_file.backend_private_key.filename
}

output "backend_sg_id" {
  value = aws_security_group.backend_sg.id
}

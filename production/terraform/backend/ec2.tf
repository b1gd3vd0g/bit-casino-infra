# Generate SSH keys for the EC2 instance.
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh" {
  key_name   = "bit-casino-backend-ssh-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

# Save the private SSH key locally.
resource "local_file" "private_key" {
  content              = tls_private_key.ssh.private_key_pem
  filename             = "${path.module}/bit_casino_ec2_private.pem"
  file_permission      = "0400"
  directory_permission = "0700"
}

# Figure out what's the AMI for our EC2 instance
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
  key_name                    = aws_key_pair.ssh.key_name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
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

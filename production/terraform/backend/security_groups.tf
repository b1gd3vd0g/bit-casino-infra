# Create a security group for the EC2 instance, allowing SSH and app traffic.
resource "aws_security_group" "ec2_sg" {
  name        = "bit-casino-ec2-sg"
  description = "Allow SSH and app traffic"
  vpc_id      = aws_vpc.bit_casino.id

  # Allow SSH from all IPs
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  # Allow API Access on relevant ports (60600 - 60603)
  ingress {
    description = "Allow CloudFront Access to player microservice."
    from_port   = 60600
    to_port     = 60600
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow CloudFront Access to currency microservice."
    from_port   = 60601
    to_port     = 60601
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow CloudFront Access to reward microservice."
    from_port   = 60602
    to_port     = 60602
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow CloudFront Access to slots microservice."
    from_port   = 60603
    to_port     = 60603
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Do not allow egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow Access to RDS"
  vpc_id      = aws_vpc.bit_casino.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "redis_sg" {
  name   = "redis-sg"
  vpc_id = aws_vpc.bit_casino.id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

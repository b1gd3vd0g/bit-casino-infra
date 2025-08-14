resource "aws_vpc" "bit_casino" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.bit_casino.id
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.bit_casino.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-1a"
}

resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.bit_casino.id
  cidr_block              = "10.0.101.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-west-1a"
}

resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.bit_casino.id
  cidr_block              = "10.0.102.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-west-1c"
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.bit_casino.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

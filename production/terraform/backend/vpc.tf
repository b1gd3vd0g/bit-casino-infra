# Create a VPC to house the databases and backend APIs.
resource "aws_vpc" "bit_casino" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.bit_casino.id
}

# Create a public subnet, for the APIs.
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.bit_casino.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.bit_casino.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


# Create two private subnets, for the databases (two availability zones reqd for RDS).
resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.bit_casino.id
  cidr_block              = "10.0.101.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-west-2a"
}

resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.bit_casino.id
  cidr_block              = "10.0.102.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-west-2c"
}

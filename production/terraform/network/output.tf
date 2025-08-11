output "vpc_id" {
  value = aws_vpc.bit_casino.id
}

output "public_subnet_a_id" {
  value = aws_subnet.public_a.id
}

output "private_subnet_a_id" {
  value = aws_subnet.private_a.id
}

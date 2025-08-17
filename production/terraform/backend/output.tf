output "rds_endpoint" {
  value = aws_db_instance.postgres.address
}

output "redis_endpoint" {
  value = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "vpc_id" {
  value = aws_vpc.bit_casino.id
}

output "pub_subnet_id" {
  value = aws_subnet.public.id
}

output "priv_subnet_a_id" {
  value = aws_subnet.private_a.id
}

output "priv_subnet_b_id" {
  value = aws_subnet.private_b.id
}


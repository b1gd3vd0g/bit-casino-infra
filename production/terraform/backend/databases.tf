# A subnet group to house the RDS instance (must include two availability zones)
resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "bit-casino-rds-subnet-group"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
}

# Create the RDS instance with a single postgres database - "bit_casino_player_ms".
# NOTE: Following the creation of this database instance, it needs to be connected to, and the
# tables need to be migrated to both databases.
resource "aws_db_instance" "postgres" {
  identifier             = "bit-casino-postgres"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t4g.micro"
  allocated_storage      = 20
  username               = "b1gd3vd0g"
  password               = var.player_db_password
  db_name                = "bit_casino_player_db"
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}

# A subnet group to house the redis instance.
resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name = "bit-casino-redis-subnet-group"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
}

# Create the redis instance.
resource "aws_elasticache_cluster" "redis" {
  cluster_id         = "bit-casino-redis"
  engine             = "redis"
  node_type          = "cache.t4g.micro"
  num_cache_nodes    = 1
  subnet_group_name  = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids = [aws_security_group.redis_sg.id]
}

# Outputs: How to access these databases
output "rds_endpoint" {
  value = aws_db_instance.postgres.address
}

output "redis_endpoint" {
  value = aws_elasticache_cluster.redis.cache_nodes[0].address
}

# 1. DB Subnet Group
# Grouping the private subnets so RDS knows where to place the instance.
resource "aws_db_subnet_group" "default" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# 2. RDS Instance (MySQL)
resource "aws_db_instance" "default" {
  identifier        = "${var.project_name}-rds"
  allocated_storage = 20
  storage_type      = "gp2"
  engine            = "mysql"
  engine_version    = "8.0" # Or "5.7" depending on preference
  instance_class    = "db.t3.micro" # Free tier eligible
  
  db_name             = var.db_name
  username            = var.db_username
  password            = var.db_password
  
  # Networking
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [var.db_security_group_id]
  publicly_accessible    = false # STRICTLY PRIVATE
  
  # Reliability & Maintenance
  multi_az               = false # Set to true for Production
  skip_final_snapshot    = true  # CRITICAL for dev/test to allow easy destroy
  
  tags = {
    Name = "${var.project_name}-rds"
  }
}
output "db_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.default.address
}

output "db_name" {
  value = aws_db_instance.default.db_name
}
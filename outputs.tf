output "db_endpoint" {
  description = "RDS instance endpoint (hostname:port)"
  value       = aws_db_instance.this.endpoint
}

output "db_address" {
  description = "RDS instance hostname"
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "RDS instance port"
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.this.db_name
}

output "db_username" {
  description = "Database master username"
  value       = aws_db_instance.this.username
  sensitive   = true
}

output "db_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.this.id
}

output "db_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.this.arn
}

output "db_password" {
  description = "Database master password (sensitive — stored encrypted in S3 state)"
  value       = var.db_password
  sensitive   = true
}

output "db_connection_info" {
  description = "Connection info for the application (set these as environment variables)"
  value = {
    DATABASE_HOST = aws_db_instance.this.address
    DATABASE_PORT = tostring(aws_db_instance.this.port)
    DATABASE_NAME = aws_db_instance.this.db_name
    DATABASE_USER = aws_db_instance.this.username
  }
  sensitive = true
}

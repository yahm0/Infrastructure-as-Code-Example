output "rds_instance_id" {
  description = "The ID of the RDS instance"
  value       = aws_db_instance.this.id
}

output "rds_endpoint" {
  description = "The connection endpoint of the RDS instance"
  value       = aws_db_instance.this.endpoint
}

output "rds_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.this.arn
}

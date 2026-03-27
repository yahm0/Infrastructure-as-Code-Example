output "log_group_name" {
  description = "The name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.this.name
}

output "log_group_arn" {
  description = "The ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.this.arn
}

output "sns_topic_arn" {
  description = "The ARN of the alarms SNS topic (if enabled)"
  value       = var.enable_alarms ? aws_sns_topic.alarms[0].arn : ""
}

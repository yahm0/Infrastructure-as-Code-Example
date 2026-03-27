output "trail_arn" {
  description = "The ARN of the CloudTrail trail"
  value       = aws_cloudtrail.this.arn
}

output "s3_bucket_name" {
  description = "The S3 bucket name storing CloudTrail logs"
  value       = aws_s3_bucket.trail.id
}

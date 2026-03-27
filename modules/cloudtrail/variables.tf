variable "trail_name" {
  description = "Name of the CloudTrail trail"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name for CloudTrail logs"
  type        = string
}

variable "is_multi_region" {
  description = "Whether the trail captures events from all regions"
  type        = bool
  default     = false
}

variable "force_destroy" {
  description = "Whether to force-destroy the S3 bucket on deletion"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

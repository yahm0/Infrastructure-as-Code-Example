variable "log_group_name" {
  description = "Name of the CloudWatch log group"
  type        = string
}

variable "retention_in_days" {
  description = "Number of days to retain log events (0 = never expire)"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to the log group"
  type        = map(string)
  default     = {}
}

# --- Alarm Variables ---

variable "enable_alarms" {
  description = "Whether to create CloudWatch alarms and SNS topic"
  type        = bool
  default     = false
}

variable "alarm_prefix" {
  description = "Prefix for alarm names"
  type        = string
  default     = ""
}

variable "alarm_email" {
  description = "Email address for alarm notifications (leave empty to skip)"
  type        = string
  default     = ""
}

variable "ec2_instance_id" {
  description = "EC2 instance ID for CPU alarm (leave empty to skip)"
  type        = string
  default     = ""
}

variable "rds_instance_id" {
  description = "RDS instance identifier for alarms (leave empty to skip)"
  type        = string
  default     = ""
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix for 5xx alarm (leave empty to skip)"
  type        = string
  default     = ""
}

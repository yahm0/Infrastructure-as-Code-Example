variable "domain_name" {
  description = "The domain name for the hosted zone"
  type        = string
}

variable "create_zone" {
  description = "Whether to create a new hosted zone or use an existing one"
  type        = bool
  default     = true
}

variable "record_name" {
  description = "DNS record name (e.g. app.example.com)"
  type        = string
  default     = ""
}

variable "alb_dns_name" {
  description = "DNS name of the ALB for alias record"
  type        = string
  default     = ""
}

variable "alb_zone_id" {
  description = "Route53 zone ID of the ALB"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

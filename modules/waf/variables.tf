variable "name" {
  description = "Name of the WAF Web ACL"
  type        = string
}

variable "description" {
  description = "Description of the WAF Web ACL"
  type        = string
  default     = "WAF Web ACL with AWS managed rules"
}

variable "alb_arn" {
  description = "ARN of the ALB to associate with the WAF"
  type        = string
}

variable "rate_limit" {
  description = "Maximum number of requests per 5-minute period per IP"
  type        = number
  default     = 2000
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

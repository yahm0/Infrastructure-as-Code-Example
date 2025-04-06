
variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "assume_role_services" {
  description = "Service or services that can assume the role"
  type        = any
}

variable "policy_name" {
  description = "Name of the IAM policy"
  type        = string
}

variable "policy_description" {
  description = "Description of the IAM policy"
  type        = string
}

variable "policy_document" {
  description = "IAM policy document in JSON"
  type        = string
}

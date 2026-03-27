
variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "assume_role_services" {
  description = "Service(s) that can assume the role (e.g. \"ec2.amazonaws.com\" or [\"ec2.amazonaws.com\", \"lambda.amazonaws.com\"])"
  type        = list(string)
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

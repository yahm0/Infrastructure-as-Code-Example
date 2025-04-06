# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"  # Change this to your desired region
}

# Configure terraform backend (optional)
terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # Update to your desired version
    }
  }

  # Uncomment and configure if you want to use remote state
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "dev/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

# Variables
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# VPC Resources
resource "aws_vpc" "main" {
  # Add your VPC configuration here
}

# Subnet Resources
resource "aws_subnet" "public" {
  # Add your public subnet configuration here
}

resource "aws_subnet" "private" {
  # Add your private subnet configuration here
}

# Security Group Resources
resource "aws_security_group" "example" {
  # Add your security group configuration here
}

# EC2 Resources
resource "aws_instance" "example" {
  # Add your EC2 instance configuration here
}

# Output values
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

# Add any additional resources you need below

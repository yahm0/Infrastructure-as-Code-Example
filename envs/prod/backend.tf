# Option 1: Terraform Cloud (recommended)
# terraform {
#   backend "remote" {
#     hostname     = "app.terraform.io"
#     organization = "your-org-name"
#
#     workspaces {
#       name = "infrastructure-prod"
#     }
#   }
# }

# Option 2: S3 + DynamoDB (self-managed)
# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket"
#     key            = "prod/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-locks"
#     encrypt        = true
#   }
# }

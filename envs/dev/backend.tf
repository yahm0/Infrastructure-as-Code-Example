# Uncomment after running: make bootstrap PROJECT=myproject REGION=us-east-1
# terraform {
#   backend "s3" {
#     bucket         = "myproject-terraform-state"
#     key            = "dev/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "myproject-terraform-locks"
#     encrypt        = true
#   }
# }

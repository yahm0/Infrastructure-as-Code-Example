terraform {
  backend "s3" {
    bucket         = "myproject-terraform-state"
    key            = "staging/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "myproject-terraform-locks"
    encrypt        = true
  }
}

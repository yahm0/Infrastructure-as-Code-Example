run "creates_vpc_with_correct_cidr" {
  command = plan

  module {
    source = "../modules/vpc"
  }

  variables {
    vpc_name       = "test-vpc"
    vpc_cidr       = "10.99.0.0/16"
    public_subnets = ["10.99.1.0/24"]
    private_subnets = ["10.99.101.0/24"]
    azs            = ["us-east-1a"]
  }

  assert {
    condition     = aws_vpc.main.cidr_block == "10.99.0.0/16"
    error_message = "VPC CIDR block did not match expected value."
  }

  assert {
    condition     = aws_vpc.main.enable_dns_support == true
    error_message = "DNS support should be enabled."
  }

  assert {
    condition     = aws_vpc.main.enable_dns_hostnames == true
    error_message = "DNS hostnames should be enabled."
  }
}

run "creates_correct_number_of_subnets" {
  command = plan

  module {
    source = "../modules/vpc"
  }

  variables {
    vpc_name       = "test-vpc"
    vpc_cidr       = "10.99.0.0/16"
    public_subnets = ["10.99.1.0/24", "10.99.2.0/24"]
    private_subnets = ["10.99.101.0/24", "10.99.102.0/24"]
    azs            = ["us-east-1a", "us-east-1b"]
  }

  assert {
    condition     = length(aws_subnet.public) == 2
    error_message = "Expected 2 public subnets."
  }

  assert {
    condition     = length(aws_subnet.private) == 2
    error_message = "Expected 2 private subnets."
  }
}

run "rds_encryption_enabled" {
  command = plan

  module {
    source = "../modules/rds"
  }

  variables {
    db_name              = "testdb"
    username             = "admin"
    password             = "test-password-12345"
    vpc_security_group_ids = ["sg-12345"]
    db_subnet_group_name   = "test-subnet-group"
    storage_encrypted      = true
  }

  assert {
    condition     = aws_db_instance.this.storage_encrypted == true
    error_message = "RDS storage encryption should be enabled."
  }
}

run "rds_not_publicly_accessible" {
  command = plan

  module {
    source = "../modules/rds"
  }

  variables {
    db_name              = "testdb"
    username             = "admin"
    password             = "test-password-12345"
    vpc_security_group_ids = ["sg-12345"]
    db_subnet_group_name   = "test-subnet-group"
    publicly_accessible    = false
  }

  assert {
    condition     = aws_db_instance.this.publicly_accessible == false
    error_message = "RDS should not be publicly accessible."
  }
}

run "rds_deletion_protection_configurable" {
  command = plan

  module {
    source = "../modules/rds"
  }

  variables {
    db_name              = "testdb"
    username             = "admin"
    password             = "test-password-12345"
    vpc_security_group_ids = ["sg-12345"]
    db_subnet_group_name   = "test-subnet-group"
    deletion_protection    = true
  }

  assert {
    condition     = aws_db_instance.this.deletion_protection == true
    error_message = "RDS deletion protection should be enabled when configured."
  }
}

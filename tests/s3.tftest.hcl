run "creates_encrypted_bucket" {
  command = plan

  module {
    source = "../modules/s3"
  }

  variables {
    bucket_name       = "test-bucket-12345"
    enable_versioning = true
  }

  assert {
    condition     = aws_s3_bucket_server_side_encryption_configuration.this.rule[0].apply_server_side_encryption_by_default[0].sse_algorithm == "AES256"
    error_message = "S3 bucket should use AES256 encryption."
  }
}

run "blocks_public_access" {
  command = plan

  module {
    source = "../modules/s3"
  }

  variables {
    bucket_name = "test-bucket-12345"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.block_public_acls == true
    error_message = "Public ACLs should be blocked."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.block_public_policy == true
    error_message = "Public policy should be blocked."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.restrict_public_buckets == true
    error_message = "Public buckets should be restricted."
  }
}

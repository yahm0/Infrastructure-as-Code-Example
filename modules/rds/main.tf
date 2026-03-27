
resource "aws_db_instance" "this" {
  allocated_storage    = var.allocated_storage
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  db_name              = var.db_name
  username             = var.username
  password             = var.password
  parameter_group_name = var.parameter_group_name
  skip_final_snapshot  = var.skip_final_snapshot
  publicly_accessible  = var.publicly_accessible

  # Security
  storage_encrypted = var.storage_encrypted

  # High availability
  multi_az = var.multi_az

  # Backups
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window

  # Maintenance
  maintenance_window = var.maintenance_window

  # Networking
  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name   = var.db_subnet_group_name

  tags = var.tags
}

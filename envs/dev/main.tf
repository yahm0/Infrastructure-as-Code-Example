terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }
}

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# --- Networking ---

module "vpc" {
  source = "../../modules/vpc"

  vpc_name                 = "${var.environment}-vpc"
  vpc_cidr                 = var.vpc_cidr
  public_subnets           = var.public_subnets
  private_subnets          = var.private_subnets
  azs                      = var.azs
  enable_nat_gateway       = var.enable_nat_gateway
  enable_flow_logs         = true
  flow_logs_retention_days = 14
}

# --- Security Groups ---

module "web_sg" {
  source = "../../modules/security-groups"

  name        = "${var.environment}-web-sg"
  description = "Allow HTTP/HTTPS inbound, all outbound"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  tags = merge(local.common_tags, {
    Name = "${var.environment}-web-sg"
  })
}

module "db_sg" {
  source = "../../modules/security-groups"

  name        = "${var.environment}-db-sg"
  description = "Allow MySQL/PostgreSQL from web tier only"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = var.public_subnets # restrict to app tier CIDRs
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  tags = merge(local.common_tags, {
    Name = "${var.environment}-db-sg"
  })
}

# --- Database ---

resource "aws_db_subnet_group" "this" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = module.vpc.private_subnet_ids

  tags = merge(local.common_tags, {
    Name = "${var.environment}-db-subnet-group"
  })
}

module "rds" {
  source = "../../modules/rds"

  db_name                 = "${var.environment}db"
  username                = var.db_username
  password                = var.db_password
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  parameter_group_name    = var.db_parameter_group_name
  skip_final_snapshot     = true # OK for dev — override in prod
  publicly_accessible     = false
  storage_encrypted       = true
  multi_az                = false
  backup_retention_period = 1
  deletion_protection     = false
  vpc_security_group_ids  = [module.db_sg.security_group_id]
  db_subnet_group_name    = aws_db_subnet_group.this.name

  tags = merge(local.common_tags, {
    Name = "${var.environment}-rds"
  })
}

# --- Compute ---

module "ec2" {
  source = "../../modules/ec2"

  ami                         = var.ec2_ami
  instance_type               = var.ec2_instance_type
  subnet_id                   = module.vpc.public_subnet_ids[0]
  security_group_ids          = [module.web_sg.security_group_id]
  associate_public_ip_address = true

  tags = merge(local.common_tags, {
    Name = "${var.environment}-web-server"
  })
}

# --- Storage ---

module "s3" {
  source = "../../modules/s3"

  bucket_name       = "${var.environment}-${var.project_name}-assets"
  enable_versioning = true
}

# --- Logging & Monitoring ---

module "cloudwatch" {
  source = "../../modules/cloudwatch"

  log_group_name    = "/${var.environment}/${var.project_name}"
  retention_in_days = 14

  enable_alarms   = true
  alarm_prefix    = var.environment
  alarm_email     = var.alarm_email
  ec2_instance_id = module.ec2.instance_id
  rds_instance_id = module.rds.rds_instance_id
  alb_arn_suffix  = replace(module.alb.alb_arn, "/.*:loadbalancer\\//", "")

  tags = local.common_tags
}

# --- Load Balancer ---

module "alb" {
  source = "../../modules/alb"

  name              = "${var.environment}-alb"
  internal          = false
  security_groups   = [module.web_sg.security_group_id]
  subnets           = module.vpc.public_subnet_ids
  vpc_id            = module.vpc.vpc_id
  health_check_path = var.health_check_path
  certificate_arn   = var.certificate_arn

  tags = merge(local.common_tags, {
    Name = "${var.environment}-alb"
  })
}

# --- IAM ---

module "ec2_role" {
  source = "../../modules/iam"

  role_name            = "${var.environment}-ec2-role"
  assume_role_services = ["ec2.amazonaws.com"]
  policy_name          = "${var.environment}-ec2-policy"
  policy_description   = "EC2 instance policy for ${var.environment}"

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

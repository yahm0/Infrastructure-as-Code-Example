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
}

# --- Networking ---

module "vpc" {
  source = "../../modules/vpc"

  vpc_name           = "${var.environment}-vpc"
  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  azs                = var.azs
  enable_nat_gateway = var.enable_nat_gateway
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

  tags = {
    Name        = "${var.environment}-web-sg"
    Environment = var.environment
  }
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
      cidr_blocks = var.public_subnets
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

  tags = {
    Name        = "${var.environment}-db-sg"
    Environment = var.environment
  }
}

# --- Database ---

resource "aws_db_subnet_group" "this" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = module.vpc.private_subnet_ids

  tags = {
    Name        = "${var.environment}-db-subnet-group"
    Environment = var.environment
  }
}

module "rds" {
  source = "../../modules/rds"

  db_name                = "${var.environment}db"
  username               = var.db_username
  password               = var.db_password
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  parameter_group_name   = var.db_parameter_group_name
  skip_final_snapshot    = true
  publicly_accessible    = false
  storage_encrypted      = true
  multi_az               = true
  backup_retention_period = 7
  vpc_security_group_ids = [module.db_sg.security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.this.name

  tags = {
    Name        = "${var.environment}-rds"
    Environment = var.environment
  }
}

# --- Compute ---

module "ec2" {
  source = "../../modules/ec2"

  ami                         = var.ec2_ami
  instance_type               = var.ec2_instance_type
  subnet_id                   = module.vpc.public_subnet_ids[0]
  security_group_ids          = [module.web_sg.security_group_id]
  associate_public_ip_address = true

  tags = {
    Name        = "${var.environment}-web-server"
    Environment = var.environment
  }
}

# --- Storage ---

module "s3" {
  source = "../../modules/s3"

  bucket_name       = "${var.environment}-${var.project_name}-assets"
  enable_versioning = true
}

# --- Logging ---

module "cloudwatch" {
  source = "../../modules/cloudwatch"

  log_group_name    = "/${var.environment}/${var.project_name}"
  retention_in_days = 30

  tags = {
    Environment = var.environment
  }
}

# --- Load Balancer ---

module "alb" {
  source = "../../modules/alb"

  name            = "${var.environment}-alb"
  internal        = false
  security_groups = [module.web_sg.security_group_id]
  subnets         = module.vpc.public_subnet_ids

  tags = {
    Name        = "${var.environment}-alb"
    Environment = var.environment
  }
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

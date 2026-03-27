# AWS Infrastructure as Code (IaC) Template

Terraform template for provisioning a secure, modular AWS environment. Follows AWS Well-Architected Framework patterns with environment separation and reusable modules.

---

## Features

- Modular Terraform code (VPC, RDS, IAM, S3, EC2, ALB, CloudWatch, Security Groups)
- Environment separation (dev / staging / prod) with isolated state
- Remote backend support (Terraform Cloud or S3 + DynamoDB locking)
- Encrypted S3 buckets with blocked public access
- Private subnets with optional NAT Gateway
- Parameterized variables with per-environment defaults
- GitHub Actions CI/CD pipeline template
- Pre-commit hooks (fmt, validate, tflint, tfsec)

---

## Architecture Overview

This template deploys:

- A custom VPC with public and private subnets across multiple AZs
- Internet Gateway for public access, optional NAT Gateway for private egress
- Application Load Balancer in public subnets
- EC2 instances with security group controls
- RDS database in private subnets (MySQL by default)
- Encrypted S3 bucket for assets
- CloudWatch log groups
- Least-privilege IAM roles and policies

> Remote Terraform state can be stored in Terraform Cloud or S3 with DynamoDB locking.

![Architecture Diagram](docs/architecture.mermaid)

---

## Repository Structure

```
infrastructure-as-code-aws/
├── modules/                    # Reusable Terraform modules
│   ├── alb/                    # Application Load Balancer
│   ├── cloudwatch/             # CloudWatch Log Groups
│   ├── ec2/                    # EC2 Instances
│   ├── iam/                    # IAM Roles & Policies
│   ├── rds/                    # RDS Database
│   ├── s3/                     # S3 Buckets
│   ├── security-groups/        # Security Groups
│   └── vpc/                    # VPC, Subnets, IGW, NAT
├── envs/                       # Environment configurations
│   ├── dev/
│   ├── staging/
│   └── prod/
│       ├── main.tf             # Module calls with env-specific values
│       ├── variables.tf        # Variable definitions with defaults
│       ├── outputs.tf          # Output exports
│       ├── backend.tf          # Remote state config (commented)
│       ├── terraform.tfvars    # Your values (git-ignored)
│       └── terraform.tfvars.example  # Template to copy
├── .github/workflows/
│   └── terraform.yml           # CI/CD pipeline
├── provider.tf                 # Root provider config
├── .pre-commit-config.yaml
├── .gitignore
├── LICENSE
└── README.md
```

---

## Quick Start

1. **Clone the repo:**
   ```bash
   git clone https://github.com/your-org/infrastructure-as-code-aws.git
   cd infrastructure-as-code-aws/envs/dev
   ```

2. **Create your tfvars:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. **Configure backend** (optional):
   Uncomment your preferred backend in `backend.tf` (Terraform Cloud or S3).

4. **Deploy:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

---

## Environment Differences

| Setting              | Dev           | Staging       | Prod             |
|----------------------|---------------|---------------|------------------|
| VPC CIDR             | 10.0.0.0/16   | 10.1.0.0/16   | 10.2.0.0/16      |
| AZs                  | 2             | 2             | 3                |
| NAT Gateway          | Off           | On            | On               |
| RDS Instance         | db.t3.micro   | db.t3.small   | db.t3.medium     |
| RDS Storage          | 20 GB         | 50 GB         | 100 GB           |
| Skip Final Snapshot  | Yes           | Yes           | **No**           |
| EC2 Instance         | t3.micro      | t3.small      | t3.medium        |
| Log Retention        | 14 days       | 30 days       | 90 days          |

---

## Secrets

Pass sensitive values via environment variables instead of tfvars:

```bash
export TF_VAR_db_password="your-secure-password"
```

For CI/CD, store these as GitHub Actions secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `DB_PASSWORD`
- `TF_API_TOKEN` (if using Terraform Cloud)

---

## License

MIT — see [LICENSE](LICENSE).

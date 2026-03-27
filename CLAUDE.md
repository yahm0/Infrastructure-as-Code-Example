# CLAUDE.md

## Project Overview

Terraform infrastructure-as-code for AWS. Manages VPC, EC2/ASG, RDS, S3, ALB, IAM, CloudWatch, CloudTrail, and WAF across three environments (dev, staging, prod).

## Repository Structure

- `modules/` — Reusable Terraform modules (one resource concern per module)
- `envs/{dev,staging,prod}/` — Environment-specific configurations calling shared modules
- `scripts/` — Operational scripts (backend bootstrap)
- `tests/` — Terraform native tests (`.tftest.hcl`)
- `.github/workflows/` — CI/CD pipelines

## Conventions

- **Module pattern**: Each module has `main.tf`, `variables.tf`, `outputs.tf`. Keep modules focused on a single AWS resource type.
- **Naming**: Resources use `${var.environment}-<purpose>` pattern (e.g. `dev-web-sg`, `prod-rds`).
- **Tagging**: All resources get `Environment`, `Project`, and `ManagedBy` tags via `default_tags` in the provider block plus `local.common_tags`.
- **State**: Remote S3 backend with DynamoDB locking. Each environment has isolated state.
- **Secrets**: Never hardcode. Use `TF_VAR_db_password` env var or GitHub Actions secrets.

## Common Commands

```bash
make plan ENV=dev          # Plan for dev
make apply ENV=staging     # Apply for staging
make validate-all          # Validate all environments
make fmt                   # Format all .tf files
make docs                  # Generate module README docs
make checkov               # Run security scan
make bootstrap PROJECT=myproject REGION=us-east-1  # One-time backend setup
```

## Key Differences Between Environments

- **dev**: Single EC2, no NAT, no WAF, no CloudTrail, 14-day logs, no deletion protection
- **staging**: Single EC2, NAT enabled, CloudTrail, 30-day logs, multi-AZ RDS
- **prod**: ASG (auto-scaling), NAT, WAF, CloudTrail (multi-region), 90-day logs, deletion protection, multi-AZ RDS

## When Adding a New Module

1. Create `modules/<name>/` with `main.tf`, `variables.tf`, `outputs.tf`
2. Call the module from each environment's `main.tf` as needed
3. Add new variables to each `envs/*/variables.tf` with sensible defaults
4. Update `envs/*/terraform.tfvars.example` with the new variables
5. Add tests in `tests/<name>.tftest.hcl`
6. Run `make docs` to regenerate module documentation

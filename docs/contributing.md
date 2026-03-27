# Contributing Guide

## Getting Started

1. Clone the repository
2. Install prerequisites:
   - [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5.0
   - [pre-commit](https://pre-commit.com/#install)
   - [TFLint](https://github.com/terraform-linters/tflint)
   - [tfsec](https://github.com/aquasecurity/tfsec)
   - [terraform-docs](https://terraform-docs.io/)
   - [Checkov](https://www.checkov.io/) (optional)
3. Install pre-commit hooks:
   ```bash
   pre-commit install
   ```

## Development Workflow

1. Create a feature branch from `main`
2. Make your changes
3. Run formatting and validation:
   ```bash
   make fmt
   make validate-all
   ```
4. Run pre-commit hooks:
   ```bash
   make pre-commit
   ```
5. Commit and push
6. Open a pull request against `main`

## Pull Request Process

- PRs trigger format checks, validation, security scans, and plan generation for all environments
- Review the Terraform plan output in the CI logs
- Infracost will comment with cost impact (if configured)
- Get at least one approval before merging
- Merging to `main` triggers auto-apply

## Code Conventions

### File Structure

Each module follows this structure:
```
modules/<name>/
  main.tf          # Resource definitions
  variables.tf     # Input variables
  outputs.tf       # Output values
```

Each environment follows this structure:
```
envs/<env>/
  main.tf                    # Module calls
  variables.tf               # Variable definitions with env-specific defaults
  outputs.tf                 # Output exports
  backend.tf                 # Remote state configuration
  terraform.tfvars.example   # Template for local overrides
```

### Naming Conventions

- **Resources**: `${var.environment}-<purpose>` (e.g. `dev-web-sg`, `prod-rds`)
- **Modules**: Lowercase with hyphens (e.g. `security-groups`, `cloudwatch`)
- **Variables**: Snake case (e.g. `db_instance_class`, `enable_nat_gateway`)
- **Outputs**: Snake case matching the resource attribute (e.g. `vpc_id`, `alb_dns_name`)

### Tagging

All resources must include these tags (applied via `default_tags` in the provider):
- `Environment` — dev, staging, or prod
- `Project` — project name
- `ManagedBy` — "terraform"

Use `local.common_tags` and `merge()` for resource-specific tags.

### Security

- Never commit secrets, credentials, or `.tfvars` files
- Mark sensitive variables with `sensitive = true`
- Use `TF_VAR_` environment variables for secrets
- All S3 buckets must have encryption and public access blocking
- RDS must not be publicly accessible
- Production RDS must have `deletion_protection = true`

## Adding a New Module

1. Create `modules/<name>/` with `main.tf`, `variables.tf`, `outputs.tf`
2. Follow existing module patterns for variable naming and tagging
3. Add the module call to each relevant environment's `main.tf`
4. Add corresponding variables to each environment's `variables.tf`
5. Update `terraform.tfvars.example` files
6. Write tests in `tests/<name>.tftest.hcl`
7. Run `make docs` to generate module documentation
8. Update the repository structure section in `README.md`

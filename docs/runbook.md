# Operations Runbook

## Day-to-Day Operations

### Deploying Changes

```bash
# 1. Make your changes
# 2. Format and validate
make fmt
make validate-all

# 3. Plan (always review before apply)
make plan ENV=dev

# 4. Apply
make apply ENV=dev
```

### Promoting Changes Across Environments

Always deploy in order: **dev → staging → prod**.

```bash
make plan ENV=dev && make apply ENV=dev
make plan ENV=staging && make apply ENV=staging
make plan ENV=prod && make apply ENV=prod
```

---

## Common Procedures

### Rotating the Database Password

1. Generate a new password
2. Update the password in AWS Secrets Manager / your secrets store
3. Update the GitHub Actions secret `DB_PASSWORD`
4. Apply the change:
   ```bash
   export TF_VAR_db_password="new-password-here"
   make plan ENV=<env>
   make apply ENV=<env>
   ```
5. Update application configuration to use the new password
6. Verify connectivity

### Scaling EC2 Instances (Production)

Production uses an Auto Scaling Group. To adjust capacity:

1. Update `envs/prod/terraform.tfvars`:
   ```hcl
   asg_desired_capacity = 4
   asg_min_size         = 2
   asg_max_size         = 8
   ```
2. Apply:
   ```bash
   make plan ENV=prod
   make apply ENV=prod
   ```

### Adding HTTPS (TLS)

1. Request an ACM certificate in the AWS Console or via Terraform
2. Set the certificate ARN in your tfvars:
   ```hcl
   certificate_arn = "arn:aws:acm:us-east-1:123456789:certificate/abc-123"
   ```
3. Apply — the ALB will automatically configure an HTTPS listener and redirect HTTP → HTTPS

### Adding a New Environment

1. Copy an existing environment directory:
   ```bash
   cp -r envs/dev envs/newenv
   ```
2. Update `envs/newenv/variables.tf` defaults (environment name, CIDR blocks, etc.)
3. Update `envs/newenv/backend.tf` with a unique state key
4. Add the new environment to the CI matrix in `.github/workflows/terraform.yml`
5. Initialize and deploy:
   ```bash
   make init ENV=newenv
   make plan ENV=newenv
   make apply ENV=newenv
   ```

---

## Disaster Recovery

### RDS Restore from Snapshot

1. Identify the snapshot in the AWS Console (RDS → Snapshots)
2. Note the snapshot identifier
3. Restore via AWS CLI:
   ```bash
   aws rds restore-db-instance-from-db-snapshot \
     --db-instance-identifier prod-restored-db \
     --db-snapshot-identifier <snapshot-id>
   ```
4. Update DNS or application config to point to the restored instance
5. Import the restored instance into Terraform state if needed:
   ```bash
   terraform import module.rds.aws_db_instance.this prod-restored-db
   ```

### Full Infrastructure Recovery

1. Ensure the S3 state bucket and DynamoDB lock table exist (run `make bootstrap` if needed)
2. Initialize and apply each environment:
   ```bash
   for env in dev staging prod; do
     cd envs/$env
     terraform init
     terraform apply -auto-approve
     cd ../..
   done
   ```

---

## Troubleshooting

### Terraform State Lock

If you see "Error acquiring the state lock":

```bash
# Find the lock ID from the error message, then:
terraform force-unlock <LOCK_ID>
```

Only use this if you're certain no other apply is running.

### Drift Detected

The drift detection workflow runs on weekday mornings and creates GitHub issues when drift is found.

1. Review the issue to understand what changed
2. If the change was intentional (manual hotfix), update Terraform to match:
   ```bash
   terraform import <resource> <id>  # if a new resource was added manually
   ```
3. If the change was unintentional, re-apply to restore the desired state:
   ```bash
   make apply ENV=<env>
   ```

### RDS Deletion Protection

Production RDS has `deletion_protection = true`. To destroy:

1. Set `deletion_protection = false` in `envs/prod/main.tf`
2. Apply: `make apply ENV=prod`
3. Then run destroy: `make destroy ENV=prod`

.PHONY: help fmt validate plan apply destroy init clean docs lint

ENV ?= dev

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

fmt: ## Format all Terraform files
	terraform fmt -recursive

lint: ## Run TFLint across all environments
	@for env in dev staging prod; do \
		echo "==> Linting $$env..."; \
		cd envs/$$env && terraform init -backend=false > /dev/null 2>&1 && cd ../..; \
	done
	@echo "Done."

validate: ## Validate Terraform config for ENV (default: dev)
	cd envs/$(ENV) && terraform init -backend=false && terraform validate

validate-all: ## Validate all environments
	@for env in dev staging prod; do \
		echo "==> Validating $$env..."; \
		cd envs/$$env && terraform init -backend=false && terraform validate && cd ../..; \
	done

init: ## Initialize Terraform for ENV (default: dev)
	cd envs/$(ENV) && terraform init

plan: ## Run terraform plan for ENV (default: dev)
	cd envs/$(ENV) && terraform plan

plan-dev: ## Plan for dev
	$(MAKE) plan ENV=dev

plan-staging: ## Plan for staging
	$(MAKE) plan ENV=staging

plan-prod: ## Plan for prod
	$(MAKE) plan ENV=prod

apply: ## Apply changes for ENV (default: dev)
	cd envs/$(ENV) && terraform apply

apply-dev: ## Apply for dev
	$(MAKE) apply ENV=dev

apply-staging: ## Apply for staging
	$(MAKE) apply ENV=staging

apply-prod: ## Apply for prod (requires confirmation)
	cd envs/prod && terraform apply

destroy: ## Destroy infrastructure for ENV (default: dev) — use with caution
	cd envs/$(ENV) && terraform destroy

docs: ## Generate module documentation with terraform-docs
	@for dir in modules/*/; do \
		echo "==> Generating docs for $$dir"; \
		terraform-docs markdown table "$$dir" > "$$dir/README.md"; \
	done

clean: ## Remove .terraform directories
	find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	find . -name ".terraform.lock.hcl" -not -path "./envs/*" -delete 2>/dev/null || true

bootstrap: ## Create S3 backend and DynamoDB lock table
	@bash scripts/bootstrap-backend.sh $(PROJECT) $(REGION)

pre-commit: ## Run pre-commit hooks
	pre-commit run --all-files

checkov: ## Run Checkov security scan
	checkov -d . --framework terraform --quiet

infracost: ## Estimate cost for ENV (default: dev)
	cd envs/$(ENV) && infracost breakdown --path .

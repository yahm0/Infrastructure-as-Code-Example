# 🏗️ AWS Infrastructure as Code (IaC) Example

This project provisions a secure, scalable, and modular AWS environment using [Terraform](https://www.terraform.io/). It follows AWS best practices for cloud infrastructure design, including network segmentation, encryption, IAM governance, and environment separation.

---

## 🧩 Features

- ✅ Modular Terraform code (VPC, RDS, IAM, S3, EC2)
- ✅ Remote backend support (S3 + DynamoDB locking)
- ✅ Encrypted S3 buckets with blocked public access
- ✅ Private subnets for secure database deployment
- ✅ Parameterized environment variables (`dev`, `prod`)
- ✅ Follows the AWS Well-Architected Framework

---

## 📐 Architecture Overview

This IaC stack deploys a foundational cloud environment with:

- A custom VPC with public and private subnets
- NAT and Internet Gateways
- An encrypted S3 bucket
- A PostgreSQL RDS instance in a private subnet
- EC2 bastion host (optional)
- Least-privilege IAM roles and instance profiles

> 🔒 Remote Terraform state is stored in an S3 bucket with state locking via DynamoDB.

![Architecture Diagram](docs/architecture.png)

---

## 📁 Repository Structure

```bash
infrastructure-as-code-aws/
├── modules/                # Reusable modules
│   ├── vpc/
│   ├── rds/
│   ├── iam/
│   └── s3/
├── envs/                   # Environment-specific configs
│   └── dev/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── terraform.tfvars
├── backend.tf              # Remote backend config
├── provider.tf             # AWS provider setup
├── .gitignore
├── LICENSE
└── README.md

#!/usr/bin/env bash
set -euo pipefail

# Bootstrap Terraform remote state backend (S3 + DynamoDB)
# Run once per AWS account to create the state bucket and lock table.
#
# Usage:
#   ./scripts/bootstrap-backend.sh <project-name> [region]
#
# Example:
#   ./scripts/bootstrap-backend.sh myproject us-east-1

PROJECT="${1:?Usage: $0 <project-name> [region]}"
REGION="${2:-us-east-1}"
BUCKET="${PROJECT}-terraform-state"
TABLE="${PROJECT}-terraform-locks"

echo "==> Creating S3 bucket: ${BUCKET} in ${REGION}"
if aws s3api head-bucket --bucket "${BUCKET}" 2>/dev/null; then
  echo "    Bucket already exists, skipping."
else
  aws s3api create-bucket \
    --bucket "${BUCKET}" \
    --region "${REGION}" \
    $([ "${REGION}" != "us-east-1" ] && echo "--create-bucket-configuration LocationConstraint=${REGION}")

  aws s3api put-bucket-versioning \
    --bucket "${BUCKET}" \
    --versioning-configuration Status=Enabled

  aws s3api put-bucket-encryption \
    --bucket "${BUCKET}" \
    --server-side-encryption-configuration '{
      "Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]
    }'

  aws s3api put-public-access-block \
    --bucket "${BUCKET}" \
    --public-access-block-configuration '{
      "BlockPublicAcls": true,
      "IgnorePublicAcls": true,
      "BlockPublicPolicy": true,
      "RestrictPublicBuckets": true
    }'

  echo "    Bucket created and configured."
fi

echo "==> Creating DynamoDB table: ${TABLE} in ${REGION}"
if aws dynamodb describe-table --table-name "${TABLE}" --region "${REGION}" >/dev/null 2>&1; then
  echo "    Table already exists, skipping."
else
  aws dynamodb create-table \
    --table-name "${TABLE}" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "${REGION}"

  echo "    Table created."
fi

echo ""
echo "==> Done! Update each envs/*/backend.tf with:"
echo ""
echo "  terraform {"
echo "    backend \"s3\" {"
echo "      bucket         = \"${BUCKET}\""
echo "      key            = \"<env>/terraform.tfstate\""
echo "      region         = \"${REGION}\""
echo "      dynamodb_table = \"${TABLE}\""
echo "      encrypt        = true"
echo "    }"
echo "  }"

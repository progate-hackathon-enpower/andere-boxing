#!/bin/bash

# Bootstrap terraform state を参照して、backend configuration を取得・適用
# このスクリプトは各環境ディレクトリで実行してください

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_DIR="$SCRIPT_DIR/../bootstrap"
PROJECT_NAME=${1:-"andere-boxing"}
AWS_REGION=${2:-"ap-northeast-1"}
AUTO_INIT=${3:-"true"}  # true の場合は自動的に terraform init を実行

if [ ! -f "$BOOTSTRAP_DIR/terraform.tfstate" ]; then
  echo "Error: Bootstrap terraform state not found at $BOOTSTRAP_DIR/terraform.tfstate"
  echo "Please run: cd $BOOTSTRAP_DIR && terraform init && terraform apply"
  exit 1
fi

# Bootstrap outputs から bucket name と table name を抽出
BUCKET_NAME=$(cd "$BOOTSTRAP_DIR" && terraform output -raw bucket_name 2>/dev/null)
TABLE_NAME=$(cd "$BOOTSTRAP_DIR" && terraform output -raw dynamodb_table_name 2>/dev/null)

if [ -z "$BUCKET_NAME" ] || [ -z "$TABLE_NAME" ]; then
  echo "Error: Could not retrieve backend configuration from bootstrap state"
  exit 1
fi

CURRENT_ENV=$(basename $(pwd))
BACKEND_KEY="${CURRENT_ENV}/terraform.tfstate"

echo "Backend configuration found:"
echo "  Bucket: $BUCKET_NAME"
echo "  Table: $TABLE_NAME"
echo "  Region: $AWS_REGION"
echo "  Key: $BACKEND_KEY"
echo ""

if [ "$AUTO_INIT" = "true" ] || [ "$AUTO_INIT" = "1" ]; then
  echo "Initializing terraform with backend configuration..."
  terraform init \
    -backend-config="bucket=$BUCKET_NAME" \
    -backend-config="key=$BACKEND_KEY" \
    -backend-config="region=$AWS_REGION" \
    -backend-config="dynamodb_table=$TABLE_NAME" \
    -backend-config="encrypt=true"
  echo ""
  echo "✅ Terraform initialized successfully!"
else
  echo "To initialize terraform, run:"
  echo ""
  echo "terraform init \\"
  echo "  -backend-config=\"bucket=$BUCKET_NAME\" \\"
  echo "  -backend-config=\"key=$BACKEND_KEY\" \\"
  echo "  -backend-config=\"region=$AWS_REGION\" \\"
  echo "  -backend-config=\"dynamodb_table=$TABLE_NAME\" \\"
  echo "  -backend-config=\"encrypt=true\""
fi


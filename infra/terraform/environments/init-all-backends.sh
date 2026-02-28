#!/bin/bash

# 全環境の terraform backend を初期化するスクリプト

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENVIRONMENTS=("network" "app" "eks" "shared" "lambda" "argocd")

echo "🚀 Initializing Terraform backends for all environments..."
echo ""

for env in "${ENVIRONMENTS[@]}"; do
  ENV_DIR="$SCRIPT_DIR/$env"
  if [ -d "$ENV_DIR" ]; then
    echo "📦 Initializing $env environment..."
    cd "$ENV_DIR"
    bash ../init-backend.sh
    echo "✅ $env environment initialized"
    echo ""
  else
    echo "⚠️  $env environment directory not found, skipping..."
    echo ""
  fi
done

echo "🎉 All environments initialized successfully!"
echo ""
echo "Next steps:"
echo "  1. Run terraform plan in each environment:"
echo "     cd network && terraform plan -var-file terraform.tfvars"
echo "     cd ../app && terraform plan -var-file terraform.tfvars"
echo "     cd ../eks && terraform plan -var-file terraform.tfvars"
echo "     cd ../shared && terraform plan -var-file terraform.tfvars"
echo ""
echo "  2. Review the plans and apply when ready:"
echo "     terraform apply -var-file terraform.tfvars"

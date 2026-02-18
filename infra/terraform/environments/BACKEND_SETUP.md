# Terraform Backend Configuration Helper

各環境の terraform init を簡単にするためのスクリプトと設定です。

## 前提条件

1. bootstrap が実行済み
   ```bash
   cd infra/terraform/bootstrap
   terraform apply
   ```

## 使い方

### 方法 1: 自動スクリプト使用（推奨）

```bash
cd infra/terraform/environments/network

# スクリプトで backend config を確認
bash ../init-backend.sh

# 出力されたコマンドをコピーして実行
terraform init \
  -backend-config="bucket=andere-boxing-terraform-state-123456789" \
  -backend-config="key=network/terraform.tfstate" \
  -backend-config="region=ap-northeast-1" \
  -backend-config="dynamodb_table=andere-boxing-terraform-locks" \
  -backend-config="encrypt=true"
```

### 方法 2: bootstrap outputs から直接取得

```bash
cd infra/terraform/bootstrap

# bucket name を確認
terraform output -raw bucket_name
# Output: andere-boxing-terraform-state-123456789

# table name を確認
terraform output -raw dynamodb_table_name
# Output: andere-boxing-terraform-locks

# それを使って各環境を初期化
cd ../environments/network
terraform init \
  -backend-config="bucket=$(cd ../../bootstrap && terraform output -raw bucket_name)" \
  -backend-config="key=network/terraform.tfstate" \
  -backend-config="region=ap-northeast-1" \
  -backend-config="dynamodb_table=$(cd ../../bootstrap && terraform output -raw dynamodb_table_name)" \
  -backend-config="encrypt=true"
```

## Deterministic Naming

bucket name は以下のフォーマットで自動生成されます：

```
${project_name}-terraform-state-${aws_account_id}
```

例: `andere-boxing-terraform-state-123456789012`

これにより、複数の環境でも同じバケットを参照でき、各環境のtfstateは異なる key で管理されます。

## GitHub Actions での活用

```yaml
- name: Get Backend Config
  id: backend
  run: |
    cd infra/terraform/bootstrap
    echo "bucket=$(terraform output -raw bucket_name)" >> $GITHUB_OUTPUT
    echo "table=$(terraform output -raw dynamodb_table_name)" >> $GITHUB_OUTPUT

- name: Terraform Init
  working-directory: infra/terraform/environments/network
  env:
    TF_BUCKET: ${{ steps.backend.outputs.bucket }}
    TF_TABLE: ${{ steps.backend.outputs.table }}
  run: |
    terraform init \
      -backend-config="bucket=$TF_BUCKET" \
      -backend-config="key=network/terraform.tfstate" \
      -backend-config="region=ap-northeast-1" \
      -backend-config="dynamodb_table=$TF_TABLE" \
      -backend-config="encrypt=true"
```

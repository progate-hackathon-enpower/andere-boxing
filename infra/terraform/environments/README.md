# Andere Boxing - Terraform Environments

分野ごとに分割されたTerraform構成です。各ディレクトリは独立したtfstateを持ちます。

## ディレクトリ構成

```
environments/
├── network/          # VPC、NAT Gateway、ルートテーブル
├── app/              # ECR、Lambdaなどのアプリケーション層
└── shared/           # IAMロール、その他の共有リソース
```

## 実行順序

1. **network** - VPC とネットワーク基盤を構築
2. **app** - アプリケーション関連のリソース（ECRなど）
3. **shared** - 共有リソース（IAMなど）

## 各環境の初期化方法

### Network

```bash
cd infra/terraform/environments/network

# バックエンド初期化
terraform init \
  -backend-config="bucket=<bucket-name>" \
  -backend-config="key=network/terraform.tfstate" \
  -backend-config="region=ap-northeast-1" \
  -backend-config="dynamodb_table=<table-name>" \
  -backend-config="encrypt=true"

# 実行
terraform plan -var-file terraform.tfvars
terraform apply -var-file terraform.tfvars
```

### App

```bash
cd infra/terraform/environments/app

terraform init \
  -backend-config="bucket=<bucket-name>" \
  -backend-config="key=app/terraform.tfstate" \
  -backend-config="region=ap-northeast-1" \
  -backend-config="dynamodb_table=<table-name>" \
  -backend-config="encrypt=true"

terraform plan -var-file terraform.tfvars
terraform apply -var-file terraform.tfvars
```

### Shared

```bash
cd infra/terraform/environments/shared

terraform init \
  -backend-config="bucket=<bucket-name>" \
  -backend-config="key=shared/terraform.tfstate" \
  -backend-config="region=ap-northeast-1" \
  -backend-config="dynamodb_table=<table-name>" \
  -backend-config="encrypt=true"

terraform plan -var-file terraform.tfvars
terraform apply -var-file terraform.tfvars
```

## tfstate ファイル

各ディレクトリは独立したtfstateを持ちます：
- `network/terraform.tfstate` - ネットワークリソース
- `app/terraform.tfstate` - アプリケーションリソース
- `shared/terraform.tfstate` - 共有リソース

## GitHub Actions ワークフローの例

```yaml
name: Deploy Infrastructure

on:
  push:
    branches: [main]
    paths:
      - 'infra/terraform/**'

jobs:
  network:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: actions/checkout@v4
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: ap-northeast-1
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      - name: Network Terraform
        working-directory: infra/terraform/environments/network
        run: |
          terraform init \
            -backend-config="bucket=${{ secrets.TF_STATE_BUCKET }}" \
            -backend-config="key=network/terraform.tfstate" \
            -backend-config="region=ap-northeast-1" \
            -backend-config="dynamodb_table=${{ secrets.TF_LOCKS_TABLE }}" \
            -backend-config="encrypt=true"
          terraform plan -var-file terraform.tfvars
          terraform apply -auto-approve -var-file terraform.tfvars

  app:
    needs: network
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: actions/checkout@v4
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: ap-northeast-1
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      - name: App Terraform
        working-directory: infra/terraform/environments/app
        run: |
          terraform init \
            -backend-config="bucket=${{ secrets.TF_STATE_BUCKET }}" \
            -backend-config="key=app/terraform.tfstate" \
            -backend-config="region=ap-northeast-1" \
            -backend-config="dynamodb_table=${{ secrets.TF_LOCKS_TABLE }}" \
            -backend-config="encrypt=true"
          terraform plan -var-file terraform.tfvars
          terraform apply -auto-approve -var-file terraform.tfvars

  shared:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: actions/checkout@v4
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: ap-northeast-1
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      - name: Shared Terraform
        working-directory: infra/terraform/environments/shared
        run: |
          terraform init \
            -backend-config="bucket=${{ secrets.TF_STATE_BUCKET }}" \
            -backend-config="key=shared/terraform.tfstate" \
            -backend-config="region=ap-northeast-1" \
            -backend-config="dynamodb_table=${{ secrets.TF_LOCKS_TABLE }}" \
            -backend-config="encrypt=true"
          terraform plan -var-file terraform.tfvars
          terraform apply -auto-approve -var-file terraform.tfvars
```

## 設定ファイルの準備

各ディレクトリで `terraform.tfvars` をカスタマイズしてください。

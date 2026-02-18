# Andere Boxing - Terraform Infrastructure

マルチルートを前提とした、再利用可能なTerraformモジュール構成です。

## ディレクトリ構成

```
infra/terraform/
├── bootstrap/              # S3 バックエンドの初期化
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars.example
├── environments/           # メイン構成ファイル（単一環境）
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
├── modules/               # 再利用可能なモジュール
│   ├── vpc/              # VPC とサブネット
│   ├── nat_gateway/      # NAT ゲートウェイとルートテーブル
│   ├── ecr/              # ECR リポジトリ
│   ├── s3/               # S3 バックエンドリソース
│   └── iam/              # GitHub Actions 用 IAM ロール
└── README.md
```

## ネットワーク構成

```
VPC (10.0.0.0/16)
├── Public Subnet (10.0.0.0/24)
│   └── NAT Gateway, ALB
├── Private Subnet - EKS AZ-a (10.0.10.0/23)
├── Private Subnet - EKS AZ-c (10.0.12.0/23)
├── Private Subnet - Observability (10.0.20.0/23)
│   └── (ECR, Prometheus など)
└── Private Subnet - Lambda (10.0.30.0/22)
```

## セットアップ手順

### 1. 初期化 (Bootstrap)

まず S3 バックエンドを作成します。この手順はローカルで実行する必要があります。

```bash
cd infra/terraform/bootstrap

# 設定ファイルの準備
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars を環境に合わせて編集

# 初期化と実行
terraform init
terraform plan
terraform apply
```

出力された `backend_config` をメモします。

### 2. メイン構成の実行

```bash
cd ../environments

# 設定ファイルの準備
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars を環境に合わせて編集

# バックエンド初期化
terraform init \
  -backend-config="bucket=<bucket-name>" \
  -backend-config="key=terraform.tfstate" \
  -backend-config="region=ap-northeast-1" \
  -backend-config="dynamodb_table=<table-name>" \
  -backend-config="encrypt=true"

# プランと実行
terraform plan
terraform apply
```

## GitHub Actions での利用

GitHub Actions では、AWS 認証情報をコードに含めず、OIDC を使用して認証します。

### IAM ロール ARN の確認

```bash
# メイン構成実行後、以下で IAM ロール ARN を確認
terraform output github_actions_role_arn
```

### GitHub Actions ワークフローの例

```yaml
name: Deploy Infrastructure

on:
  push:
    branches: [main]
    paths:
      - 'infra/terraform/**'

jobs:
  terraform:
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
        with:
          terraform_version: 1.6.0

      - name: Terraform Init
        working-directory: infra/terraform/environments
        run: |
          terraform init \
            -backend-config="bucket=${{ secrets.TF_STATE_BUCKET }}" \
            -backend-config="key=terraform.tfstate" \
            -backend-config="region=ap-northeast-1" \
            -backend-config="dynamodb_table=${{ secrets.TF_LOCKS_TABLE }}" \
            -backend-config="encrypt=true"

      - name: Terraform Plan
        working-directory: infra/terraform/environments
        run: terraform plan -var-file terraform.tfvars

      - name: Terraform Apply
        working-directory: infra/terraform/environments
        if: github.event_name == 'push'
        run: terraform apply -auto-approve -var-file terraform.tfvars
```

### GitHub Secrets の設定

GitHub リポジトリの Settings -> Secrets に以下を追加します：

- `AWS_ROLE_ARN`: terraform output で出力された GitHub Actions IAM ロール ARN
- `TF_STATE_BUCKET`: bootstrap で作成された S3 バケット名
- `TF_LOCKS_TABLE`: bootstrap で作成された DynamoDB テーブル名

## モジュール説明

### vpc
VPC、サブネット、インターネットゲートウェイ、VPC Flow Logs を作成します。

**入力変数:**
- `vpc_cidr`: VPC の CIDR ブロック
- `public_subnet_cidr`, `private_subnet_*_cidr`: 各サブネットの CIDR
- `availability_zone_*`: アベイラビリティゾーン
- `vpc_flow_logs_role_arn`, `vpc_flow_logs_destination`: VPC Flow Logs の設定

### nat_gateway
NAT Gateway、Elastic IP、ルートテーブルを作成します。

**入力変数:**
- `public_subnet_id`: NAT Gateway を配置するサブネット
- `private_subnet_ids`: NAT Gateway 経由でルーティングするサブネット
- `internet_gateway_id`: インターネットゲートウェイの ID

### ecr
ECR リポジトリと ライフサイクルポリシーを作成します。

**入力変数:**
- `repository_names`: リポジトリ名のリスト
- `image_tag_mutability`: イメージタグの可変性 (MUTABLE/IMMUTABLE)
- `scan_on_push`: プッシュ時のスキャン有効化
- `retention_days`: タグなしイメージの保持日数

### s3
S3 バックエンド用のバケットとテーブルを作成します。

**入力変数:**
- `bucket_name`: 状態ファイル保存用のバケット名
- `dynamodb_table_name`: ロック用テーブル名
- `versioning_enabled`: バージョニング有効化
- `sse_algorithm`: 暗号化アルゴリズム

### iam
GitHub Actions 用の IAM ロールとポリシーを作成します。

**入力変数:**
- `github_repository`: GitHub リポジトリ (owner/repo 形式)
- `github_role_name`: IAM ロール名

## トラブルシューティング

### バックエンド初期化エラー

```
Error: Error reading S3 Bucket in account xxx: AccessDenied
```

IAM ユーザーに S3 と DynamoDB の権限があるか確認してください。

### VPC Flow Logs エラー

IAM ロール `vpc_flow_logs_role` が正しく作成されているか確認してください。

## 今後の拡張

- EKS クラスタ
- RDS（データベース）
- Lambda 関数
- CloudFront + S3（静的コンテンツ配信）
- Prometheus/Grafana（モニタリング）

<p align="center">
  <img
    src="https://github.com/user-attachments/assets/bce54061-e001-40b4-a349-08cd9acfc901"
    alt="image"
    width="400"
  />
</p>

<h1 align="center">
  <ruby>
    突き<rt>ラッシュ</rt>
  </ruby>
  の速さ比べか？
</h1>

Apple Watch のセンサーデータをトリガーに、iOS アプリ経由で Rust 製の低遅延同期サーバーと通信し、Web UI 上でアバター同士をリアルタイムに対戦させる格闘ゲーム。

## 使用技術一覧

<p align="center">
  <img src="https://img.shields.io/badge/Swift-F05138?logo=swift&logoColor=white" alt="Swift" />
  <img src="https://img.shields.io/badge/Rust-000000?logo=rust&logoColor=white" alt="Rust" />
  <img src="https://img.shields.io/badge/React_19-61DAFB?logo=react&logoColor=black" alt="React" />
  <img src="https://img.shields.io/badge/TypeScript-3178C6?logo=typescript&logoColor=white" alt="TypeScript" />
  <img src="https://img.shields.io/badge/Vite_7-646CFF?logo=vite&logoColor=white" alt="Vite" />
  <img src="https://img.shields.io/badge/Tailwind_CSS_4-06B6D4?logo=tailwindcss&logoColor=white" alt="TailwindCSS" />
  <img src="https://img.shields.io/badge/Cloudflare_Workers-F38020?logo=cloudflare&logoColor=white" alt="Cloudflare" />
  <img src="https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=white" alt="Kubernetes" />
  <img src="https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white" alt="Docker" />
</p>

## アーキテクチャ

```
[Apple Watch (watchOS)]  --->  [iOS アプリ (Swift)]
                                       |  WebTransport (UDP:7000-8000)
                                       v
[Web UI (React/TanStack)]  <---  [sync-server (Rust)]  <---  [Kubernetes + Agones]
   対戦描画・観戦              Protocol Buffers            サーバー割り当て
```

## 環境一覧

| カテゴリ | 技術 | バージョン |
|---|---|---|
| iOS / watchOS | Swift / SwiftUI | - |
| 同期サーバー | Rust / wtransport / Tokio / prost | Edition 2024 |
| Web | React / TanStack Start / Vite / Tailwind CSS | 19 / 1.132 / 7 / 4 |
| インフラ | Kubernetes / Agones / ArgoCD / Cloudflare Workers | - |

## ディレクトリ構成

```
apps/
├── andere-boxing/    # iOS / watchOS アプリ (Swift)
├── sync-server/      # リアルタイム同期サーバー (Rust)
├── web/              # Web フロントエンド (React)
└── proto/            # Protocol Buffers 定義
infra/
├── argocd/           # Kubernetes マニフェスト
└── terraform/        # IaC
```

## 開発環境構築

### 前提条件

- Rust (Edition 2024)
- Node.js + pnpm
- Xcode (iOS / watchOS ビルド用)

### sync-server

```bash
cd apps/sync-server
cargo run
```

### Web

```bash
cd apps/web
pnpm install
pnpm dev
```

## 環境変数一覧

| 変数名 | 説明 | デフォルト |
|---|---|---|
| `AGONES_ALLOCATOR_HOST` | Agones Allocator のホスト | - |
| `AGONES_ALLOCATOR_PORT` | Agones Allocator のポート | - |
| `DISCORD_WEBHOOK_URL` | Discord 通知用 Webhook URL | - |

## 概要

## 画面構成
1. Web

`イメージ１`
![image]()

2. モバイル

`イメージ２`
![image]()

3. 対戦

`イメージ３`
![image]()

# 🛠 技術スタック
🔗 [リポジトリ]()


## フロントエンド（Web）
| 項目 | 技術 |
|---|---|
| 言語 | TypeScript |
| フレームワーク | React 19 + TanStack Start / Router |
| ビルドツール | Vite |
| スタイリング | TailwindCSS |
| 2D グラフィックス | PixiJS（ゲーム描画） |
| 通信 | Protocol Buffers（protobufjs） |
| パッケージマネージャー | pnpm |
| デプロイ先 | AWS Lambda |

## フロントエンド（モバイル）
| 項目 | 技術 |
|---|---|
| 言語 | Swift |
| フレームワーク | SwiftUI |
| 対応プラットフォーム | iOS / watchOS |
| センサー連携 | Apple Watch モーションセンサー |
| デバイス間通信 | WatchConnectivity（iOS ↔ watchOS） |
| サーバー通信 | WebTransport（UDP） |

## バックエンド
| 項目 | 技術 |
|---|---|
| 言語 | Rust |
| 非同期ランタイム | Tokio |
| 通信プロトコル | WebTransport（wtransport） |
| シリアライゼーション | Protocol Buffers（prost） |
| ゲームサーバー管理 | Agones SDK |
| ログ・トレーシング | tracing |

## インフラ
| 項目 | 技術 |
|---|---|
| クラウド | AWS（東京リージョン） |
| オーケストレーション | Kubernetes（EKS） |
| ゲームサーバースケーリング | Agones |
| GitOps | ArgoCD |
| IaC | Terraform |
| コンテナレジストリ | Amazon ECR |
| CI/CD | GitHub Actions |

## ML


# AI活用
・`.claude/CLAUDE.md`  + `.claude/rules/` で、基本の規則とコーディング規則を分けた。`rules/`以下の方はファイルパスや言語に対して自動適用される。

・`claude-code-action` を使った PR 自動レビューワークフローを入れた。人間が怒られる時代になってしまった。(´･ω･`)

![image](https://ptera-publish.topaz.dev/project/01KHRD2MK5ZPXF9VXP3JQV7EGB.png)
![image](https://ptera-publish.topaz.dev/project/01KHRD93Q2SWW8BXKB4CZY5WJQ.png)

## GitHub Agentic Workflow
[2/16に出ていた記事](https://github.blog/jp/2026-02-16-automate-repository-tasks-with-github-agentic-workflows/) を読んで導入してみた。

### 作った仕組み
**・PR マージ後に README の更新要否を判断して、よしなに更新 PR を作成してくれるやつ：**

立ち止まれてえらい：
![image](https://ptera-publish.topaz.dev/project/01KHRCM1CDBF99Y4JV9EYV54CT.png)

**・毎日定時にリポジトリの状態を分析し「Repo Report」としてIssueを発行してくれるやつ：**

`report` ラベルをトリガーに Discord へ自動配信する仕組みも組み合わせた：
![image](https://ptera-publish.topaz.dev/project/01KHRCRH948110PBWG5H1M4YG6.png)

## CI/CD
### TopazのCD <=NEW!!!!
topazのmdを、actionsで指定したmdの内容で置き換え自動更新する仕組みを作成しました。

topazの認証フローを理解し、actionsのflowとして公開しています。
[詳しくはこちら](https://github.com/mono0218/topaz-md-cicd)


# 技術的挑戦
・

# チームメンバーからひとこと

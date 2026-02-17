---
on:
  schedule: daily

permissions:
  contents: read
  issues: read
  pull-requests: read

safe-outputs:
  create-issue:
    title-prefix: "[repo status] "
    labels: [report]

tools:
  github:
---

# 日次リポジトリステータスレポート

メンテナー向けの日次ステータスレポートを作成してください。

以下を含めること
- 最近のリポジトリ活動（Issue、PR、ディスカッション、リリース、コード変更）
- 進捗の追跡、目標のリマインダーとハイライト
- プロジェクトの状況と推奨事項
- メンテナー向けの具体的な次のアクション

簡潔にまとめ、関連するIssue/PRへのリンクを含めてください。

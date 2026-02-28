# Issue 作成ルール

## タグ一覧

| ラベル | 対象領域 |
|---|---|
| `web-front` | Web フロントエンド (React / PixiJS / TanStack) |
| `backend` | バックエンド / sync-server (Rust) |
| `infra` | インフラ (Kubernetes / Agones / ArgoCD / Terraform) |
| `mobile` | iOS / watchOS アプリ (Swift) |
| `llm` | LLM・AI 関連機能 |

## テンプレート

```markdown
## 概要

<!-- このタスクで何を達成するかを 1〜2 文で説明する -->

## タスク

- [ ] 具体的な作業項目 1
- [ ] 具体的な作業項目 2

## 関連 PR / Issue

<!-- 関連する PR・Issue があればリンクする -->
```

## 作成コマンド

```bash
gh issue create \
  --repo progate-hackathon-enpower/andere-boxing \
  --title "feat|fix|chore: タイトル" \
  --label "web-front" \
  --body "..."
```

## 作成ルール

- タイトルは `feat:` / `fix:` / `chore:` などの prefix を付ける
- ラベルは上記タグ一覧から該当するものを選ぶ（複数可）
- タスク項目は具体的・チェックボックス形式で書く
- PR 作成時は `Closes #issue番号` を PR の body 冒頭に記載して紐付ける

---
paths: [apps/sync-server/**/*.rs]
---

# Rust コーディング規約

## 基本方針

- `cargo clippy` の警告を残さない
- `unwrap()` は本番コードで使用しない。`?` 演算子または適切なエラーハンドリングを使う
- `unsafe` は原則禁止。やむを得ない場合は理由をコメントで明記する

## 命名規則

| 対象 | ケース | 例 |
|---|---|---|
| 変数・関数 | snake_case | `get_user_name` |
| 型・トレイト | PascalCase | `GameSession` |
| 定数 | UPPER_SNAKE_CASE | `MAX_PLAYERS` |
| モジュール | snake_case | `game_logic` |

## 非同期処理

- Tokio ランタイムを使用する
- チャネル経由のメッセージパッシングを優先し、共有状態のロックは最小限にする

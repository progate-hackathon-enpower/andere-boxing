---
paths: [apps/web/**/*.{ts,tsx}]
---

# TypeScript コーディング規約

## 型定義

- `any` は使用禁止。`unknown` を使い、型ガードで絞り込む
- 関数の引数と返り値には明示的に型を付ける
- `interface` よりも `type` を優先する（union や intersection が必要な場面が多いため）

## 命名規則

| 対象 | ケース | 例 |
|---|---|---|
| 変数・関数 | camelCase | `getUserName` |
| 型・コンポーネント | PascalCase | `UserProfile` |
| 定数 | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT` |
| ファイル (コンポーネント) | PascalCase | `UserProfile.tsx` |
| ファイル (その他) | camelCase / kebab-case | `utils.ts`, `use-auth.ts` |

## インポート

- パスエイリアス `@/*` → `./src/*` を使用する
- 外部モジュール → 内部モジュール → 相対パスの順に並べる

## React

- 関数コンポーネントのみ使用する（クラスコンポーネント禁止）
- hooks のルールを遵守する（条件分岐内で hooks を呼ばない）
- コンポーネントの props は `type` で定義する

---
paths: [apps/web/**/*.{ts,tsx}]
---

# TypeScript コーディング規約

## 型定義

- `any`と`unknown`は禁止。できる限り既存の型を使いつつ、ない場合は作成する。
- 関数の引数と返り値には明示的に型を付ける
- `interface` よりも `type` を優先する（union や intersection が必要な場面が多いため）
- PixiJS スプライトシートのモーション名などは、文字列リテラルの Union 型（例: type Motion \= 'idle' | 'walk' | 'attack'）で定義し、型の安全性を確保する。

## 命名規則

| 対象 | ケース | 例 |
|---|---|---|
| 変数・関数 | camelCase | `getUserName` |
| 型・コンポーネント | PascalCase | `UserProfile` |
| 定数 | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT` |
| ファイル (コンポーネント) | PascalCase | `UserProfile.tsx` |
| ファイル (その他) | camelCase / kebab-case | `utils.ts`, `use-auth.ts` |
| Asset定義 | UPPER_SNAKE_CASE | PLAYER_SPRITE_SHEET |

## インポート

- パスエイリアス `@/*` → `./src/*` を使用する
- 外部モジュール → 内部モジュール → 相対パスの順に並べる

## React & PixiJS

## React & PixiJS

- 関数コンポーネントのみ使用する。
- hooks のルールを遵守する。
- コンポーネントの props は type で定義する。

### PixiJS 運用ルール

- 描画とロジックの分離: 座標計算や当たり判定などの「毎フレームの更新」は useTick 内で行い、Ref（useRef）を使用して値を保持する。React の State 更新は、UI（HPバー等）の同期や画面遷移など、描画頻度が低いものに限定する。
- リソース管理: テクスチャやスプライトシートのロードは、ゲーム開始前の loader または useEffect で一括で行い、コンポーネント内での動的生成を避ける。
- クリーンアップ: useEffect を使用して、コンポーネントのアンマウント時に必ず PixiJS のインスタンスやリスナー（キーボードイベント等）を破棄（.destroy()）する。
- コンポーネント設計: @pixi/react のコンポーネント（Sprite, Container 等）をラップして独自コンポーネントを作成する際は、再利用性を高めるために x, y, rotation などの基本プロパティを透過的に扱えるようにする。


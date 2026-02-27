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


## フロントエンド

## バックエンド

## インフラ

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


# 技術的挑戦
・

# チームメンバーからひとこと

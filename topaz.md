# 👊 概要

### ____それは、スタンドバトルの心理戦！

> Apple Watch の加速度センサーをトリガーに、iOS アプリ経由で Rust 製の低遅延同期サーバーと通信し、リアルタイムにラッシュバトルを体感できる、**『私たちの夢』** です。

## web UIのスクショ

`スタート画面`
![image](https://ptera-publish.topaz.dev/project/01KJK4F6Y59JGWHRCW0AVCBJVW.png)

`対戦画面`
![image](https://ptera-publish.topaz.dev/project/01KJKHY05E6D9QTY5GWZN2M3ZF.png)


# 🛠 技術スタック

![image](https://ptera-publish.topaz.dev/project/01KJK4J47W61F1DWKYE937CX3Z.png)

## フロントエンド（Web）
![image](https://ptera-publish.topaz.dev/project/01KJK4MHC9R18WVBVKDMKF2V52.png)


## フロントエンド（モバイル）
![image](https://ptera-publish.topaz.dev/project/01KJK4K3HAZ81C4PFS2R374XQR.png)

## バックエンド
![image](https://ptera-publish.topaz.dev/project/01KJK4NCM3EHJ335JPSJ08TWTT.png)

## インフラ
![image](https://ptera-publish.topaz.dev/project/01KJK4P1EPMFYS250P28CE57FG.png)

`構成図`
![image](https://ptera-publish.topaz.dev/project/01KJKJXVQTS34PDDD5PTA31AEF.png)

## （ML）
AppleWatchで「時間軸、ユーザー加速度、回転速度」の情報を持つCSVから、CoreMLでモデルを作成。ユーザーがパンチしたり、パンチに似た他の動作をしたりした時、動作を識別し、適切な操作を可能にし...ようとしていました。（後述）


# 🤖 AI活用
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

### スプライト画像生成
Nano Banana 2にスプライト画像を作らせた。

`結果/プロンプト`
![image](https://ptera-publish.topaz.dev/project/01KJK51NYEARGQWSN8AJTH1258.png)

## CI/CD
### ArgoCD（GitOps）
GitHub リポジトリの `infra/argocd/` 配下にある Kubernetes マニフェストを ArgoCD が監視し、変更があれば自動で EKS クラスタに同期する GitOps 構成を採用。`ApplicationSet` でディレクトリを自動検出し、`selfHeal` と `prune` を有効にすることで、手動変更の自動復旧や不要リソースの削除も実現している。

### DockerのECR Push
sync-server（Rust 製の対戦同期サーバー）を GitHub Actions でビルドし、AWS ECR にプッシュするパイプラインを構築。Rust のマルチステージビルドでイメージサイズを最小化し、GitHub Actions Cache（`cache-from/to: type=gha`）でビルド時間を短縮。PR 時はビルドのみ、main マージ時にプッシュする制御を入れている。

### lambrollを用いたPreviewURL
Web フロントを Nitro の `aws-lambda` プリセットでビルドし、lambroll で Lambda にデプロイ。PR ごとに `pr-{番号}` のエイリアスを作成して独立した Function URL を発行し、Preview URL として PR コメントに自動投稿する仕組みを実現。PR クローズ時にはエイリアスと Function URL を自動削除してクリーンアップする。

### TopazのCD <=NEW!!!!
topazのmdを、actionsで指定したmdの内容で置き換え自動更新する仕組みを作成しました。

topazの認証フローを理解し、actionsのflowとして公開しています。
[詳しくはこちら](https://github.com/mono0218/topaz-md-cicd)

# 😭 苦労した点
**Apple Watchでの開発がキビしすぎる**
最初はパンチ/防御/Core MLを使った機械学習を予定しており、[専用のデータ収集用アプリ](https://github.com/progate-hackathon-enpower/CollectOraOraData)なども作っていたのですが、途中からどのメンバーもApple watchとの接続が不安定になり、学習データの取り出しができなくなりました。
加速度を取得するシンプルな方針に切り替えて、ことなきを得ました。（大事！）

**どのタイミングで寝るかの判断**

# ✍️ チームメンバーからひとこと

### yomi4486
・ProtoBufferを初めて開発で使った。面白い。
・CoreMLを初めて使った。Apple製品だけで速攻で学習モデルが作れるのすごい。
・iOSでネイティブにHTTP/3 + QUICでWebTransportサーバーに接続可能にした。

### mono0218
・個人開発で培ったProtoBufferとその型を使ってイベント駆動のおかげで、安定したシステムを作成できた。
・疎結合の設計にしたとこで、分業をすることができ、夜寝れた。
・三人で1年間開発してきたので、issueやPRを適切なタイミングできれるようになった。

### まる
・ProtoBuffer, WebTransportが初めてでした。
・ゲーム作り/Pixi.jsが初めてでした。状態管理が難しかったけど、スプライトが動いて超嬉しかったです。
・AI活用点を稼ぐために最新の公式ドキュメントを読みました。
・**中間発表時間使いすぎてすみませんでした...**




# Protocol Buffers Swift 統合手順

## 生成・追加されたファイル

✅ **自動生成されたファイル**:
- `apps/andere-boxing/andere-boxing/Generated/event.pb.swift` (7480 bytes)
  - `AndereBoxing_NetworkEvent`: ネットワークイベントのメインメッセージ
  - `AndereBoxing_UserAction`: ユーザーアクション (PUNCH, DEFEND)
  - `AndereBoxing_RoomAction`: ルームアクション (CREATE, START, END, JOIN, LEAVE, DELETE)

✅ **ヘルパーファイル（コメントアウト済み）**:
- `apps/andere-boxing/andere-boxing/NetworkEventHelpers.swift`
  - NetworkEvent の便利な拡張メソッド（static ファクトリメソッド）
  - イベント説明やバリデーション用のプロパティ
  
- `apps/andere-boxing/andere-boxing/WebTransportManager.swift`
  - Protocol Buffers メッセージ送受信用の extension（ファイル末尾にコメント化して追加済み）

## Xcode プロジェクトへの統合手順

### 1. SwiftProtobuf パッケージを追加

1. Xcode で `andere-boxing.xcodeproj` を開く
2. プロジェクト設定 → `andere-boxing` ターゲットを選択
3. "Package Dependencies" タブをクリック
4. "+" ボタンをクリック
5. 以下の URL を入力:
   ```
   https://github.com/apple/swift-protobuf.git
   ```
6. バージョンを `1.35.1` 以上に設定
7. "Add Package" をクリック
8. `SwiftProtobuf` を `andere-boxing` ターゲットに追加

### 2. Generated フォルダをプロジェクトに追加

1. Xcode のプロジェクトナビゲーターで `andere-boxing` フォルダを右クリック
2. "Add Files to 'andere-boxing'..." を選択
3. `Generated` フォルダを選択
4. "Create folder references" を選択
5. ターゲット `andere-boxing` にチェックを入れる
6. "Add" をクリック

### 3. コメント部分を有効化

SwiftProtobuf を追加し、Generated フォルダをプロジェクトに追加したら、以下のファイルのコメント部分を解除してください：

1. **NetworkEventHelpers.swift**: ファイル全体のコメント `/* ... */` を削除
2. **WebTransportManager.swift**: ファイル末尾の extension のコメント `/* ... */` を削除

### 4. 使用例

**基本的な使用方法:**

```swift
import SwiftProtobuf

// パンチイベントを作成（ファクトリメソッド使用）
let punchEvent = AndereBoxing_NetworkEvent.punch(
    roomID: "room123",
    userID: "user456"
)

// WebTransport 経由で送信
await WebTransportManager.shared.sendEvent(punchEvent)
```

**便利メソッドを使用:**

```swift
// より簡潔な方法
await WebTransportManager.shared.sendPunchAction(
    roomID: "room123",
    userID: "user456"
)

await WebTransportManager.shared.sendDefendAction(
    roomID: "room123",
    userID: "user456"
)

await WebTransportManager.shared.sendCreateRoomAction(
    roomID: "room789",
    userID: "user456"
)
```

**手動でイベントを作成:**

```swift
// ネットワークイベントを手動で作成
var event = AndereBoxing_NetworkEvent()
event.roomID = "room123"
event.userID = "user456"
event.timestamp = Int64(Date().timeIntervalSince1970 * 1000)
event.userAction = .punch

// バリデーション
if event.isValid {
    print("イベントタイプ: \(event.eventDescription)")  // "イベントタイプ: パンチ"
    
    // シリアライズ（バイナリに変換）
    let data = try event.serializedData()
    
    // または文字列に変換
    let jsonString = try event.jsonString()
    
    // Base64 エンコードして送信
    let base64 = data.base64EncodedString()
    await webTransportManager.sendMessage(base64)
}
```

**受信したデータをデシリアライズ:**

```swift
// バイナリデータから NetworkEvent を復元
do {
    let receivedEvent = try AndereBoxing_NetworkEvent(serializedData: data)
    
    if receivedEvent.hasUserAction {
        print("ユーザーアクション: \(receivedEvent.userAction.displayName)")
    }
    
    if receivedEvent.hasRoomAction {
        print("ルームアクション: \(receivedEvent.roomAction.displayName)")
    }
} catch {
    print("デシリアライズエラー: \(error)")
}
```

## 再生成が必要な場合

`.proto` ファイルを更新した場合は、Makefile を使って Swift コードを再生成できます：

```bash
cd apps/proto
make generate
```

### その他の Makefile コマンド

```bash
# ヘルプを表示
make help

# 生成されたファイルを削除
make clean

# 依存関係のバージョンを確認
make version

# 依存関係をインストール（初回のみ）
make install-deps
```

### 手動で生成する場合

```bash
cd apps/proto
protoc --swift_out=../andere-boxing/andere-boxing/Generated event.proto
```

## トラブルシューティング

### "SwiftProtobuf module not found" エラー

→ SwiftProtobuf パッケージが正しく追加されていません。上記の手順 1 を再確認してください。

### "event.pb.swift" がビルドに含まれない

→ Generated フォルダがターゲット `andere-boxing` に追加されていません。上記の手順 2 を再確認してください。

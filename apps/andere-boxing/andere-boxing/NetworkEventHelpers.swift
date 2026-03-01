//
//  NetworkEventHelpers.swift
//  andere-boxing
//
//  Protocol Buffers NetworkEvent の便利な拡張
//

// ⚠️ この拡張を使用するには、SwiftProtobuf パッケージと Generated/event.pb.swift を
//    Xcode プロジェクトに追加する必要があります。
//    詳細は PROTOBUF_SETUP.md を参照してください。

/*
import Foundation
import SwiftProtobuf

// MARK: - NetworkEvent 拡張

extension AndereBoxing_NetworkEvent {
    /// パンチアクションイベントを作成
    static func punch(roomID: String, userID: String) -> Self {
        var event = Self()
        event.roomID = roomID
        event.userID = userID
        event.timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        event.userAction = .punch
        return event
    }
    
    /// ディフェンドアクションイベントを作成
    static func defend(roomID: String, userID: String) -> Self {
        var event = Self()
        event.roomID = roomID
        event.userID = userID
        event.timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        event.userAction = .defend
        return event
    }
    
    /// ルーム作成イベントを作成
    static func createRoom(roomID: String, userID: String) -> Self {
        var event = Self()
        event.roomID = roomID
        event.userID = userID
        event.timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        event.roomAction = .create
        return event
    }
    
    /// ルーム開始イベントを作成
    static func startRoom(roomID: String, userID: String) -> Self {
        var event = Self()
        event.roomID = roomID
        event.userID = userID
        event.timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        event.roomAction = .start
        return event
    }
    
    /// ルーム終了イベントを作成
    static func endRoom(roomID: String, userID: String) -> Self {
        var event = Self()
        event.roomID = roomID
        event.userID = userID
        event.timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        event.roomAction = .end
        return event
    }
    
    /// ルーム参加イベントを作成
    static func joinRoom(roomID: String, userID: String) -> Self {
        var event = Self()
        event.roomID = roomID
        event.userID = userID
        event.timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        event.roomAction = .join
        return event
    }
    
    /// ルーム退出イベントを作成
    static func leaveRoom(roomID: String, userID: String) -> Self {
        var event = Self()
        event.roomID = roomID
        event.userID = userID
        event.timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        event.roomAction = .leave
        return event
    }
    
    /// ルーム削除イベントを作成
    static func deleteRoom(roomID: String, userID: String) -> Self {
        var event = Self()
        event.roomID = roomID
        event.userID = userID
        event.timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        event.roomAction = .delete
        return event
    }
    
    /// イベントタイプの説明文を取得
    var eventDescription: String {
        if hasUserAction {
            switch userAction {
            case .punch: return "パンチ"
            case .defend: return "防御"
            case .unspecified: return "未指定"
            case .UNRECOGNIZED(let value): return "不明(\(value))"
            }
        } else if hasRoomAction {
            switch roomAction {
            case .create: return "ルーム作成"
            case .start: return "ルーム開始"
            case .end: return "ルーム終了"
            case .join: return "ルーム参加"
            case .leave: return "ルーム退出"
            case .delete: return "ルーム削除"
            case .unspecified: return "未指定"
            case .UNRECOGNIZED(let value): return "不明(\(value))"
            }
        } else {
            return "イベントなし"
        }
    }
    
    /// バリデーション: 必須フィールドがすべて設定されているか確認
    var isValid: Bool {
        guard !roomID.isEmpty, !userID.isEmpty, timestamp > 0 else {
            return false
        }
        
        // 少なくとも1つのアクションが設定されている必要がある
        return hasUserAction || hasRoomAction
    }
}

// MARK: - UserAction 拡張

extension AndereBoxing_UserAction {
    /// 日本語の説明を取得
    var displayName: String {
        switch self {
        case .unspecified: return "未指定"
        case .punch: return "パンチ"
        case .defend: return "防御"
        case .UNRECOGNIZED(let value): return "不明(\(value))"
        }
    }
}

// MARK: - RoomAction 拡張

extension AndereBoxing_RoomAction {
    /// 日本語の説明を取得
    var displayName: String {
        switch self {
        case .unspecified: return "未指定"
        case .create: return "作成"
        case .start: return "開始"
        case .end: return "終了"
        case .delete: return "削除"
        case .join: return "参加"
        case .leave: return "退出"
        case .UNRECOGNIZED(let value): return "不明(\(value))"
        }
    }
}

// MARK: - 使用例（テスト用）

/*
// パンチイベントを作成して送信
let punchEvent = AndereBoxing_NetworkEvent.punch(
    roomID: "room123",
    userID: "user456"
)
await WebSocketManager.shared.sendEvent(punchEvent)

// または便利メソッドを使用
await WebSocketManager.shared.sendPunchAction(
    roomID: "room123",
    userID: "user456"
)

// ルーム作成イベント
let createEvent = AndereBoxing_NetworkEvent.createRoom(
    roomID: "room789",
    userID: "user456"
)
print("イベントタイプ: \(createEvent.eventDescription)")  // "イベントタイプ: ルーム作成"
print("有効: \(createEvent.isValid)")  // true
*/
*/

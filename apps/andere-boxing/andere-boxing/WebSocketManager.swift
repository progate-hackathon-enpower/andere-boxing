import Foundation
import SwiftProtobuf

// MARK: - Message Direction & Types

enum MessageDirection {
    case sent
    case received
}

struct WebSocketMessage: Identifiable {
    let id = UUID()
    let content: String
    let direction: MessageDirection
    let timestamp: Date
}

// MARK: - WebSocket Manager (Alias: WebTransportManager)

/// URLSessionWebSocketTask を使用したWebSocket接続管理
@Observable
@MainActor
class WebSocketManager {
    static let shared = WebSocketManager()

    // MARK: - 接続状態
    var isConnected = false
    var connectionError: String = ""
    var messageInput: String = ""
    private let userID = UUID().uuidString  // ユーザー識別用 UUID

    // MARK: - メッセージ管理
    var sentMessages: [WebSocketMessage] = []
    var receivedMessages: [WebSocketMessage] = []

    // MARK: - Private State
    private var webSocket: URLSessionWebSocketTask?
    private var receiveTask: Task<Void, Never>?
    private var currentRoomID: String?

    // MARK: - Init
    private init() {}

    // MARK: - Connection Methods

    func disconnect() async {
        webSocket?.cancel(with: .goingAway, reason: nil)
        receiveTask?.cancel()
        webSocket = nil
        currentRoomID = nil
        isConnected = false
        connectionError = ""
        print("🛑 WebSocket 接続を切断")
    }

    /// ルーム接続用のWebSocket接続
    func connectToRoom(endpoint: String, roomId: String) async {
        guard webSocket == nil else { return }
        connectionError = ""
        
        print("🚀 ルーム接続を試行中: Room=\(roomId), Endpoint=\(endpoint)")
        
        // URLを作成（https -> wss に変換）
        var wsURLString = endpoint
        if wsURLString.hasPrefix("https://") {
            wsURLString = "wss://" + wsURLString.dropFirst(8)
            print("🔄 [WebSocket] https -> wss 変換: \(endpoint) → \(wsURLString)")
        } else if wsURLString.hasPrefix("http://") {
            wsURLString = "ws://" + wsURLString.dropFirst(7)
            print("🔄 [WebSocket] http -> ws 変換: \(endpoint) → \(wsURLString)")
        } else {
            // プロトコルがない場合はwss://を追加
            wsURLString = "wss://" + wsURLString
            print("🔄 [WebSocket] プロトコル追加: \(endpoint) → \(wsURLString)")
        }
        
        guard let wsURL = URL(string: wsURLString) else {
            connectionError = "無効なエンドポイント形式"
            print("❌ [WebSocket] URL変換失敗: \(wsURLString)")
            return
        }
        
        print("✅ [WebSocket] WebSocket URL生成成功: \(wsURL.absoluteString)")
        
        let webSocket = URLSession.shared.webSocketTask(with: wsURL)
        self.webSocket = webSocket
        self.currentRoomID = roomId
        
        webSocket.resume()
        
        self.isConnected = true
        self.connectionError = ""
        print("✅ WebSocket 接続成功: Room=\(roomId)")
        
        // ルーム参加を通知
        await sendRoomJoinAction(roomID: roomId)
        
        // 受信ループを開始
        startReceiveLoop()
    }

    func sendMessage(_ message: String) async {
        guard !message.isEmpty else { return }
        guard isConnected, let webSocket = webSocket else {
            connectionError = "未接続です"
            return
        }

        let data = Data(message.utf8)
        addSentMessage(message)
        
        print("📤 WebSocket メッセージ送信: \(message)")
        
        do {
            try await webSocket.send(.data(data))
            print("✅ メッセージ送信成功")
        } catch {
            connectionError = "送信失敗: \(error)"
            print("❌ 送信エラー: \(error)")
        }
    }

    // MARK: - Helper Methods

    private func addSentMessage(_ content: String) {
        let msg = WebSocketMessage(
            content: content,
            direction: .sent,
            timestamp: Date()
        )
        sentMessages.append(msg)
    }

    private func addReceivedMessage(_ content: String) {
        let msg = WebSocketMessage(
            content: content,
            direction: .received,
            timestamp: Date()
        )
        receivedMessages.append(msg)
    }

    func clearHistory() {
        sentMessages.removeAll()
        receivedMessages.removeAll()
    }

    // MARK: - Protocol Buffers Actions

    /// ルーム参加アクションを送信
    func sendRoomJoinAction(roomID: String) async {
        guard isConnected, let webSocket = webSocket else {
            connectionError = "未接続です"
            return
        }

        // Protocol Buffers メッセージを構築
        var event = AndereBoxing_NetworkEvent()
        event.roomID = roomID
        event.userID = userID
        event.timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        event.roomAction = .join
        
        do {
            // Protocol Buffers メッセージをバイナリにシリアライズ
            let data = try event.serializedData()
            
            addSentMessage("🏠 ROOM_ACTION_JOIN: Room=\(roomID)")
            print("📤 Protocol Buffers ROOM_ACTION_JOIN 送信中: Room=\(roomID), User=\(userID), Size=\(data.count) bytes")
            
            try await webSocket.send(.data(data))
            print("✅ ROOM_ACTION_JOIN 送信成功")
        } catch {
            connectionError = "ROOM_ACTION_JOIN 送信失敗: \(error)"
            print("❌ ROOM_ACTION_JOIN 送信エラー: \(error)")
        }
    }

    // MARK: - Receive Loop

    private func startReceiveLoop() {
        receiveTask?.cancel()
        receiveTask = Task {
            while isConnected, let webSocket = webSocket {
                do {
                    let message = try await webSocket.receive()
                    
                    switch message {
                    case .data(let data):
                        parseAndHandleData(data)
                    case .string(let text):
                        addReceivedMessage(text)
                        print("📥 WebSocket テキスト受信: \(text)")
                    @unknown default:
                        break
                    }
                } catch {
                    if isConnected {
                        connectionError = "受信エラー: \(error)"
                        print("❌ 受信エラー: \(error)")
                        isConnected = false
                    }
                    break
                }
            }
        }
    }

    private func parseAndHandleData(_ data: Data) {
        // Protocol Buffers として復号化を試みる
        do {
            let event = try AndereBoxing_NetworkEvent(serializedData: data)
            
            // イベント情報をログ用に抽出
            var eventType = "Unknown"
            switch event.event {
            case .userAction(let action):
                eventType = "UserAction: \(action)"
            case .roomAction(let action):
                eventType = "RoomAction: \(action)"
            case nil:
                eventType = "EmptyEvent"
            }
            
            let message = "📦 Event: \(eventType) [roomID: \(event.roomID), userID: \(event.userID)]"
            addReceivedMessage(message)
            print("📥 Protocol Buffers 受信: \(message)")
        } catch {
            // Protocol Buffers として復号化失敗時は文字列として扱う
            if let message = String(data: data, encoding: .utf8) {
                addReceivedMessage(message)
                print("📥 テキスト受信: \(message)")
            }
        }
    }
}

// MARK: - パンチアクション送信

extension WebSocketManager {
    /// パンチアクションを送信
    func sendPunchAction() async {
        guard isConnected, let webSocket = webSocket, let roomID = currentRoomID else {
            print("⚠️ パンチアクション送信スキップ: 未接続またはroomID未設定")
            return
        }
        
        var event = AndereBoxing_NetworkEvent()
        event.roomID = roomID
        event.userID = userID
        event.timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        event.userAction = .punch

        print("🥊 [PUNCH] パンチアクション送信開始: Room=\(roomID), User=\(userID)")
        
        do {
            let data = try event.serializedData()
            addSentMessage("🥊 USER_ACTION_PUNCH")
            try await webSocket.send(.data(data))
            print("✅ [PUNCH] パンチアクション送信成功: Room=\(roomID), Size=\(data.count) bytes")
        } catch {
            print("❌ [PUNCH] パンチアクション送信エラー: \(error)")
            connectionError = "パンチ送信失敗: \(error.localizedDescription)"
        }
    }
}


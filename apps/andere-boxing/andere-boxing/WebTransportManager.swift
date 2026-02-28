import Foundation
import Network
import SwiftProtobuf

// MARK: - WebTransport Message Model

enum MessageDirection {
    case sent
    case received
}

struct WebTransportMessage: Identifiable {
    let id = UUID()
    let content: String
    let direction: MessageDirection
    let timestamp: Date
}

// MARK: - WebTransport Manager

/// Network.framework を使用した QUIC データグラム接続管理
@Observable
@MainActor
class WebTransportManager {
    static let shared = WebTransportManager()

    // MARK: - 接続状態
    var isConnected = false
    var connectionError: String = ""
    var messageInput: String = ""
    private let userID = UUID().uuidString  // ユーザー識別用 UUID

    // MARK: - メッセージ管理
    var sentMessages: [WebTransportMessage] = []
    var receivedMessages: [WebTransportMessage] = []

    // MARK: - Private State
    private var connection: NWConnection?
    private let connectionQueue = DispatchQueue(label: "com.andere-boxing.quic")

    // MARK: - Init
    private init() {}

    // MARK: - Connection Methods

    func disconnect() async {
        connection?.cancel()
        connection = nil
        isConnected = false
        connectionError = ""
        print("🛑 QUIC 接続を切断")
    }

    /// ルーム接続用のQUIC接続（データグラム対応）
    func connectToRoom(endpoint: String, roomId: String) async {
        guard connection == nil else { return }
        connectionError = ""
        
        print("🚀 ルーム接続を試行中: Room=\(roomId), Endpoint=\(endpoint)")
        
        // エンドポイントをパース
        var urlString = endpoint
        if urlString.hasPrefix("https://") {
            urlString.removeFirst(8)
        } else if urlString.hasPrefix("http://") {
            urlString.removeFirst(7)
        }
        
        let components = urlString.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false).map(String.init)
        guard components.count == 2,
              let portNumber = UInt16(components[1]) else {
            connectionError = "無効なエンドポイント形式"
            return
        }
        
        let host = components[0]
        let nwEndpoint = NWEndpoint.hostPort(
            host: NWEndpoint.Host(host),
            port: NWEndpoint.Port(rawValue: portNumber)!
        )
        
        // QUIC パラメータを設定（データグラム対応）
        let quicOptions = NWProtocolQUIC.Options()
        quicOptions.alpn = ["h3"]  // HTTP/3
        
        let parameters = NWParameters(quic: quicOptions)
        parameters.allowLocalEndpointReuse = true
        
        let newConnection = NWConnection(to: nwEndpoint, using: parameters)
        self.connection = newConnection
        
        newConnection.stateUpdateHandler = { [weak self] (state: NWConnection.State) in
            Task { @MainActor in
                switch state {
                case .ready:
                    self?.isConnected = true
                    self?.connectionError = ""
                    print("✅ QUIC 接続成功: Room=\(roomId)")
                    
                    // ルーム参加を通知
                    await self?.sendRoomJoinAction(roomID: roomId)
                    
                    // 受信ループを開始
                    self?.receiveLoop()
                    
                case .waiting(let error):
                    self?.connectionError = "接続待機中: \(error)"
                    print("⏳ 接続待機: \(error)")
                    
                case .failed(let error):
                    self?.isConnected = false
                    self?.connectionError = "接続失敗: \(error)"
                    print("❌ 接続エラー: \(error)")
                    
                case .cancelled:
                    self?.isConnected = false
                    print("🛑 接続キャンセル")
                    
                @unknown default:
                    break
                }
            }
        }
        
        newConnection.start(queue: connectionQueue)
    }

    func sendMessage(_ message: String) async {
        guard !message.isEmpty else { return }
        guard isConnected, let connection = connection else {
            connectionError = "未接続です"
            return
        }

        let data = Data(message.utf8)
        addSentMessage(message)
        
        print("📤 データグラムメッセージ送信: \(message)")
        
        // データグラムとして送信（isComplete: true で1メッセージとして扱う）
        let context = NWConnection.ContentContext.defaultMessage
        
        connection.send(content: data, contentContext: context, isComplete: true, completion: .contentProcessed { [weak self] error in
            if let error = error {
                Task { @MainActor in
                    self?.connectionError = "送信失敗: \(error)"
                    print("❌ 送信エラー: \(error)")
                }
            }
        })
    }

    // MARK: - Helper Methods

    private func addSentMessage(_ content: String) {
        let msg = WebTransportMessage(
            content: content,
            direction: .sent,
            timestamp: Date()
        )
        sentMessages.append(msg)
    }

    private func addReceivedMessage(_ content: String) {
        let msg = WebTransportMessage(
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

    /// ルーム参加アクションを送信（データグラムとして）
    func sendRoomJoinAction(roomID: String) async {
        guard isConnected, let connection = connection else {
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
            
            // データグラムとして送信（isComplete: true で1メッセージとして扱う）
            let context = NWConnection.ContentContext.defaultMessage
            
            connection.send(content: data, contentContext: context, isComplete: true, completion: .contentProcessed { [weak self] error in
                if let error = error {
                    Task { @MainActor in
                        self?.connectionError = "ROOM_ACTION_JOIN 送信失敗: \(error)"
                        print("❌ ROOM_ACTION_JOIN 送信エラー: \(error)")
                    }
                } else {
                    print("✅ ROOM_ACTION_JOIN 送信成功")
                }
            })
        } catch {
            connectionError = "Protocol Buffers シリアライズ失敗: \(error)"
            print("❌ Protocol Buffers シリアライズエラー: \(error)")
        }
    }

    // MARK: - Receive Loop

    private func receiveLoop() {
        guard let connection = connection else { return }
        
        // メッセージ単位で受信（isComplete を待つ）
        connection.receiveMessage { [weak self] data, context, isComplete, error in
            guard let self = self else { return }
            
            Task { @MainActor in
                if let data = data, !data.isEmpty {
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
                        self.addReceivedMessage(message)
                        print("📥 QUIC データグラム Protocol Buffers 受信: \(message)")
                    } catch {
                        // Protocol Buffers として復号化失敗時は文字列として扱う
                        if let message = String(data: data, encoding: .utf8) {
                            self.addReceivedMessage(message)
                            print("📥 QUIC データグラム テキスト受信: \(message)")
                        } else {
                            print("📥 QUIC データグラム バイナリ受信（復号化失敗）: \(data.count) bytes")
                        }
                    }
                }
                
                if let error = error {
                    self.connectionError = "受信エラー: \(error)"
                    print("❌ 受信エラー: \(error)")
                    self.isConnected = false
                    return
                }
                
                // 次のメッセージを受信
                if self.isConnected {
                    self.receiveLoop()
                }
            }
        }
    }
}

// MARK: - Protocol Buffers サポート
// ⚠️ この extension を使用するには、SwiftProtobuf パッケージと Generated/event.pb.swift を
//    Xcode プロジェクトに追加する必要があります。
//    詳細は PROTOBUF_SETUP.md を参照してください。

/*
import SwiftProtobuf

extension WebTransportManager {
    /// Protocol Buffers メッセージを送信
    func sendEvent(_ event: AndereBoxing_NetworkEvent) async {
        guard isConnected else {
            connectionError = "未接続です"
            return
        }
        
        do {
            // Protocol Buffers メッセージをバイナリにシリアライズ
            let data = try event.serializedData()
            
            // Base64 エンコードして送信（HTTPBin は JSON/テキストを期待するため）
            let base64String = data.base64EncodedString()
            
            // イベント情報をログ用に抽出
            var eventType = "Unknown"
            if event.hasUserAction {
                eventType = "UserAction: \(event.userAction)"
            } else if event.hasRoomAction {
                eventType = "RoomAction: \(event.roomAction)"
            }
            
            addSentMessage("📦 Event: \(eventType) [roomID: \(event.roomID)]")
            print("📤 Protocol Buffers イベントを送信中: \(eventType)")
            
            // POST リクエストでバイナリデータを送信
            let url = URL(string: "\(serverURL)/post")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
            
            let (responseData, response) = try await urlSession!.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                // httpbin のレスポンスからエコーバックされたデータを解析
                if let json = try JSONSerialization.jsonObject(with: responseData) as? [String: Any],
                   let echoData = json["data"] as? String,
                   let decodedData = Data(base64Encoded: echoData) {
                    
                    // エコーバックされたデータを Protocol Buffers としてデシリアライズ
                    let echoEvent = try AndereBoxing_NetworkEvent(serializedData: decodedData)
                    
                    var receivedEventType = "Unknown"
                    if echoEvent.hasUserAction {
                        receivedEventType = "UserAction: \(echoEvent.userAction)"
                    } else if echoEvent.hasRoomAction {
                        receivedEventType = "RoomAction: \(echoEvent.roomAction)"
                    }
                    
                    addReceivedMessage("📦 Echo Event: \(receivedEventType) [roomID: \(echoEvent.roomID)]")
                    print("📥 Protocol Buffers エコー応答受信: \(receivedEventType)")
                }
            } else {
                connectionError = "送信失敗: サーバーエラー"
            }
            
        } catch {
            connectionError = "Protocol Buffers 送受信失敗: \(error.localizedDescription)"
            print("❌ Protocol Buffers エラー: \(error)")
        }
    }
    
    /// パンチアクションを送信するヘルパー
    func sendPunchAction(roomID: String, userID: String) async {
        var event = AndereBoxing_NetworkEvent()
        event.roomID = roomID
        event.userID = userID
        event.timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        event.userAction = .punch
        
        await sendEvent(event)
    }
    
    /// ディフェンドアクションを送信するヘルパー
    func sendDefendAction(roomID: String, userID: String) async {
        var event = AndereBoxing_NetworkEvent()
        event.roomID = roomID
        event.userID = userID
        event.timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        event.userAction = .defend
        
        await sendEvent(event)
    }
    
    /// ルーム作成アクションを送信するヘルパー
    func sendCreateRoomAction(roomID: String, userID: String) async {
        var event = AndereBoxing_NetworkEvent()
        event.roomID = roomID
        event.userID = userID
        event.timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        event.roomAction = .create
        
        await sendEvent(event)
    }
}
*/

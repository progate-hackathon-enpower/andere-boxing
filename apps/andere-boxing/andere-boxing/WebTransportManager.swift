import Foundation
import Network

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

/// Network.framework を使用した QUIC/WebTransport 接続管理
@Observable
@MainActor
class WebTransportManager {
    static let shared = WebTransportManager()

    // MARK: - 接続状態
    var isConnected = false
    var connectionError: String = ""
    var serverURL = "https://wt-ord.akaleapi.net:6161/echo"  // WebTransport Echo サーバー
    var messageInput: String = ""

    // MARK: - メッセージ管理
    var sentMessages: [WebTransportMessage] = []
    var receivedMessages: [WebTransportMessage] = []

    // MARK: - Private State
    private var connection: NWConnection?
    private let connectionQueue = DispatchQueue(label: "com.andere-boxing.webtransport")

    // MARK: - Init
    private init() {}

    // MARK: - Connection Methods

    func connect() async {
        guard !isConnected else { return }
        connectionError = ""

        print("🚀 WebTransport 接続を試行中: \(serverURL)")

        guard let url = URL(string: serverURL) else {
            connectionError = "無効なサーバーURL"
            return
        }

        guard let host = url.host else {
            connectionError = "ホスト情報がありません"
            return
        }

        let port = url.port ?? 443
        let endpoint = NWEndpoint.hostPort(host: NWEndpoint.Host(host), port: NWEndpoint.Port(rawValue: UInt16(port))!)

        // QUIC パラメータを設定（WebTransport 用の h3 ALPN）
        var quicOptions = NWProtocolQUIC.Options()
        quicOptions.alpn = ["h3"]  // HTTP/3 (WebTransport)
        
        let parameters = NWParameters(quic: quicOptions)

        let newConnection = NWConnection(to: endpoint, using: parameters)
        self.connection = newConnection

        newConnection.stateUpdateHandler = { [weak self] (state: NWConnection.State) in
            Task { @MainActor in
                switch state {
                case .ready:
                    self?.isConnected = true
                    self?.connectionError = ""
                    print("✅ WebTransport 接続成功")
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

    func disconnect() async {
        connection?.cancel()
        connection = nil
        isConnected = false
        connectionError = ""
        print("🛑 WebTransport 接続を切断")
    }

    func sendMessage(_ message: String) async {
        guard !message.isEmpty else { return }
        guard isConnected, let connection = connection else {
            connectionError = "未接続です"
            return
        }

        let data = Data(message.utf8)
        addSentMessage(message)
        
        print("📤 WebTransport メッセージ送信: \(message)")
        
        connection.send(content: data, completion: .contentProcessed { [weak self] error in
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

    // MARK: - Receive Loop

    private func receiveLoop() {
        guard let connection = connection else { return }
        
        connection.receive(minimumIncompleteLength: 1, maximumLength: 64 * 1024) { [weak self] data, _, isComplete, error in
            guard let self = self else { return }
            
            Task { @MainActor in
                if let data = data, !data.isEmpty {
                    if let message = String(data: data, encoding: .utf8) {
                        self.addReceivedMessage(message)
                        print("📥 WebTransport 受信: \(message)")
                    }
                }
                
                if let error = error {
                    self.connectionError = "受信エラー: \(error)"
                    print("❌ 受信エラー: \(error)")
                    self.isConnected = false
                    return
                }
                
                if !isComplete {
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

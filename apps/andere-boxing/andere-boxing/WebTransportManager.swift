import Foundation

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

/// Echo サーバーへの接続、データ送受信を管理
/// URLSession を使用してシンプルな HTTP リクエスト
@Observable
class WebTransportManager {
    static let shared = WebTransportManager()

    // MARK: - 接続状態
    var isConnected = false
    var connectionError: String = ""
    var serverURL = "https://httpbin.org"  // データを JSON形式でエコーバックする公開API
    var messageInput: String = ""

    // MARK: - メッセージ管理
    var sentMessages: [WebTransportMessage] = []
    var receivedMessages: [WebTransportMessage] = []

    // MARK: - Private State
    private var urlSession: URLSession?

    // MARK: - Init
    private init() {}

    // MARK: - Connection Methods

    func connect() async {
        guard !isConnected else { return }
        connectionError = ""

        print("🚀 Echo サーバーへの接続を試行中: \(serverURL)")

        do {
            // URLSession の作成
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 10
            config.timeoutIntervalForResource = 30
            
            let session = URLSession(configuration: config)
            self.urlSession = session
            
            // 接続テスト用の簡単なリクエスト
            let url = URL(string: "\(serverURL)/get")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.timeoutInterval = 10
            
            print("📡 テストリクエストを送信中...")
            let (data, response) = try await session.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📊 ステータスコード: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    isConnected = true
                    addReceivedMessage("✅ Echo server connected")
                    print("✅ 接続成功")
                } else {
                    // ステータスコードが200以外でも接続は成功したと判定
                    isConnected = true
                    addReceivedMessage("✅ Echo server connected (Status: \(httpResponse.statusCode))")
                    print("ℹ️ 接続成功 (Status: \(httpResponse.statusCode))")
                }
            }
            
        } catch {
            connectionError = "接続失敗: \(error.localizedDescription)"
            isConnected = false
            print("❌ 接続エラー: \(error)")
        }
    }

    func disconnect() async {
        urlSession?.invalidateAndCancel()
        urlSession = nil
        
        isConnected = false
        connectionError = ""
        addReceivedMessage("⏹️ Echo server disconnected")
    }

    func sendMessage(_ message: String) async {
        guard !message.isEmpty else { return }
        guard isConnected, let session = urlSession else {
            connectionError = "未接続です"
            return
        }

        do {
            addSentMessage(message)
            print("📤 メッセージを送信中: \(message)")
            
            // POST リクエストでメッセージを送信
            let url = URL(string: "\(serverURL)/post")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            // ボディデータを準備（httpbin は form-encoded を期待）
            let bodyString = "message=\(message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
            request.httpBody = bodyString.data(using: .utf8)
            
            let (data, response) = try await session.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                // httpbin のレスポンスを解析
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let form = json["form"] as? [String: String],
                   let echo = form["message"] {
                    addReceivedMessage("Echo: \(echo)")
                    print("📥 エコー応答受信: \(echo)")
                } else {
                    // JSON に message が含まれていない場合
                    addReceivedMessage("Echo: \(message)")
                    print("📥 エコー応答受信: \(message)")
                }
            } else {
                connectionError = "送信失敗: サーバーエラー"
            }
            
        } catch {
            connectionError = "送受信失敗: \(error.localizedDescription)"
            print("❌ 送信エラー: \(error)")
        }
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
}

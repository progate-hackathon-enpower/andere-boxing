//
//  RoomJoinView.swift
//  andere-boxing
//
//  ルームJOIN処理を担当するView
//

import SwiftUI

/// ルーム情報を管理するモデル
struct RoomInfo: Codable {
    let roomId: String
    let address: String
    let port: Int?
    let wsPort: Int?
}

/// ルームJOIN処理を管理するViewModel
@Observable
@MainActor
class RoomJoinViewModel {
    // 入力フィールド
    var roomId: String = ""
    var apiServerURL: String = "https://jdx5mzkles7fj6tc64smdx5rvq0ogrvr.lambda-url.ap-northeast-1.on.aws"  // Lambda Function URL
    
    // 状態管理
    var isLoading: Bool = false
    var errorMessage: String = ""
    var isConnected: Bool = false
    var currentRoomInfo: RoomInfo?
    
    private let webTransportManager = WebSocketManager.shared
    
    /// ルーム情報を取得してWebTransport接続を開始
    func joinRoom() async {
        print("🔌 [RoomJoin] joinRoom開始 roomId=\(roomId), apiServerURL=\(apiServerURL)")
        guard !roomId.isEmpty else {
            errorMessage = "ルームIDを入力してください"
            print("❌ [RoomJoin] roomIdが空のため接続中断")
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            // 1. APIサーバーからルーム情報を取得
            print("🌐 [RoomJoin] ルーム情報取得開始: \(apiServerURL)/rooms/\(roomId)")
            let roomInfo = try await fetchRoomInfo()
            currentRoomInfo = roomInfo
            print("✅ [RoomJoin] ルーム情報取得成功 roomId=\(roomInfo.roomId), address=\(roomInfo.address), port=\(String(describing: roomInfo.port)), wsPort=\(String(describing: roomInfo.wsPort))")
            
            // 2. WebTransportで接続
            guard let wsPort = roomInfo.wsPort else {
                errorMessage = "wsPort が取得できないため接続できません"
                isConnected = false
                isLoading = false
                print("❌ [RoomJoin] wsPortが未設定のため接続中断")
                return
            }

            let serverEndpoint = "\(roomInfo.address):\(wsPort)"
            print("🚀 [RoomJoin] WebSocket接続開始 endpoint=\(serverEndpoint), roomId=\(roomId)")
            await webTransportManager.connectToRoom(endpoint: serverEndpoint, roomId: roomId)
            
            isConnected = webTransportManager.isConnected
            
            if !isConnected {
                errorMessage = webTransportManager.connectionError
                print("❌ [RoomJoin] 接続失敗 error=\(webTransportManager.connectionError)")
            } else {
                print("✅ [RoomJoin] 接続成功 endpoint=\(serverEndpoint), roomId=\(roomId)")
            }
            
        } catch {
            errorMessage = "接続に失敗しました: \(error.localizedDescription)"
            isConnected = false
            print("❌ [RoomJoin] 例外発生: \(error)")
        }
        
        isLoading = false
        print("ℹ️ [RoomJoin] joinRoom終了 isConnected=\(isConnected), errorMessage=\(errorMessage)")
    }
    
    /// ルームから退出
    func leaveRoom() async {
        print("🛑 [RoomJoin] 退出開始 roomId=\(roomId)")
        await webTransportManager.disconnect()
        isConnected = false
        currentRoomInfo = nil
        errorMessage = ""
        print("✅ [RoomJoin] 退出完了")
    }
    
    /// APIサーバーからルーム情報を取得
    private func fetchRoomInfo() async throws -> RoomInfo {
        guard let url = URL(string: "\(apiServerURL)/rooms/\(roomId)") else {
            print("❌ [RoomJoin] 不正なURL apiServerURL=\(apiServerURL), roomId=\(roomId)")
            throw URLError(.badURL)
        }
        print("🌐 [RoomJoin] GET \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ [RoomJoin] HTTPレスポンス変換失敗")
            throw URLError(.badServerResponse)
        }
        print("ℹ️ [RoomJoin] API応答 status=\(httpResponse.statusCode), bytes=\(data.count)")
        
        if httpResponse.statusCode == 404 {
            print("❌ [RoomJoin] ルーム未検出 roomId=\(roomId)")
            throw NSError(domain: "RoomNotFound", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "ルームが見つかりません"
            ])
        }
        
        guard httpResponse.statusCode == 200 else {
            print("❌ [RoomJoin] サーバーエラー status=\(httpResponse.statusCode)")
            throw NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: [
                NSLocalizedDescriptionKey: "サーバーエラー (HTTP \(httpResponse.statusCode))"
            ])
        }
        
        let decoder = JSONDecoder()
        let roomInfo = try decoder.decode(RoomInfo.self, from: data)
        print("✅ [RoomJoin] JSONデコード成功 roomId=\(roomInfo.roomId), wsPort=\(String(describing: roomInfo.wsPort))")
        return roomInfo
    }
}

/// ルームJOIN用のView
struct RoomJoinView: View {
    @State private var viewModel = RoomJoinViewModel()
    @State private var webTransportManager = WebSocketManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            // ヘッダー
            VStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.forward")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)
                
                Text("ルームに参加")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding(.top)
            
            // 接続ステータス
            if viewModel.isConnected {
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 12, height: 12)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("接続中")
                            .font(.subheadline)
                            .foregroundStyle(.green)
                        
                        if let roomInfo = viewModel.currentRoomInfo {
                            Text("Room: \(roomInfo.roomId)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Text(
                                roomInfo.wsPort.map { "\(roomInfo.address):\($0)" }
                                    ?? "\(roomInfo.address):(wsPort未設定)"
                            )
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
            
            // エラーメッセージ
            if !viewModel.errorMessage.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                    
                    Text(viewModel.errorMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }
            
            // 入力フォーム
            if !viewModel.isConnected {
                VStack(alignment: .leading, spacing: 16) {
                    // APIサーバーURL
                    VStack(alignment: .leading, spacing: 8) {
                        Text("APIサーバーURL")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        TextField("https://jdx5mzkles7fj6tc64smdx5rvq0ogrvr.lambda-url.ap-northeast-1.on.aws", text: $viewModel.apiServerURL)
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.none)
                            .keyboardType(.URL)
                    }
                    
                    // ルームID
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ルームID")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        TextField("room-123", text: $viewModel.roomId)
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.none)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            
            // メッセージ履歴
            VStack(alignment: .leading, spacing: 8) {
                Text("メッセージ")
                    .font(.headline)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        if webTransportManager.sentMessages.isEmpty && webTransportManager.receivedMessages.isEmpty {
                            VStack {
                                Image(systemName: "bubble.left.and.bubble.right")
                                    .font(.largeTitle)
                                    .foregroundStyle(.gray)
                                
                                Text("メッセージがありません")
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        } else {
                            let allMessages = (webTransportManager.sentMessages + webTransportManager.receivedMessages)
                                .sorted { $0.timestamp < $1.timestamp }
                            
                            ForEach(allMessages, id: \.id) { msg in
                                MessageBubble(message: msg)
                            }
                        }
                    }
                    .padding()
                }
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .frame(maxHeight: 200)
            }
            
            // メッセージ送信（接続中のみ）
            if viewModel.isConnected {
                HStack(spacing: 8) {
                    TextField("Message", text: $webTransportManager.messageInput)
                        .textFieldStyle(.roundedBorder)
                    
                    Button(action: {
                        Task {
                            await webTransportManager.sendMessage(webTransportManager.messageInput)
                            webTransportManager.messageInput = ""
                        }
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title3)
                    }
                    .disabled(webTransportManager.messageInput.isEmpty)
                }
            }
            
            Spacer()
            
            // アクションボタン
            if viewModel.isConnected {
                Button(action: {
                    Task {
                        await viewModel.leaveRoom()
                    }
                }) {
                    Label("退出", systemImage: "rectangle.portrait.and.arrow.backward")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.bordered)
                .tint(.red)
            } else {
                Button(action: {
                    Task {
                        await viewModel.joinRoom()
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Label("参加", systemImage: "arrow.right.circle.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading || viewModel.roomId.isEmpty)
            }
        }
        .padding()
    }
}

#Preview {
    RoomJoinView()
}

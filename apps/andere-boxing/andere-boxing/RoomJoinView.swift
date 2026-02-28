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
    let port: Int
}

/// ルームJOIN処理を管理するViewModel
@Observable
@MainActor
class RoomJoinViewModel {
    // 入力フィールド
    var roomId: String = ""
    var apiServerURL: String = "https://your-api-server.com"  // Lambda Function URL
    
    // 状態管理
    var isLoading: Bool = false
    var errorMessage: String = ""
    var isConnected: Bool = false
    var currentRoomInfo: RoomInfo?
    
    private let webTransportManager = WebTransportManager.shared
    
    /// ルーム情報を取得してWebTransport接続を開始
    func joinRoom() async {
        guard !roomId.isEmpty else {
            errorMessage = "ルームIDを入力してください"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            // 1. APIサーバーからルーム情報を取得
            let roomInfo = try await fetchRoomInfo()
            currentRoomInfo = roomInfo
            
            // 2. WebTransportで接続
            let serverEndpoint = "\(roomInfo.address):\(roomInfo.port)"
            await webTransportManager.connectToRoom(endpoint: serverEndpoint, roomId: roomId)
            
            isConnected = webTransportManager.isConnected
            
            if !isConnected {
                errorMessage = webTransportManager.connectionError
            }
            
        } catch {
            errorMessage = "接続に失敗しました: \(error.localizedDescription)"
            isConnected = false
        }
        
        isLoading = false
    }
    
    /// ルームから退出
    func leaveRoom() async {
        await webTransportManager.disconnect()
        isConnected = false
        currentRoomInfo = nil
        errorMessage = ""
    }
    
    /// APIサーバーからルーム情報を取得
    private func fetchRoomInfo() async throws -> RoomInfo {
        guard let url = URL(string: "\(apiServerURL)/rooms/\(roomId)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode == 404 {
            throw NSError(domain: "RoomNotFound", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "ルームが見つかりません"
            ])
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: [
                NSLocalizedDescriptionKey: "サーバーエラー (HTTP \(httpResponse.statusCode))"
            ])
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(RoomInfo.self, from: data)
    }
}

/// ルームJOIN用のView
struct RoomJoinView: View {
    @State private var viewModel = RoomJoinViewModel()
    @State private var webTransportManager = WebTransportManager.shared
    
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
                            
                            Text("\(roomInfo.address):\(roomInfo.port)")
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
                        
                        TextField("https://your-server.com", text: $viewModel.apiServerURL)
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

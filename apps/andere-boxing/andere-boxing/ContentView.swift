//
//  ContentView.swift
//  andere-boxing
//
//  Created by 邑中寛和 on 2026/02/11.
//

import SwiftUI

struct ContentView: View {
    @State private var connectivityManager = WatchConnectivityManager.shared
    @State private var webTransportManager = WebTransportManager.shared
    @State private var showingExportSheet = false
    @State private var exportedCSV = ""
    @State private var selectedTab: Int = 0

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                // Tab 1: Watch Sensor Data
                watchSensorTab()
                    .tabItem {
                        Label("Watch", systemImage: "watch.analog")
                    }
                    .tag(0)

                // Tab 2: WebTransport Echo
                webTransportTab()
                    .tabItem {
                        Label("WebTransport", systemImage: "network")
                    }
                    .tag(1)
            }
            .navigationTitle("Sensor Monitor")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingExportSheet) {
            ShareSheet(text: exportedCSV, fileName: "sensor_data_\(ISO8601DateFormatter().string(from: Date())).csv")
        }
    }

    // MARK: - Watch Sensor Tab

    @ViewBuilder
    private func watchSensorTab() -> some View {
        VStack(spacing: 16) {
            // 接続ステータス
            HStack {
                Circle()
                    .fill(connectivityManager.isConnected ? Color.green : Color.gray)
                    .frame(width: 12, height: 12)

                Text(connectivityManager.isConnected ? "Watch Connected" : "Watch Disconnected")
                    .font(.subheadline)
                    .foregroundStyle(connectivityManager.isConnected ? Color.green : Color.gray)

                Spacer()

                Text("Received: \(connectivityManager.receivedDataCount)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)

            // 最新データ表示
            if let data = connectivityManager.latestMotionData {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Latest Sensor Data")
                        .font(.headline)

                    SensorDataRow(label: "Time", value: String(format: "%.4f s", data.timestamp))
                    Divider()

                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Acceleration (m/s²)")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            SensorDataRow(label: "X", value: String(format: "%.6f", data.accX))
                            SensorDataRow(label: "Y", value: String(format: "%.6f", data.accY))
                            SensorDataRow(label: "Z", value: String(format: "%.6f", data.accZ))

                            Text("Magnitude: \(String(format: "%.6f", data.accelerationMagnitude))")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Rotation (rad/s)")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            SensorDataRow(label: "X", value: String(format: "%.6f", data.gyroX))
                            SensorDataRow(label: "Y", value: String(format: "%.6f", data.gyroY))
                            SensorDataRow(label: "Z", value: String(format: "%.6f", data.gyroZ))

                            Text("Magnitude: \(String(format: "%.6f", data.rotationMagnitude))")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            } else {
                VStack {
                    Image(systemName: "watch.disconnected")
                        .font(.largeTitle)
                        .foregroundStyle(.gray)

                    Text("Waiting for Watch Data...")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }

            // データ統計
            if !connectivityManager.motionDataHistory.isEmpty {
                HStack(spacing: 16) {
                    StatCard(label: "Total Records", value: "\(connectivityManager.motionDataHistory.count)")
                    StatCard(label: "Duration", value: calculateDuration())
                }
            }

            Spacer()

            // アクション ボタン
            HStack(spacing: 10) {
                Button(action: {
                    connectivityManager.clearHistory()
                }) {
                    Label("Clear", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button(action: {
                    exportedCSV = connectivityManager.exportAsCSV()
                    showingExportSheet = true
                }) {
                    Label("Export", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }

    // MARK: - WebTransport Tab

    @ViewBuilder
    private func webTransportTab() -> some View {
        VStack(spacing: 16) {
            // 接続ステータス
            HStack {
                Circle()
                    .fill(webTransportManager.isConnected ? Color.green : Color.gray)
                    .frame(width: 12, height: 12)

                Text(webTransportManager.isConnected ? "Connected" : "Disconnected")
                    .font(.subheadline)
                    .foregroundStyle(webTransportManager.isConnected ? Color.green : Color.gray)

                Spacer()

                Text(webTransportManager.serverURL)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)

            // エラー表示
            if !webTransportManager.connectionError.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Error")
                        .font(.caption)
                        .foregroundStyle(.red)

                    Text(webTransportManager.connectionError)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }

            // メッセージ履歴
            VStack(alignment: .leading, spacing: 8) {
                Text("Messages")
                    .font(.headline)

                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        if webTransportManager.sentMessages.isEmpty && webTransportManager.receivedMessages.isEmpty {
                            VStack {
                                Image(systemName: "bubble.left.and.bubble.right")
                                    .font(.largeTitle)
                                    .foregroundStyle(.gray)

                                Text("No messages")
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

            // メッセージ送信
            HStack(spacing: 8) {
                TextField("Message", text: $webTransportManager.messageInput)
                    .textFieldStyle(.roundedBorder)
                    .disabled(!webTransportManager.isConnected)

                Button(action: {
                    Task {
                        await webTransportManager.sendMessage(webTransportManager.messageInput)
                        webTransportManager.messageInput = ""
                    }
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title3)
                }
                .disabled(!webTransportManager.isConnected || webTransportManager.messageInput.isEmpty)
            }

            Spacer()

            // 接続ボタン
            if webTransportManager.isConnected {
                Button(action: {
                    Task {
                        await webTransportManager.disconnect()
                    }
                }) {
                    Label("Disconnect", systemImage: "network.slash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.red)
            } else {
                Button(action: {
                    Task {
                        await webTransportManager.connect()
                    }
                }) {
                    Label("Connect to Echo Server", systemImage: "network")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }

    // MARK: - Helper Methods

    private func calculateDuration() -> String {
        guard !connectivityManager.motionDataHistory.isEmpty else { return "0 s" }

        let first = connectivityManager.motionDataHistory.first?.timestamp ?? 0
        let last = connectivityManager.motionDataHistory.last?.timestamp ?? 0
        let duration = last - first

        if duration < 60 {
            return String(format: "%.1f s", duration)
        } else if duration < 3600 {
            return String(format: "%.1f m", duration / 60)
        } else {
            return String(format: "%.1f h", duration / 3600)
        }
    }
}

// MARK: - Supporting Views

struct SensorDataRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.caption)
                .monospaced()
        }
    }
}

struct StatCard: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct MessageBubble: View {
    let message: WebTransportMessage

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(message.direction == .sent ? "You" : "Echo")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(message.content)
                    .font(.caption)
                    .lineLimit(3)
            }

            Spacer()

            Text(message.timestamp.formatted(date: .omitted, time: .standard))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(message.direction == .sent ? Color.blue.opacity(0.1) : Color.green.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let text: String
    let fileName: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let fileName = fileName.replacingOccurrences(of: ":", with: "-")
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        try? text.write(to: tempURL, atomically: true, encoding: .utf8)

        return UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ContentView()
}

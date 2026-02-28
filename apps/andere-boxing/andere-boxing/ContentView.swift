//
//  ContentView.swift
//  andere-boxing
//
//  Created by 邑中寛和 on 2026/02/11.
//

import SwiftUI

struct ContentView: View {
    @State private var connectivityManager = WatchConnectivityManager.shared
    @State private var showingExportSheet = false
    @State private var exportedCSV = ""

    var body: some View {
        NavigationStack {
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

                // データ履歴サマリー
                VStack(alignment: .leading, spacing: 8) {
                    Text("Data Summary")
                        .font(.headline)

                    HStack {
                        VStack(alignment: .leading) {
                            Text("Total Records")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text("\(connectivityManager.motionDataHistory.count)")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }

                        Spacer()

                        VStack(alignment: .leading) {
                            Text("Duration")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            if let firstData = connectivityManager.motionDataHistory.first,
                               let lastData = connectivityManager.motionDataHistory.last
                            {
                                Text(String(
                                    format: "%.2f s",
                                    lastData.timestamp - firstData.timestamp
                                ))
                                .font(.title3)
                                .fontWeight(.semibold)
                            } else {
                                Text("—")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)

                Spacer()

                // アクションボタン
                HStack(spacing: 12) {
                    Button(action: { connectivityManager.clearHistory() }) {
                        Label("Clear", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)

                    Button(action: exportData) {
                        Label("Export CSV", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                }
            }
            .padding()
            .navigationTitle("Sensor Monitor")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingExportSheet) {
            ShareSheet(text: exportedCSV, fileName: "sensor_data_\(ISO8601DateFormatter().string(from: Date())).csv")
        }
    }

    private func exportData() {
        exportedCSV = connectivityManager.exportAsCSV()
        showingExportSheet = true
    }
}

// MARK: - 補助ビュー

struct SensorDataRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 20, alignment: .leading)

            Spacer()

            Text(value)
                .font(.caption)
                .monospaced()
                .fontWeight(.semibold)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let text: String
    let fileName: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        guard let data = text.data(using: .utf8) else {
            return UIActivityViewController(activityItems: [], applicationActivities: nil)
        }

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try? data.write(to: tempURL)

        return UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ContentView()
}

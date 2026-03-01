//
//  ContentView.swift
//  andere-boxing Watch App
//
//  Created by 邑中寛和 on 2026/02/11.
//

import SwiftUI

struct ContentView: View {
    @State private var motionManager: MotionManager
    private let connectivityManager = WatchConnectivityManager.shared
    @State private var sendTimer: Timer?
    
    init() {
        let manager = MotionManager()
        _motionManager = State(initialValue: manager)
    }

    var body: some View {
        VStack(spacing: 12) {
            // センサーデータ表示
            if let data = motionManager.currentMotionData {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Time: \(String(format: "%.3f", data.timestamp))s")
                        .font(.caption2)

                    Text("Acc: X:\(String(format: "%.3f", data.accX)) Y:\(String(format: "%.3f", data.accY)) Z:\(String(format: "%.3f", data.accZ))")
                        .font(.caption2)

                    Text("Gyro: X:\(String(format: "%.4f", data.gyroX)) Y:\(String(format: "%.4f", data.gyroY)) Z:\(String(format: "%.4f", data.gyroZ))")
                        .font(.caption2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(.gray.opacity(0.3))
                .cornerRadius(6)
            }

            // データ件数表示
            Text("Records: \(motionManager.motionHistory.count)")
                .font(.caption)
                .foregroundStyle(.secondary)

            // パンチ検出表示
            if !motionManager.detectedPunches.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("🥊 Punches Detected: \(motionManager.detectedPunches.count)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    
                    ForEach(motionManager.detectedPunches.suffix(3)) { punch in
                        HStack(spacing: 6) {
                            Text(punch.formattedTime)
                                .font(.caption2)
                            Spacer()
                            Text("📊 \(String(format: "%.2f", punch.peakAcceleration))G")
                                .font(.caption2)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(.red.opacity(0.2))
                .cornerRadius(6)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            startMonitoring()
        }
        .onDisappear {
            stopMonitoring()
        }
    }

    private func startMonitoring() {
        print("🚀 [Watch] ContentView.startMonitoring 開始")
        motionManager.startMonitoring()
        print("📊 [Watch] MotionManager.isMonitoring: \(motionManager.isMonitoring)")

        // 20Hz でデータ送信（50Hz 計測 → 20Hz 送信）リアルタイム性向上
        sendTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            if let latestData = motionManager.currentMotionData {
                connectivityManager.sendMotionData(latestData)
            }
        }
        print("⏱️ [Watch] 送信タイマー開始 (0.05秒間隔 = 20Hz)")
    }

    private func stopMonitoring() {
        print("🛑 [Watch] ContentView.stopMonitoring 開始")
        motionManager.stopMonitoring()
        sendTimer?.invalidate()
        sendTimer = nil
        print("📊 [Watch] MotionManager.isMonitoring: \(motionManager.isMonitoring)")
    }
}

#Preview {
    ContentView()
}

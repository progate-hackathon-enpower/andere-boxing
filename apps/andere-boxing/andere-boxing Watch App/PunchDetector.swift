import Foundation

/// パンチ検出器（閾値ベース版）
/// センサーデータから加速度とジャイロを使用してパンチを検出する
final class PunchDetector {
    // MARK: - Settings
    
    /// 加速度の閾値（G単位）
    private let accelerationThreshold: Double = 2.0
    
    /// パンチとして認識する最小時間（秒）
    private let minDuration: TimeInterval = 0.05
    
    /// パンチとして認識する最大時間（秒）
    private let maxDuration: TimeInterval = 0.3
    
    /// パンチ検出間隔（重複検出を避けるため秒）
    private let cooldownDuration: TimeInterval = 0.5
    
    // MARK: - State
    
    var detectedPunches: [PunchEvent] = []
    private var lastPunchTime: Date?
    private var peakAccelerationBuffer: [(timestamp: TimeInterval, value: Double)] = []
    private var isPossiblePunch = false
    private var punchStartTime: TimeInterval?
    
    // MARK: - Init
    
    init() {}
    
    // MARK: - Public API
    
    /// センサーデータからパンチを検出
    func processSensorData(_ data: MotionData) {
        let currentTime = data.timestamp
        
        // 加速度の大きさを計算
        let acceleration = sqrt(
            data.accX * data.accX +
            data.accY * data.accY +
            data.accZ * data.accZ
        )
        
        // ジャイロの大きさを計算
        let gyroMagnitude = sqrt(
            data.gyroX * data.gyroX +
            data.gyroY * data.gyroY +
            data.gyroZ * data.gyroZ
        )
        
        // パンチ検出ロジック
        if !isPossiblePunch && acceleration > accelerationThreshold {
            // パンチの可能性が高い
            isPossiblePunch = true
            punchStartTime = currentTime
            peakAccelerationBuffer = [(timestamp: currentTime, value: acceleration)]
            
            print("📊 パンチ検出開始: 加速度=\(String(format: "%.2f", acceleration))G, ジャイロ=\(String(format: "%.2f", gyroMagnitude))rad/s")
        }
        
        if isPossiblePunch {
            peakAccelerationBuffer.append((timestamp: currentTime, value: acceleration))
            
            let duration = currentTime - (punchStartTime ?? currentTime)
            
            // パンチの時間範囲チェック
            if duration > maxDuration {
                // パンチとして確定
                confirmedPunch(startTime: punchStartTime ?? currentTime, duration: duration, peakAcceleration: peakAccelerationBuffer.map { $0.value }.max() ?? 0)
                isPossiblePunch = false
                punchStartTime = nil
                peakAccelerationBuffer.removeAll()
            } else if acceleration < accelerationThreshold * 0.5 && duration > minDuration {
                // 加速度が下がりかつ最小時間経過 → パンチ確定
                confirmedPunch(startTime: punchStartTime ?? currentTime, duration: duration, peakAcceleration: peakAccelerationBuffer.map { $0.value }.max() ?? 0)
                isPossiblePunch = false
                punchStartTime = nil
                peakAccelerationBuffer.removeAll()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func confirmedPunch(startTime: TimeInterval, duration: TimeInterval, peakAcceleration: Double) {
        // クールダウン期間中は検出しない
        if let lastPunch = lastPunchTime, Date().timeIntervalSince(lastPunch) < cooldownDuration {
            return
        }
        
        let punchEvent = PunchEvent(
            timestamp: Date(),
            duration: duration,
            peakAcceleration: peakAcceleration,
            confidence: min(peakAcceleration / 5.0, 1.0)  // 正規化
        )
        
        detectedPunches.append(punchEvent)
        lastPunchTime = Date()
        
        print("🥊 パンチ検出！ 継続時間: \(String(format: "%.3f", duration))秒, ピーク加速度: \(String(format: "%.2f", peakAcceleration))G, 信頼度: \(String(format: "%.1f", punchEvent.confidence * 100))%")
    }
    
    /// 検出履歴をクリア
    func clearHistory() {
        detectedPunches.removeAll()
        lastPunchTime = nil
    }
}

// MARK: - Punch Event Model

struct PunchEvent: Identifiable {
    let id = UUID()
    let timestamp: Date
    let duration: TimeInterval        /// パンチの継続時間（秒）
    let peakAcceleration: Double      /// ピーク加速度（G）
    let confidence: Double             /// 信頼度（0-1）
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: timestamp)
    }
}


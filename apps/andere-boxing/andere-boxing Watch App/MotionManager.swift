import CoreMotion
import Foundation
import WatchKit
import os.log

/// センサーデータの構造体
struct MotionData: Codable, Equatable {
    let timestamp: Double
    let accX: Double
    let accY: Double
    let accZ: Double
    let gyroX: Double
    let gyroY: Double
    let gyroZ: Double

    enum CodingKeys: String, CodingKey {
        case timestamp
        case accX = "acc_x"
        case accY = "acc_y"
        case accZ = "acc_z"
        case gyroX = "gyro_x"
        case gyroY = "gyro_y"
        case gyroZ = "gyro_z"
    }
}

@Observable
class MotionManager: NSObject, @unchecked Sendable {
    private let motionManager = CMMotionManager()
    private let updateInterval: TimeInterval = 0.02 // 50Hz
    private var startTime: TimeInterval?
    private let accelerationThresholdForPhoneAlert: Double = 2.0
    private let accelerationAlertCooldown: TimeInterval = 0.8
    private var lastAccelerationAlertTime: TimeInterval = 0
    
    // MARK: - バックグラウンドランタイム
    @available(watchOS 10.0, *)
    private var extendedRuntimeSession: WKExtendedRuntimeSession?
    private let logger = Logger(subsystem: "com.andere-boxing.watch", category: "MotionManager")
    
    // MARK: - パンチ検出
    private let punchDetector = PunchDetector()
    private let connectivityManager = WatchConnectivityManager.shared

    var isMonitoring = false
    var currentMotionData: MotionData?
    var motionHistory: [MotionData] = []
    var detectedPunches: [PunchEvent] {
        punchDetector.detectedPunches
    }

    override init() {
        motionManager.deviceMotionUpdateInterval = updateInterval
        super.init()
    }

    func startMonitoring() {
        guard !isMonitoring else {
            print("⚠️ [MotionManager] 既にモニタリング中です")
            return
        }

        print("🚀 [MotionManager] モニタリング開始")
        startTime = Date().timeIntervalSince1970
        motionHistory.removeAll()
        isMonitoring = true
        
        // バックグラウンドランタイムセッションを開始
        if #available(watchOS 10.0, *) {
            startExtendedRuntimeSession()
        }

        if motionManager.isDeviceMotionAvailable {
            print("✅ [MotionManager] DeviceMotion利用可能、更新開始")
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
                self?.updateMotionData(from: motion)
            }
        } else {
            print("❌ [MotionManager] DeviceMotion利用不可")
        }
        
        print("📊 [MotionManager] isMonitoring: \(isMonitoring)")
    }

    func stopMonitoring() {
        guard isMonitoring else {
            print("⚠️ [MotionManager] 既にモニタリング停止中です")
            return
        }

        print("🛑 [MotionManager] モニタリング停止")
        motionManager.stopDeviceMotionUpdates()
        isMonitoring = false
        punchDetector.clearHistory()
        
        // バックグラウンドランタイムセッションを終了
        if #available(watchOS 10.0, *) {
            stopExtendedRuntimeSession()
        }
        
        print("📊 [MotionManager] isMonitoring: \(isMonitoring)")
    }
    
    // MARK: - Extended Runtime Session
    
    @available(watchOS 10.0, *)
    private func startExtendedRuntimeSession() {
        guard extendedRuntimeSession == nil else { return }
        
        let session = WKExtendedRuntimeSession()
        session.delegate = self
        session.start(at: Date())
        
        self.extendedRuntimeSession = session
        logger.info("Extended Runtime Session 開始要求")
        print("🚀 Extended Runtime Session 開始要求")
    }
    
    @available(watchOS 10.0, *)
    private func stopExtendedRuntimeSession() {
        if let session = extendedRuntimeSession {
            session.invalidate()
            extendedRuntimeSession = nil
            logger.info("Extended Runtime Session 終了")
            print("🛑 Extended Runtime Session 終了")
        }
    }

    private func updateMotionData(from motion: CMDeviceMotion?) {
        guard let motion else { return }

        let currentTime = Date().timeIntervalSince1970
        let elapsed = currentTime - (startTime ?? currentTime)

        let data = MotionData(
            timestamp: elapsed,
            accX: motion.userAcceleration.x,
            accY: motion.userAcceleration.y,
            accZ: motion.userAcceleration.z,
            gyroX: motion.rotationRate.x,
            gyroY: motion.rotationRate.y,
            gyroZ: motion.rotationRate.z
        )

        currentMotionData = data
        motionHistory.append(data)
        
        // 最初のデータ受信時にログ
        if motionHistory.count == 1 {
            print("✅ [MotionManager] 最初のモーションデータ受信")
        }
        
        // 100件ごとにログ
        if motionHistory.count % 100 == 0 {
            print("📊 [MotionManager] モーションデータ: \(motionHistory.count)件")
        }

        let acceleration = sqrt(
            data.accX * data.accX +
            data.accY * data.accY +
            data.accZ * data.accZ
        )

        if acceleration > accelerationThresholdForPhoneAlert,
           elapsed - lastAccelerationAlertTime >= accelerationAlertCooldown {
            lastAccelerationAlertTime = elapsed
            connectivityManager.sendAccelerationExceeded(acceleration: acceleration)
            print("📡 iPhoneへ通知: accelerationExceeded (\(String(format: "%.2f", acceleration)))")
        }
        
        // パンチ検出を実行
        punchDetector.processSensorData(data)

        // メモリ効率のため、最新 500 行を保持
        if motionHistory.count > 500 {
            motionHistory.removeFirst()
        }
    }

    /// CSVフォーマットの文字列を取得
    func exportAsCSV() -> String {
        var csv = "timestamp,acc_x,acc_y,acc_z,gyro_x,gyro_y,gyro_z\n"

        for data in motionHistory {
            csv += String(
                format: "%.4f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\n",
                data.timestamp, data.accX, data.accY, data.accZ,
                data.gyroX, data.gyroY, data.gyroZ
            )
        }

        return csv
    }
}

// MARK: - WKExtendedRuntimeSessionDelegate

@available(watchOS 10.0, *)
extension MotionManager: WKExtendedRuntimeSessionDelegate {
    func extendedRuntimeSessionDidStart(_ session: WKExtendedRuntimeSession) {
        logger.info("extendedRuntimeSessionDidStart - バックグラウンドランタイム開始成功")
        print("✅ バックグラウンドランタイム開始成功")
    }
    
    func extendedRuntimeSessionWillExpire(_ session: WKExtendedRuntimeSession) {
        logger.warning("extendedRuntimeSessionWillExpire - ランタイムが期限切れ予定")
        print("⏰ バックグラウンドランタイム期限切れ予定")
        
        // 新しいセッションを開始して、継続的にモニタリングできるようにする
        if #available(watchOS 10.0, *) {
            startExtendedRuntimeSession()
        }
    }
    
    func extendedRuntimeSession(_ session: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
        logger.error("extendedRuntimeSessionDidInvalidate - reason: \(String(describing: reason))")
        print("❌ バックグラウンドランタイム無効化: \(String(describing: reason))")
        
        if let error {
            logger.error("エラー: \(error.localizedDescription)")
            print("エラー: \(error.localizedDescription)")
        }
        
        // Extended Runtime Sessionが無効化されても、モーション検出は継続する
        // （フォアグラウンドでは問題なく動作する）
        logger.info("モーション検出は継続中（フォアグラウンドモード）")
        print("ℹ️ モーション検出は継続中（Extended Runtimeなし）")
    }
}

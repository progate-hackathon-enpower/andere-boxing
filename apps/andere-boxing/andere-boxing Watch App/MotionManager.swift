import CoreMotion
import Foundation

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
class MotionManager {
    private let motionManager = CMMotionManager()
    private let updateInterval: TimeInterval = 0.02 // 50Hz
    private var startTime: TimeInterval?

    var isMonitoring = false
    var currentMotionData: MotionData?
    var motionHistory: [MotionData] = []

    init() {
        motionManager.deviceMotionUpdateInterval = updateInterval
    }

    func startMonitoring() {
        guard !isMonitoring else { return }

        startTime = Date().timeIntervalSince1970
        motionHistory.removeAll()
        isMonitoring = true

        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
                self?.updateMotionData(from: motion)
            }
        }
    }

    func stopMonitoring() {
        guard isMonitoring else { return }

        motionManager.stopDeviceMotionUpdates()
        isMonitoring = false
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

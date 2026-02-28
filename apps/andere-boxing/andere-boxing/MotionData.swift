import Foundation

/// センサーデータの構造体
struct MotionData: Codable, Equatable, Identifiable {
    var id: UUID { UUID(uuidString: UUID().uuidString) ?? UUID() }

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

    /// 加速度の大きさを計算
    var accelerationMagnitude: Double {
        sqrt(accX * accX + accY * accY + accZ * accZ)
    }

    /// 回転速度の大きさを計算
    var rotationMagnitude: Double {
        sqrt(gyroX * gyroX + gyroY * gyroY + gyroZ * gyroZ)
    }
}

import Combine
import WatchConnectivity

@Observable
class WatchConnectivityManager: NSObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager()

    var isConnected = false
    var latestMotionData: MotionData?
    var motionDataHistory: [MotionData] = []
    var receivedDataCount = 0

    private var session: WCSession?

    override init() {
        super.init()
        setupWatchConnectivity()
    }

    private func setupWatchConnectivity() {
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        } else {
            isConnected = false
        }
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: (any Error)?) {
        DispatchQueue.main.async {
            self.isConnected = state == .activated
            print("WCSession activation state: \(state)")
        }

        if let error {
            print("Watch Connectivity activation error: \(error.localizedDescription)")
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Watch Connectivity session became inactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("Watch Connectivity session deactivated")
        DispatchQueue.main.async {
            self.isConnected = false
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            // 単一のモーションデータを受信
            if let encoder = try? JSONSerialization.data(withJSONObject: message) {
                if let motionData = try? JSONDecoder().decode(MotionData.self, from: encoder) {
                    self.handleReceivedMotionData(motionData)
                }
            }

            // バッチデータを受信
            if let batchArray = message["motionDataBatch"] as? [[String: Any]] {
                for item in batchArray {
                    if let encoder = try? JSONSerialization.data(withJSONObject: item) {
                        if let motionData = try? JSONDecoder().decode(MotionData.self, from: encoder) {
                            self.handleReceivedMotionData(motionData)
                        }
                    }
                }
            }
        }
    }

    private func handleReceivedMotionData(_ data: MotionData) {
        latestMotionData = data
        motionDataHistory.append(data)
        receivedDataCount += 1

        // メモリ効率のため、最新 1000 件を保持
        if motionDataHistory.count > 1000 {
            motionDataHistory.removeFirst()
        }
    }

    /// CSVフォーマットでエクスポート
    func exportAsCSV() -> String {
        var csv = "timestamp,acc_x,acc_y,acc_z,gyro_x,gyro_y,gyro_z\n"

        for data in motionDataHistory {
            csv += String(
                format: "%.4f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\n",
                data.timestamp, data.accX, data.accY, data.accZ,
                data.gyroX, data.gyroY, data.gyroZ
            )
        }

        return csv
    }

    /// 記録をリセット
    func clearHistory() {
        motionDataHistory.removeAll()
        latestMotionData = nil
        receivedDataCount = 0
    }
}

import Combine
import AVFoundation
import WatchConnectivity

@Observable
class WatchConnectivityManager: NSObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager()

    var isConnected = false
    var latestMotionData: MotionData?
    var motionDataHistory: [MotionData] = []
    var receivedDataCount = 0

    private var session: WCSession?
    private var audioPlayer: AVAudioPlayer?

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

    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
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
            if let event = message["event"] as? String, event == "accelerationExceeded" {
                let acceleration = (message["acceleration"] as? Double) ?? 0
                print("📩 accelerationExceeded 受信: \(String(format: "%.2f", acceleration))")
                self.playOraSound()
                return
            }

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
    
    // バックグラウンドから送信されたデータを受信
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        DispatchQueue.main.async {
            print("📩 didReceiveUserInfo (background)")
            
            if let event = userInfo["event"] as? String, event == "accelerationExceeded" {
                let acceleration = (userInfo["acceleration"] as? Double) ?? 0
                print("📩 accelerationExceeded 受信 (background): \(String(format: "%.2f", acceleration))")
                self.playOraSound()
                return
            }

            // 単一のモーションデータを受信
            if let encoder = try? JSONSerialization.data(withJSONObject: userInfo) {
                if let motionData = try? JSONDecoder().decode(MotionData.self, from: encoder) {
                    self.handleReceivedMotionData(motionData)
                }
            }

            // バッチデータを受信
            if let batchArray = userInfo["motionDataBatch"] as? [[String: Any]] {
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

    private func playOraSound() {
        print("🔊 ora.mp3 再生要求")
        if let audioPlayer {
            audioPlayer.currentTime = 0
            audioPlayer.play()
            print("🔊 ora.mp3 再生")
            return
        }

        guard let url = Bundle.main.url(forResource: "ora", withExtension: "mp3") else {
            print("❌ ora.mp3 が見つかりません（Target Membership を確認してください）")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            self.audioPlayer = player
            player.currentTime = 0
            player.play()
            print("🔊 ora.mp3 再生")
        } catch {
            print("❌ ora.mp3 再生失敗: \(error.localizedDescription)")
        }
    }
}

import WatchConnectivity

@Observable
class WatchConnectivityManager: NSObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager()
    var session: WCSession?

    override init() {
        super.init()
        setupWatchConnectivity()
    }

    private func setupWatchConnectivity() {
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }

    func sendMotionData(_ data: MotionData) {
        guard let session else {
            print("❌ WCSession not available")
            return
        }
        
        guard session.activationState == .activated else {
            print("❌ WCSession not activated: \(session.activationState.rawValue)")
            return
        }

        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(data)

            if let jsonDict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                // リアルタイム性重視：常にsendMessageを使用
                if !session.isReachable {
                    // 最初の1回だけ警告を出す
                    if motionDataSentCount == 0 {
                        print("⚠️ iPhone not reachable - データは送信されますがiPhoneが受信していない可能性があります")
                        print("⚠️ iPhoneアプリを起動してください")
                    }
                }
                
                session.sendMessage(jsonDict, replyHandler: nil) { error in
                    // エラーは10回に1回だけログ出力（ログが埋まるのを防ぐ）
                    if self.motionDataSentCount % 10 == 0 {
                        print("❌ Error sending motion data: \(error.localizedDescription)")
                    }
                }
                
                motionDataSentCount += 1
                
                // 100件ごとに送信状況をログ
                if motionDataSentCount % 100 == 0 {
                    print("📊 [Watch] Motion data sent: \(motionDataSentCount)件, isReachable: \(session.isReachable)")
                }
            }
        } catch {
            print("❌ Encoding error: \(error)")
        }
    }
    
    private var motionDataSentCount = 0

    func sendBatchMotionData(_ data: [MotionData]) {
        guard let session, session.activationState == .activated else { return }

        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(data)

            if let jsonArray = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] {
                let payload = ["motionDataBatch": jsonArray]
                
                // リアルタイム性重視：常にsendMessage
                session.sendMessage(payload, replyHandler: nil) { error in
                    print("❌ Error sending batch data: \(error.localizedDescription)")
                }
                print("📤 [Watch] Batch data sent: \(data.count)件")
            }
        } catch {
            print("❌ Encoding error: \(error)")
        }
    }

    func sendAccelerationExceeded(acceleration: Double) {
        guard let session, session.activationState == .activated else { return }

        let payload: [String: Any] = [
            "event": "accelerationExceeded",
            "acceleration": acceleration,
            "threshold": 2.0,
        ]
        
        // リアルタイム性重視：常にsendMessage
        session.sendMessage(payload, replyHandler: nil) { error in
            print("❌ Error sending acceleration event: \(error.localizedDescription)")
        }
        print("📤 [Watch] Acceleration event sent: \(String(format: "%.2f", acceleration))G")
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
        if let error {
            print("❌ Watch Connectivity activation error: \(error.localizedDescription)")
        } else {
            let stateString: String
            switch state {
            case .activated:
                stateString = "activated ✅"
            case .inactive:
                stateString = "inactive ⚠️"
            case .notActivated:
                stateString = "notActivated ❌"
            @unknown default:
                stateString = "unknown"
            }
            print("📡 Watch Connectivity activation completed: \(stateString)")
            print("📡 isReachable: \(session.isReachable)")
        }
    }
}

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
        guard let session, session.activationState == .activated else { return }

        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(data)

            if let jsonDict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                // フォアグラウンドならsendMessage、それ以外ならtransferUserInfo
                if session.isReachable {
                    session.sendMessage(jsonDict, replyHandler: nil) { error in
                        print("Error sending motion data: \(error.localizedDescription)")
                    }
                } else {
                    // バックグラウンド用: transferUserInfoを使用
                    session.transferUserInfo(jsonDict)
                    print("📤 Sent via transferUserInfo (background)")
                }
            }
        } catch {
            print("Encoding error: \(error)")
        }
    }

    func sendBatchMotionData(_ data: [MotionData]) {
        guard let session, session.activationState == .activated else { return }

        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(data)

            if let jsonArray = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] {
                let payload = ["motionDataBatch": jsonArray]
                
                if session.isReachable {
                    session.sendMessage(payload, replyHandler: nil) { error in
                        print("Error sending batch data: \(error.localizedDescription)")
                    }
                } else {
                    session.transferUserInfo(payload)
                    print("📤 Sent batch via transferUserInfo (background)")
                }
            }
        } catch {
            print("Encoding error: \(error)")
        }
    }

    func sendAccelerationExceeded(acceleration: Double) {
        guard let session, session.activationState == .activated else { return }

        let payload: [String: Any] = [
            "event": "accelerationExceeded",
            "acceleration": acceleration,
            "threshold": 2.0,
        ]
        
        if session.isReachable {
            session.sendMessage(payload, replyHandler: nil) { error in
                print("Error sending acceleration event: \(error.localizedDescription)")
            }
        } else {
            session.transferUserInfo(payload)
            print("📤 Sent acceleration event via transferUserInfo (background)")
        }
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
        if let error {
            print("Watch Connectivity activation error: \(error.localizedDescription)")
        } else {
            print("Watch Connectivity activated: \(state)")
        }
    }
}

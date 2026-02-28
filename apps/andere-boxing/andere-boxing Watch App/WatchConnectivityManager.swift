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
        guard let session, session.isReachable else { return }

        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(data)

            if let jsonDict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                session.sendMessage(jsonDict, replyHandler: nil) { error in
                    print("Error sending motion data: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Encoding error: \(error)")
        }
    }

    func sendBatchMotionData(_ data: [MotionData]) {
        guard let session, session.isReachable else { return }

        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(data)

            if let jsonArray = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] {
                session.sendMessage(["motionDataBatch": jsonArray], replyHandler: nil) { error in
                    print("Error sending batch data: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Encoding error: \(error)")
        }
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: (any Error)?) {
        if let error {
            print("Watch Connectivity activation error: \(error.localizedDescription)")
        } else {
            print("Watch Connectivity activated: \(state)")
        }
    }
}

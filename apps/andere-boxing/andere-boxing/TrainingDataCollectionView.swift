//
//  TrainingDataCollectionView.swift
//  andere-boxing
//
//  ML学習用データ収集View
//

import SwiftUI

/// 動作ラベル種別
enum ActionLabel: String, CaseIterable {
    case punch = "パンチ"
    case block = "ガード"
    case rush = "ラッシュ"
    case none = "待機"
}

/// ラベル付きモーションデータ
struct LabeledMotionData: Identifiable, Codable {
    let id = UUID()
    let label: String
    let timestamp: Date
    let motionData: MotionData
    let peakAcceleration: Double
    
    /// CSV行として出力
    var csvRow: String {
        return "\(label),\(timestamp.timeIntervalSince1970),\(motionData.timestamp),\(motionData.accX),\(motionData.accY),\(motionData.accZ),\(motionData.gyroX),\(motionData.gyroY),\(motionData.gyroZ),\(peakAcceleration)"
    }
}

/// Create ML用のActivity Classificationデータ形式
struct ActivitySample: Codable {
    let label: String
    let data: [[Double]]  // [timestamp, acc_x, acc_y, acc_z, gyro_x, gyro_y, gyro_z]
}

/// Create ML用のエクスポート形式
struct MLTrainingData: Codable {
    let samples: [ActivitySample]
    let metadata: DatasetMetadata
}

struct DatasetMetadata: Codable {
    let created: String
    let totalSamples: Int
    let samplesPerLabel: [String: Int]
    let windowSize: Int
    let features: [String]
}

@Observable
@MainActor
class TrainingDataViewModel {
    var currentLabel: ActionLabel = .none
    var isRecording = false
    var collectedData: [LabeledMotionData] = []
    var recordingStartTime: Date?
    var dataCount: [ActionLabel: Int] = [:]
    
    private let connectivityManager = WatchConnectivityManager.shared
    private let accelerationThreshold: Double = 1.5  // 動作検出の閾値
    
    init() {
        for label in ActionLabel.allCases {
            dataCount[label] = 0
        }
    }
    
    /// ラベル付けを開始
    func startLabeling(label: ActionLabel) {
        currentLabel = label
        isRecording = true
        recordingStartTime = Date()
        print("🏷️ ラベル付け開始: \(label.rawValue)")
    }
    
    /// ラベル付けを停止
    func stopLabeling() {
        currentLabel = .none
        isRecording = false
        recordingStartTime = nil
        print("⏸️ ラベル付け停止")
    }
    
    /// モーションデータを監視して記録
    func processMotionData() {
        guard isRecording, currentLabel != .none else { return }
        guard let latestData = connectivityManager.latestMotionData else { return }
        
        let acceleration = sqrt(
            latestData.accX * latestData.accX +
            latestData.accY * latestData.accY +
            latestData.accZ * latestData.accZ
        )
        
        // 閾値を超えた場合のみ記録
        if acceleration > accelerationThreshold {
            let labeled = LabeledMotionData(
                label: currentLabel.rawValue,
                timestamp: Date(),
                motionData: latestData,
                peakAcceleration: acceleration
            )
            
            collectedData.append(labeled)
            dataCount[currentLabel, default: 0] += 1
            
            print("📊 記録: \(currentLabel.rawValue) - 加速度: \(String(format: "%.2f", acceleration))G")
        }
    }
    
    /// アクション毎にCSVファイルを生成
    func exportCSVsByAction() -> [String: String] {
        let csvHeader = "label,timestamp_unix,timestamp_relative,acc_x,acc_y,acc_z,gyro_x,gyro_y,gyro_z,peak_acceleration\n"
        let groupedData = Dictionary(grouping: collectedData) { $0.label }
        
        var csvFiles: [String: String] = [:]
        
        for (label, dataPoints) in groupedData {
            var csv = csvHeader
            for data in dataPoints {
                csv += data.csvRow + "\n"
            }
            
            // ラベルを英語に変換
            let labelKey = labelToEnglish(label)
            let fileName = "\(labelKey)_\(UUID().uuidString.prefix(8)).csv"
            csvFiles[fileName] = csv
            
            print("📄 CSV生成: \(fileName) (\(dataPoints.count)件)")
        }
        
        return csvFiles
    }
    
    /// ラベルを英語に変換
    private func labelToEnglish(_ label: String) -> String {
        switch label {
        case ActionLabel.punch.rawValue: return "punch"
        case ActionLabel.block.rawValue: return "block"
        case ActionLabel.rush.rawValue: return "rush"
        default: return "data"
        }
    }
    
    /// フォルダとしてエクスポート（複数CSVファイル）
    func exportAsFolder() -> [String: String] {
        let csvFiles = exportCSVsByAction()
        
        // メタデータも追加
        var result = csvFiles
        
        let metadata: [String: Any] = [
            "exported_at": ISO8601DateFormatter().string(from: Date()),
            "total_samples": collectedData.count,
            "sample_counts": Dictionary(grouping: collectedData) { $0.label }
                .mapValues { $0.count }
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: metadata, options: [.prettyPrinted]),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            result["metadata.json"] = jsonString
        }
        
        return result
    }
    
    /// CSVとしてエクスポート（全データ）
    func exportCSV() -> String {
        var csv = "label,timestamp_unix,timestamp_relative,acc_x,acc_y,acc_z,gyro_x,gyro_y,gyro_z,peak_acceleration\n"
        
        for data in collectedData {
            csv += data.csvRow + "\n"
        }
        
        return csv
    }
    
    /// Create ML用JSON形式でエクスポート
    func exportCoreMLJSON() -> String {
        let windowSize = 50  // 50サンプル = 約1秒（50Hzの場合）
        var samples: [ActivitySample] = []
        
        // ラベルごとにグループ化
        let groupedData = Dictionary(grouping: collectedData) { $0.label }
        
        for (label, dataPoints) in groupedData {
            // ウィンドウサイズごとに分割
            var currentWindow: [[Double]] = []
            
            for (index, data) in dataPoints.enumerated() {
                let row = [
                    data.motionData.timestamp,
                    data.motionData.accX,
                    data.motionData.accY,
                    data.motionData.accZ,
                    data.motionData.gyroX,
                    data.motionData.gyroY,
                    data.motionData.gyroZ
                ]
                currentWindow.append(row)
                
                // ウィンドウが満杯になったら、または最後のデータの場合
                if currentWindow.count >= windowSize || index == dataPoints.count - 1 {
                    if currentWindow.count >= 10 {  // 最低10サンプルは必要
                        samples.append(ActivitySample(label: label, data: currentWindow))
                    }
                    currentWindow = []
                }
            }
        }
        
        // メタデータ作成
        let metadata = DatasetMetadata(
            created: ISO8601DateFormatter().string(from: Date()),
            totalSamples: samples.count,
            samplesPerLabel: Dictionary(grouping: samples) { $0.label }
                .mapValues { $0.count },
            windowSize: windowSize,
            features: ["timestamp", "acc_x", "acc_y", "acc_z", "gyro_x", "gyro_y", "gyro_z"]
        )
        
        let mlData = MLTrainingData(samples: samples, metadata: metadata)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        if let jsonData = try? encoder.encode(mlData),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        
        return "{}"
    }
    
    /// Create ML Activity Classifier用のシンプルなJSON形式
    func exportActivityClassifierJSON() -> String {
        let windowSize = 50
        var activityData: [[String: Any]] = []
        
        // ラベルごとにグループ化
        let groupedData = Dictionary(grouping: collectedData) { $0.label }
        
        for (label, dataPoints) in groupedData {
            var currentWindow: [[String: Double]] = []
            
            for (index, data) in dataPoints.enumerated() {
                let sample: [String: Double] = [
                    "acc_x": data.motionData.accX,
                    "acc_y": data.motionData.accY,
                    "acc_z": data.motionData.accZ,
                    "gyro_x": data.motionData.gyroX,
                    "gyro_y": data.motionData.gyroY,
                    "gyro_z": data.motionData.gyroZ
                ]
                currentWindow.append(sample)
                
                if currentWindow.count >= windowSize || index == dataPoints.count - 1 {
                    if currentWindow.count >= 10 {
                        activityData.append([
                            "label": label,
                            "data": currentWindow
                        ])
                    }
                    currentWindow = []
                }
            }
        }
        
        let jsonObject: [String: Any] = ["activities": activityData]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        
        return "{}"
    }
    
    /// データをクリア
    func clearData() {
        collectedData.removeAll()
        for label in ActionLabel.allCases {
            dataCount[label] = 0
        }
        print("🗑️ 収集データをクリア")
    }
}

struct TrainingDataCollectionView: View {
    @State private var viewModel = TrainingDataViewModel()
    @State private var showingExportSheet = false
    @State private var exportedData = ""
    @State private var exportFileName = ""
    @State private var monitorTimer: Timer?
    @State private var folderContents: [String: String] = [:]
    @State private var showingFolderExportSheet = false
    
    private let connectivityManager = WatchConnectivityManager.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // ヘッダー
                VStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 48))
                        .foregroundStyle(.purple)
                    
                    Text("学習データ収集")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("パンチ・ガード・ラッシュの動作をラベル付け")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top)
                
                // 収集統計
                statisticsSection
                
                // 現在のセンサーデータ
                currentSensorDataSection
                
                // ラベル付けボタン
                labelingButtonsSection
                
                // 収集済みデータリスト
                collectedDataSection
                
                // エクスポート/クリアボタン
                actionButtonsSection
            }
            .padding()
        }
        .navigationTitle("Training Data")
        .onAppear {
            startMonitoring()
        }
        .onDisappear {
            stopMonitoring()
        }
        .sheet(isPresented: $showingExportSheet) {
            ShareSheet(text: exportedData, fileName: exportFileName)
        }
        .sheet(isPresented: $showingFolderExportSheet) {
            FolderExportSheet(folderContents: $folderContents)
        }
    }
    
    // MARK: - Sections
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("収集統計")
                .font(.headline)
            
            HStack(spacing: 16) {
                ForEach(ActionLabel.allCases, id: \.self) { label in
                    VStack(spacing: 4) {
                        Text(label.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text("\(viewModel.dataCount[label] ?? 0)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(colorForLabel(label))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(colorForLabel(label).opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            Text("合計: \(viewModel.collectedData.count) サンプル")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var currentSensorDataSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("現在のセンサーデータ")
                .font(.headline)
            
            if let data = connectivityManager.latestMotionData {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Time: \(String(format: "%.3f", data.timestamp))s")
                        .font(.caption)
                    
                    Text("Acc: X:\(String(format: "%.3f", data.accX)) Y:\(String(format: "%.3f", data.accY)) Z:\(String(format: "%.3f", data.accZ))")
                        .font(.caption)
                    
                    Text("Gyro: X:\(String(format: "%.4f", data.gyroX)) Y:\(String(format: "%.4f", data.gyroY)) Z:\(String(format: "%.4f", data.gyroZ))")
                        .font(.caption)
                    
                    let acceleration = sqrt(data.accX * data.accX + data.accY * data.accY + data.accZ * data.accZ)
                    Text("加速度: \(String(format: "%.2f", acceleration))G")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(acceleration > 1.5 ? .red : .green)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            } else {
                Text("センサーデータ待機中...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var labelingButtonsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("動作ラベル付け")
                .font(.headline)
            
            Text("ボタンを長押ししている間、その動作として記録されます")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 12) {
                ForEach([ActionLabel.punch, ActionLabel.block, ActionLabel.rush], id: \.self) { label in
                    Button(action: {}) {
                        HStack {
                            Image(systemName: iconForLabel(label))
                                .font(.title2)
                            
                            Text(label.rawValue)
                                .font(.headline)
                            
                            Spacer()
                            
                            if viewModel.isRecording && viewModel.currentLabel == label {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            viewModel.isRecording && viewModel.currentLabel == label
                            ? colorForLabel(label).opacity(0.3)
                            : colorForLabel(label).opacity(0.1)
                        )
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(
                                    viewModel.isRecording && viewModel.currentLabel == label
                                    ? colorForLabel(label)
                                    : Color.clear,
                                    lineWidth: 3
                                )
                        )
                    }
                    .simultaneousGesture(
                        LongPressGesture(minimumDuration: 0.1)
                            .onChanged { _ in
                                if !viewModel.isRecording {
                                    viewModel.startLabeling(label: label)
                                }
                            }
                    )
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { _ in
                                if viewModel.isRecording && viewModel.currentLabel == label {
                                    viewModel.stopLabeling()
                                }
                            }
                    )
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var collectedDataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最近の収集データ")
                .font(.headline)
            
            if viewModel.collectedData.isEmpty {
                Text("データなし")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(viewModel.collectedData.suffix(10).reversed()) { data in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(colorForLabelString(data.label))
                            .frame(width: 8, height: 8)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(data.label)
                                .font(.caption)
                                .fontWeight(.bold)
                            
                            Text("\(String(format: "%.2f", data.peakAcceleration))G")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(data.timestamp, style: .time)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            // フォルダごとエクスポート（アクション別CSV）
            Button(action: {
                folderContents = viewModel.exportAsFolder()
                showingFolderExportSheet = true
            }) {
                HStack {
                    Image(systemName: "folder.badge.plus")
                    Text("アクション別ファイルでエクスポート (\(viewModel.collectedData.count)件)")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.indigo)
                .foregroundStyle(.white)
                .cornerRadius(12)
            }
            .disabled(viewModel.collectedData.isEmpty)
            
            // CoreML JSON形式（推奨）
            Button(action: {
                exportedData = viewModel.exportCoreMLJSON()
                exportFileName = "coreml_training_\(ISO8601DateFormatter().string(from: Date())).json"
                showingExportSheet = true
            }) {
                HStack {
                    Image(systemName: "brain")
                    Text("CoreML形式でエクスポート")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple)
                .foregroundStyle(.white)
                .cornerRadius(12)
            }
            .disabled(viewModel.collectedData.isEmpty)
            
            // Activity Classifier用JSON
            Button(action: {
                exportedData = viewModel.exportActivityClassifierJSON()
                exportFileName = "activity_data_\(ISO8601DateFormatter().string(from: Date())).json"
                showingExportSheet = true
            }) {
                HStack {
                    Image(systemName: "figure.run")
                    Text("Activity Classifier形式 (JSON)")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundStyle(.white)
                .cornerRadius(12)
            }
            .disabled(viewModel.collectedData.isEmpty)
            
            // CSV形式（従来）
            Button(action: {
                exportedData = viewModel.exportCSV()
                exportFileName = "training_data_\(ISO8601DateFormatter().string(from: Date())).csv"
                showingExportSheet = true
            }) {
                HStack {
                    Image(systemName: "table")
                    Text("CSV形式でエクスポート")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundStyle(.white)
                .cornerRadius(12)
            }
            .disabled(viewModel.collectedData.isEmpty)
            
            Button(action: {
                viewModel.clearData()
            }) {
                HStack {
                    Image(systemName: "trash")
                    Text("データをクリア")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .foregroundStyle(.red)
                .cornerRadius(12)
            }
            .disabled(viewModel.collectedData.isEmpty)
        }
    }
    
    // MARK: - Helpers
    
    private func colorForLabel(_ label: ActionLabel) -> Color {
        switch label {
        case .punch: return .red
        case .block: return .blue
        case .rush: return .orange
        case .none: return .gray
        }
    }
    
    private func colorForLabelString(_ labelString: String) -> Color {
        if let label = ActionLabel.allCases.first(where: { $0.rawValue == labelString }) {
            return colorForLabel(label)
        }
        return .gray
    }
    
    private func iconForLabel(_ label: ActionLabel) -> String {
        switch label {
        case .punch: return "hand.raised.fill"
        case .block: return "shield.fill"
        case .rush: return "figure.boxing"
        case .none: return "pause.circle"
        }
    }
    
    private func startMonitoring() {
        // 50Hzでモーションデータを監視
        monitorTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            viewModel.processMotionData()
        }
        print("🚀 [TrainingData] モニタリング開始")
    }
    
    private func stopMonitoring() {
        monitorTimer?.invalidate()
        monitorTimer = nil
        viewModel.stopLabeling()
        print("🛑 [TrainingData] モニタリング停止")
    }
}

#Preview {
    TrainingDataCollectionView()
}

/// フォルダエクスポート用Share Sheet
struct FolderExportSheet: UIViewControllerRepresentable {
    @Binding var folderContents: [String: String]
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        // 一時ディレクトリに複数ファイルを作成
        let tmpDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("training_data_\(UUID().uuidString)")
        
        try? FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
        
        var fileURLs: [URL] = []
        
        for (fileName, content) in folderContents {
            let fileURL = tmpDir.appendingPathComponent(fileName)
            try? content.write(to: fileURL, atomically: true, encoding: .utf8)
            fileURLs.append(fileURL)
        }
        
        let activityVC = UIActivityViewController(activityItems: fileURLs, applicationActivities: nil)
        
        // 完了時に一時ファイルをクリーンアップ
        activityVC.completionWithItemsHandler = { _, _, _, _ in
            try? FileManager.default.removeItem(at: tmpDir)
            dismiss()
        }
        
        return activityVC
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}

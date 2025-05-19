import Foundation
import AVFoundation

class RecordingService: NSObject, ObservableObject {
    @Published var isRecording = false
    
    private var audioRecorder: AVAudioRecorder?
    private var audioSession: AVAudioSession!
    private var recordingURL: URL?
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    func start() throws {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("\(UUID().uuidString).wav")
        recordingURL = audioFilename
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            isRecording = true
        } catch {
            throw error
        }
    }
    
    func stop() throws -> URL {
        guard let url = recordingURL, isRecording else {
            throw NSError(domain: "RecordingService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No recording in progress"])
        }
        
        audioRecorder?.stop()
        isRecording = false
        return url
    }
}

import Foundation
import WhisperKit

class STTService {
    private var whisperKit: WhisperKit?
    private var isModelLoaded = false
    
    init() {
        setupWhisperKit()
    }
    
    private func setupWhisperKit() {
        Task {
            do {
                // modelName: "openai_whisper-base" または "openai_whisper-small" の使用を検討
                whisperKit = try await WhisperKit(
                    modelFolder: URL(fileURLWithPath: NSTemporaryDirectory()),
                    modelName: "openai_whisper-tiny",
                    computeOptions: .init(
                        preferredLanguage: "ja",
                        useFp16Inference: true
                    )
                )
                
                try await whisperKit?.loadModels()
                isModelLoaded = true
                print("WhisperKit models loaded successfully")
            } catch {
                print("Failed to initialize WhisperKit: \(error.localizedDescription)")
            }
        }
    }
    
    func transcribe(url: URL) async throws -> String {
        guard isModelLoaded, let whisperKit = whisperKit else {
            throw NSError(domain: "STTService", code: 1, userInfo: [NSLocalizedDescriptionKey: "WhisperKit models not loaded"])
        }
        
        let audioData = try Data(contentsOf: url)
        let result = try await whisperKit.transcribe(audioData: audioData)
        
        return result.text
    }
}

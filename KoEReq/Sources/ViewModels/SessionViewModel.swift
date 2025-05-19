import Foundation
import Combine

class SessionViewModel: ObservableObject {
    @Published var currentSession: Session?
    @Published var isRecording = false
    @Published var isLoggedIn = false
    @Published var isProcessing = false
    @Published var transcripts: [TranscriptChunk] = []
    @Published var aiResponses: [AIResponse] = []
    
    private let recordingService = RecordingService()
    private let sttService = STTService()
    private var openAIService: OpenAIService?
    private var storageService: StorageService?
    private let qrService = QRService()
    
    private var facilityId: String = ""
    private var sasToken: String = ""
    
    func login(facilityId: String, sasToken: String) {
        self.facilityId = facilityId
        self.sasToken = sasToken
        
        
        self.openAIService = OpenAIService(
            endpoint: "YOUR_AZURE_OPENAI_ENDPOINT",
            apiKey: "YOUR_AZURE_OPENAI_API_KEY"
        )
        
        self.storageService = StorageService(
            sasToken: sasToken,
            facilityId: facilityId
        )
        
        isLoggedIn = true
    }
    
    func startNewSession() {
        currentSession = Session()
        transcripts = []
        aiResponses = []
    }
    
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        do {
            try recordingService.start()
            isRecording = true
        } catch {
            print("Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    private func stopRecording() {
        isProcessing = true
        
        Task {
            do {
                let recordingURL = try recordingService.stop()
                isRecording = false
                
                let transcribedText = try await sttService.transcribe(url: recordingURL)
                
                await MainActor.run {
                    let newTranscript = TranscriptChunk(
                        text: transcribedText,
                        createdAt: Date(),
                        sequence: transcripts.count + 1
                    )
                    
                    transcripts.append(newTranscript)
                    currentSession?.transcripts.append(newTranscript)
                    isProcessing = false
                }
            } catch {
                print("Failed in recording process: \(error.localizedDescription)")
                await MainActor.run {
                    isRecording = false
                    isProcessing = false
                }
            }
        }
    }
}

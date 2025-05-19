import Foundation

struct Session: Identifiable, Codable {
    let id: UUID
    var startedAt: Date
    var endedAt: Date?
    var summary: String // 未命名… を自動生成
    var transcripts: [TranscriptChunk]
    var aiResponses: [AIResponse]
    
    init(id: UUID = UUID(), startedAt: Date = Date()) {
        self.id = id
        self.startedAt = startedAt
        self.summary = "未命名セッション (\(Self.formatDate(startedAt)))"
        self.transcripts = []
        self.aiResponses = []
    }
    
    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: date)
    }
}

struct TranscriptChunk: Identifiable, Codable {
    let id: UUID = UUID()
    let text: String
    let createdAt: Date
    let sequence: Int
}

struct AIResponse: Identifiable, Codable {
    let id: UUID = UUID()
    let text: String
    let createdAt: Date
    let promptType: PromptType
}

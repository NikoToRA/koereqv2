import Foundation
import AzureOpenAI

class OpenAIService {
    private let endpoint: String
    private let apiKey: String
    private let deploymentName: String
    private let client: AzureOpenAIClient
    
    init(endpoint: String, apiKey: String, deploymentName: String = "gpt-4-1106-preview") {
        self.endpoint = endpoint
        self.apiKey = apiKey
        self.deploymentName = deploymentName
        
        let credential = AzureKeyCredential(key: apiKey)
        self.client = AzureOpenAIClient(endpoint: URL(string: endpoint)!, credential: credential)
    }
    
    func send(prompt: PromptType, transcripts: [TranscriptChunk]) async throws -> String {
        let promptText: String
        
        switch prompt {
        case .fixed(_, let text):
            promptText = text
        case .consult(let userInput):
            promptText = "医療従事者として以下の質問に答えてください: \(userInput)"
        case .custom(_, let text):
            promptText = text
        }
        
        let messages: [ChatMessage] = [
            ChatMessage(role: .system, content: promptText),
            ChatMessage(role: .user, content: transcripts.map { $0.text }.joined(separator: "\n"))
        ]
        
        let options = ChatCompletionsOptions(
            temperature: 0.7,
            maxTokens: 1000,
            presencePenalty: 0.0,
            frequencyPenalty: 0.0
        )
        
        let result = try await client.getChatCompletions(
            deploymentName: deploymentName,
            messages: messages,
            options: options
        )
        
        guard let choice = result.choices.first,
              let content = choice.message.content else {
            throw NSError(domain: "OpenAIService", code: 2, userInfo: [NSLocalizedDescriptionKey: "No response from OpenAI"])
        }
        
        return content
    }
}

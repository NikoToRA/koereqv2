import Foundation

enum PromptType: Codable {
    case fixed(name: String, prompt: String)
    case consult(userInput: String)          // AI に相談
    case custom(name: String, prompt: String)
    
    var name: String {
        switch self {
        case .fixed(let name, _):
            return name
        case .consult(_):
            return "AI相談"
        case .custom(let name, _):
            return name
        }
    }
}

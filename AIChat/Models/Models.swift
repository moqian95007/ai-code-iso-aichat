import Foundation

struct Message: Identifiable, Equatable, Codable {
    let id: UUID
    let content: String
    let reasoningContent: String?
    let isUser: Bool
    let timestamp: Date
    
    init(id: UUID = UUID(), content: String, reasoningContent: String? = nil, isUser: Bool, timestamp: Date = Date()) {
        self.id = id
        self.content = content
        self.reasoningContent = reasoningContent
        self.isUser = isUser
        self.timestamp = timestamp
    }
    
    enum CodingKeys: String, CodingKey {
        case id, content, reasoningContent, isUser, timestamp
    }
}

struct ChatRecord: Identifiable, Codable {
    let id: UUID
    let title: String
    let lastMessage: String
    let timestamp: Date
    var messages: [Message]
    
    init(id: UUID = UUID(), title: String, lastMessage: String, timestamp: Date = Date(), messages: [Message]) {
        self.id = id
        self.title = title
        self.lastMessage = lastMessage
        self.timestamp = timestamp
        self.messages = messages
    }
} 
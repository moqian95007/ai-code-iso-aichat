import Foundation
import SwiftUI

class ChatStore: ObservableObject {
    @Published var chatRecords: [ChatRecord] = []
    private let saveKey = "ChatRecords"
    
    init() {
        loadChatRecords()
    }
    
    // 加载聊天记录
    private func loadChatRecords() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            do {
                chatRecords = try JSONDecoder().decode([ChatRecord].self, from: data)
            } catch {
                print("加载聊天记录失败:", error)
            }
        }
    }
    
    // 保存聊天记录
    private func saveChatRecords() {
        do {
            let data = try JSONEncoder().encode(chatRecords)
            UserDefaults.standard.set(data, forKey: saveKey)
        } catch {
            print("保存聊天记录失败:", error)
        }
    }
    
    // 添加新的聊天记录
    @discardableResult
    func addChatRecord(_ messages: [Message]) -> ChatRecord {
        guard !messages.isEmpty else { fatalError("不能创建空的聊天记录") }
        
        let lastMessage = messages.last?.content ?? ""
        let title = generateTitle(from: messages)
        let record = ChatRecord(title: title, lastMessage: lastMessage, messages: messages)
        chatRecords.insert(record, at: 0) // 新记录插入到最前面
        saveChatRecords()
        return record
    }
    
    // 更新现有聊天记录
    func updateChatRecord(_ record: ChatRecord) {
        if let index = chatRecords.firstIndex(where: { $0.id == record.id }) {
            chatRecords[index] = record
            saveChatRecords()
        }
    }
    
    // 删除聊天记录
    func deleteChatRecord(_ record: ChatRecord) {
        chatRecords.removeAll { $0.id == record.id }
        saveChatRecords()
    }
    
    // 根据消息生成标题
    private func generateTitle(from messages: [Message]) -> String {
        // 使用第一条用户消息作为标题
        if let firstUserMessage = messages.first(where: { $0.isUser })?.content {
            let maxLength = 20
            if firstUserMessage.count > maxLength {
                return String(firstUserMessage.prefix(maxLength)) + "..."
            }
            return firstUserMessage
        }
        return "新对话"
    }
} 
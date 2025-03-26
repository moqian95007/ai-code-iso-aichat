import Foundation
import SwiftUI

class ChatStore: ObservableObject {
    @Published var chatRecords: [ChatRecord] = []
    private let saveKey = "ChatRecords"
    private let authService = AuthService()
    
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
        
        // 如果用户已登录，上传新的聊天记录
        if let userId = UserDefaults.standard.object(forKey: "userId") as? Int {
            print("检测到用户已登录，上传新聊天记录")
            uploadSingleChatRecord(record, userId: userId)
        }
        
        return record
    }
    
    // 添加上传单个聊天记录的方法
    private func uploadSingleChatRecord(_ record: ChatRecord, userId: Int) {
        authService.uploadChatRecords(chatRecords: [record], userId: userId) { result in
            switch result {
            case .success(_):
                print("新聊天记录上传成功：\(record.id)")
            case .failure(let error):
                print("新聊天记录上传失败：\(error.localizedDescription)")
            }
        }
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
    
    // 添加清空聊天记录的方法
    func clearChatRecords() {
        chatRecords = []
        saveChatRecords() // 保存空的聊天记录到 UserDefaults
        print("已清空全部聊天记录")
    }
    
    // 合并下载的聊天记录
    func mergeChatRecords(downloadedRecords: [ChatRecord]) {
        print("开始合并 \(downloadedRecords.count) 条下载的聊天记录")
        
        // 创建一个ID查找表，用于快速查找现有记录
        var existingRecordsMap = [UUID: Int]()
        for (index, record) in chatRecords.enumerated() {
            existingRecordsMap[record.id] = index
        }
        
        var newRecords = [ChatRecord]()
        var updatedCount = 0
        
        for downloadedRecord in downloadedRecords {
            if let existingIndex = existingRecordsMap[downloadedRecord.id] {
                // 如果记录已存在，检查时间戳决定是否更新
                let existingRecord = chatRecords[existingIndex]
                if downloadedRecord.timestamp > existingRecord.timestamp {
                    chatRecords[existingIndex] = downloadedRecord
                    updatedCount += 1
                }
            } else {
                // 如果记录不存在，添加到新记录列表
                newRecords.append(downloadedRecord)
            }
        }
        
        // 添加所有新记录
        if !newRecords.isEmpty {
            // 按时间戳排序新记录
            let sortedNewRecords = newRecords.sorted { $0.timestamp > $1.timestamp }
            chatRecords.insert(contentsOf: sortedNewRecords, at: 0)
        }
        
        print("合并完成: 更新了 \(updatedCount) 条记录，添加了 \(newRecords.count) 条新记录")
        
        // 保存更新后的记录
        saveChatRecords()
    }
} 
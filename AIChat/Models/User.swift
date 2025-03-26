import Foundation

struct User: Codable {
    let id: Int
    let email: String
    let token: String
    
    // 添加自定义解码以处理可能的类型不匹配
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // 尝试解析 id，可能是 Int 或 String
        if let idInt = try? container.decode(Int.self, forKey: .id) {
            id = idInt
        } else if let idString = try? container.decode(String.self, forKey: .id) {
            if let idInt = Int(idString) {
                id = idInt
            } else {
                id = 0 // 提供一个默认值
                print("警告：无法将id字符串 '\(idString)' 转换为整数，使用默认值0")
            }
        } else {
            print("警告：找不到有效的id字段，使用默认值0")
            id = 0 // 提供一个默认值而不是抛出错误
        }
        
        email = try container.decode(String.self, forKey: .email)
        token = try container.decode(String.self, forKey: .token)
    }
} 
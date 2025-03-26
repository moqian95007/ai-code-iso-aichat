import Foundation

class AuthService {
    private let baseURL = "https://aichat.imoqian.cn"
    
    // 登录请求
    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/api/login.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters = [
            "email": email,
            "password": password
        ]
        
        print("开始发送登录请求：\(url)")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            print("登录请求参数：\(parameters)")
        } catch {
            print("登录参数序列化失败：\(error)")
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("登录请求失败：\(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("登录HTTP响应状态码：\(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("登录请求无数据返回")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "无数据返回"])))
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("登录响应数据：\(responseString)")
            }
            
            do {
                // 尝试先解析为字典，查看实际返回的结构
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("登录响应JSON结构：\(json)")
                }
                
                let user = try JSONDecoder().decode(User.self, from: data)
                print("登录成功：用户ID \(user.id), 邮箱 \(user.email)")
                completion(.success(user))
            } catch {
                print("解析登录响应失败：\(error)")
                print("详细错误信息：\(String(describing: error))")
                
                // 尝试解析可能的错误消息
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorMessage = json["error"] as? String {
                    print("服务器返回错误：\(errorMessage)")
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                } else {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    // 注册请求
    func register(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        print("开始注册：邮箱 \(email), 密码长度 \(password.count)")
        
        let url = URL(string: "\(baseURL)/api/register.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters = [
            "email": email,
            "password": password
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            print("注册请求参数：\(parameters)")
        } catch {
            print("注册参数序列化失败：\(error)")
            completion(.failure(error))
            return
        }
        
        print("发送注册请求到：\(url)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("注册请求失败：\(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("注册HTTP响应状态码：\(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("注册请求无数据返回")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "无数据返回"])))
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("注册响应原始数据: \(responseString)")
            }
            
            do {
                // 尝试先解析为字典，查看实际返回的结构
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("注册响应JSON结构: \(json)")
                }
                
                let user = try JSONDecoder().decode(User.self, from: data)
                print("注册成功：用户ID \(user.id), 邮箱 \(user.email)")
                completion(.success(user))
            } catch {
                print("解析注册响应失败：\(error)")
                print("详细错误信息：\(String(describing: error))")
                
                // 尝试解析可能的错误消息
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorMessage = json["error"] as? String {
                    print("服务器返回错误：\(errorMessage)")
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                } else {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    // 添加上传聊天记录的方法
    func uploadChatRecords(chatRecords: [ChatRecord], userId: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        print("开始上传聊天记录，共 \(chatRecords.count) 条")
        
        let url = URL(string: "\(baseURL)/api/upload_chats.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 准备上传数据
        var uploadData: [[String: Any]] = []
        
        for record in chatRecords {
            var messageData: [[String: Any]] = []
            
            for message in record.messages {
                messageData.append([
                    "content": message.content,
                    "reasoning_content": message.reasoningContent as Any,
                    "is_user": message.isUser,
                    "timestamp": ISO8601DateFormatter().string(from: message.timestamp)
                ])
            }
            
            uploadData.append([
                "id": record.id.uuidString,
                "title": record.title,
                "last_message": record.lastMessage,
                "timestamp": ISO8601DateFormatter().string(from: record.timestamp),
                "messages": messageData
            ])
        }
        
        let parameters: [String: Any] = [
            "user_id": userId,
            "chat_records": uploadData
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            print("上传请求参数准备完成")
        } catch {
            print("上传参数序列化失败：\(error)")
            completion(.failure(error))
            return
        }
        
        print("发送上传请求到：\(url)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("上传请求失败：\(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("上传HTTP响应状态码：\(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("上传请求无数据返回")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "无数据返回"])))
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("上传响应数据：\(responseString)")
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let success = json["success"] as? Bool, success {
                        print("聊天记录上传成功")
                        completion(.success(true))
                    } else if let error = json["error"] as? String {
                        print("服务器返回错误：\(error)")
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: error])))
                    } else {
                        print("未知响应格式")
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "未知响应格式"])))
                    }
                } else {
                    print("无法解析响应JSON")
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法解析响应"])))
                }
            } catch {
                print("解析上传响应失败：\(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    // 添加下载聊天记录的方法
    func downloadChatRecords(userId: Int, completion: @escaping (Result<[ChatRecord], Error>) -> Void) {
        print("开始下载用户ID \(userId) 的聊天记录")
        
        let url = URL(string: "\(baseURL)/api/download_chats.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 准备请求参数
        let parameters = [
            "user_id": userId
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            print("下载请求参数准备完成")
        } catch {
            print("下载参数序列化失败：\(error)")
            completion(.failure(error))
            return
        }
        
        print("发送下载请求到：\(url)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("下载请求失败：\(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("下载HTTP响应状态码：\(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("下载请求无数据返回")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "无数据返回"])))
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("下载响应原始数据: \(responseString)")
            }
            
            do {
                // 尝试先解析为字典，查看实际返回的结构
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("下载响应JSON结构: \(json)")
                    
                    // 检查是否有错误信息
                    if let error = json["error"] as? String {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: error])))
                        return
                    }
                    
                    // 如果成功但没有聊天记录
                    if let chatRecordsArray = json["chat_records"] as? [[String: Any]], chatRecordsArray.isEmpty {
                        print("用户没有云端聊天记录")
                        completion(.success([]))
                        return
                    }
                }
                
                // 解析聊天记录
                let decoder = JSONDecoder()
                let dateFormatter = ISO8601DateFormatter()
                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)
                    if let date = dateFormatter.date(from: dateString) {
                        return date
                    }
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format")
                }
                
                let response = try decoder.decode(ChatRecordsResponse.self, from: data)
                print("成功下载 \(response.chatRecords.count) 条聊天记录")
                completion(.success(response.chatRecords))
            } catch {
                print("解析下载响应失败：\(error)")
                print("详细错误信息：\(String(describing: error))")
                completion(.failure(error))
            }
        }.resume()
    }
}

// 添加解析响应的模型
struct ChatRecordsResponse: Codable {
    let success: Bool
    let chatRecords: [ChatRecord]
    
    enum CodingKeys: String, CodingKey {
        case success
        case chatRecords = "chat_records"
    }
} 
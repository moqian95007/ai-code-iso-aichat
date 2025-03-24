import Foundation

// 定义一个新的结构体来保存API响应内容
struct AIResponse {
    let content: String
    let reasoningContent: String?
}

class ChatService {
    private let apiURL = "https://api.siliconflow.cn/v1/chat/completions"
    private let apiKey = "sk-ufpvhjcjzzagkmrmhbxfbvyjecfstnwfevktlxnzexygzwos" // 可以考虑从安全的地方获取
    
    func sendMessage(_ message: String, model: String = "deepseek-ai/DeepSeek-V3", completion: @escaping (Result<AIResponse, Error>) -> Void) {
        print("正在使用模型: \(model) 发送消息")
        
        // 构建请求体
        let requestBody: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "user", "content": message]
            ],
            "stream": false,
            "max_tokens": 512,
            "temperature": 0.7,
            "top_p": 0.7,
            "top_k": 50,
            "frequency_penalty": 0.5,
            "n": 1,
            "response_format": [
                "type": "text"
            ]
        ]
        
        // 创建请求
        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(error))
            return
        }
        
        // 发送请求
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            // 打印响应数据，用于调试
            if let responseString = String(data: data, encoding: .utf8) {
                print("API Response:", responseString)
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    // 尝试获取reasoning_content
                    let reasoningContent = message["reasoning_content"] as? String
                    
                    let response = AIResponse(content: content, reasoningContent: reasoningContent)
                    completion(.success(response))
                } else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
} 
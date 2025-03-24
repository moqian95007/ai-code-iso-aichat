import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                // 显示思考内容（仅非用户消息且有思考内容时）
                if !message.isUser, let reasoningContent = message.reasoningContent, !reasoningContent.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "brain.filled")
                                .foregroundColor(.gray)
                            Text("已深度思考")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            // Text("(用时 2 秒)")  // 这个可以是一个估计值或固定值
                            //     .font(.system(size: 12))
                            //     .foregroundColor(.gray)
                            Spacer()
                        }
                        
                        Text(reasoningContent)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.gray.opacity(0.1))
                            .foregroundColor(.gray)
                            .cornerRadius(20)
                    }
                    .padding(.bottom, 8)
                }
                
                // 显示消息内容
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(message.isUser ? Color.blue : Color(UIColor.systemGray6))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(20)
                
                Text(formatDate(message.timestamp))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            if !message.isUser {
                Spacer()
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    VStack(spacing: 20) {
        MessageBubbleView(message: Message(content: "你好,我是AI助手", isUser: false, timestamp: Date()))
        MessageBubbleView(message: Message(content: "你好,请问有什么可以帮你的吗?", isUser: true, timestamp: Date()))
    }
    .padding()
} 
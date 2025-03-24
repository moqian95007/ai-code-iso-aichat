import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    @State private var showReasoning = false // 控制展开/折叠状态
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                // 显示思考内容（仅非用户消息且有思考内容时）
                if !message.isUser, let reasoningContent = message.reasoningContent, !reasoningContent.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Button(action: {
                            withAnimation {
                                showReasoning.toggle()
                            }
                        }) {
                            HStack {
                                Image(systemName: "brain.filled")
                                    .foregroundColor(.green) // 更改为绿色以匹配深度思考按钮
                                
                                Text("深度思考")
                                    .font(.system(size: 12))
                                    .foregroundColor(.green)
                                
                                Image(systemName: showReasoning ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 10))
                                    .foregroundColor(.green)
                                
                                Spacer()
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if showReasoning {
                            Text(reasoningContent)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.gray.opacity(0.1))
                                .foregroundColor(.gray)
                                .cornerRadius(20)
                                .transition(.opacity)
                        }
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
        MessageBubbleView(message: Message(
            content: "你好,我是AI助手", 
            reasoningContent: "这是我的思考过程，通常会比较长，用户可以通过展开/折叠来查看",
            isUser: false, 
            timestamp: Date()
        ))
        MessageBubbleView(message: Message(
            content: "你好,请问有什么可以帮你的吗?", 
            isUser: true, 
            timestamp: Date()
        ))
    }
    .padding()
} 
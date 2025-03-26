import SwiftUI

struct ChatView: View {
    @State private var messageText: String = ""
    @State private var messages: [Message] = []
    @State private var isLoading = false
    @State private var isDeepThinking = true  // 默认选中状态
    @State private var showLoginSheet = false
    @State private var isLoggedIn = false
    @State private var remainingChats = 3
    @State private var userEmail: String?
    @EnvironmentObject var chatStore: ChatStore
    @Binding var chatRecord: ChatRecord?
    var onStartNewChat: (() -> Void)?
    var onUpdateChatRecord: ((ChatRecord) -> Void)?
    
    private let chatService = ChatService()
    
    // 为了向后兼容，添加一个无需绑定的初始化方法
    init(chatRecord: ChatRecord? = nil, onStartNewChat: (() -> Void)? = nil, onUpdateChatRecord: ((ChatRecord) -> Void)? = nil) {
        self._chatRecord = .constant(chatRecord)
        self.onStartNewChat = onStartNewChat
        self.onUpdateChatRecord = onUpdateChatRecord
        if let record = chatRecord {
            _messages = State(initialValue: record.messages)
        } else {
            _messages = State(initialValue: [])
        }
    }
    
    // 新的初始化方法，使用绑定
    init(chatRecord: Binding<ChatRecord?>, onStartNewChat: (() -> Void)? = nil, onUpdateChatRecord: ((ChatRecord) -> Void)? = nil) {
        self._chatRecord = chatRecord
        self.onStartNewChat = onStartNewChat
        self.onUpdateChatRecord = onUpdateChatRecord
        if let record = chatRecord.wrappedValue {
            _messages = State(initialValue: record.messages)
        } else {
            _messages = State(initialValue: [])
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 导航栏
            HStack {
                Text(chatRecord?.title ?? "小莫 DeepSeek")
                    .font(.title2)
                    .bold()
                Spacer()
                
                // 只保留登录按钮
                Button(action: {
                    showLoginSheet = true
                }) {
                    HStack {
                        if isLoggedIn {
                            Text(userEmail ?? "")
                                .foregroundColor(.blue)
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.blue)
                        } else {
                            Text("登录")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            
            // 聊天内容区
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubbleView(message: message)
                                .id(message.id)
                        }
                        
                        // 添加加载指示器
                        if isLoading {
                            HStack(alignment: .center) {
                                Image(systemName: "leaf.fill")
                                    .foregroundColor(.green)
                                    .padding(8)
                                    .background(Color(UIColor.systemGray6))
                                    .clipShape(Circle())
                                
                                LoadingBubbleView()
                            }
                            .id("loadingIndicator")
                            .padding(.top, 16)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _ in
                    if let lastMessage = messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: isLoading) { loading in
                    // 当加载状态改变时，如果是开始加载，滚动到加载指示器
                    if loading {
                        withAnimation {
                            proxy.scrollTo("loadingIndicator", anchor: .bottom)
                        }
                    }
                }
                .onAppear {
                    // 确保滚动到最后一条消息
                    if let lastMessage = messages.last {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            
            // 输入区域
            VStack(spacing: 8) {
                if !isLoggedIn {
                    HStack {
                        Text("剩余对话次数：\(remainingChats)")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                
                // 深度思考按钮
                HStack {
                    Spacer()
                    Button(action: {
                        isDeepThinking.toggle()
                        print("深度思考模式: \(isDeepThinking ? "开启" : "关闭")")
                    }) {
                        HStack {
                            Image(systemName: "brain")
                            Text("深度思考")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(isDeepThinking ? Color.green : Color.gray.opacity(0.2))
                        .foregroundColor(isDeepThinking ? .white : .gray)
                        .cornerRadius(16)
                    }
                    Spacer()
                }
                
                // 输入框和发送按钮
                HStack(spacing: 8) {
                    TextField("有问题，尽管问", text: $messageText)
                        .padding(10)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(20)
                        .disabled(isLoading)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(isLoading ? Color.gray : Color.blue)
                            .clipShape(Circle())
                    }
                    .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                }
                
                // 新增对话按钮移到底部
                Button(action: {
                    messages = []
                    onStartNewChat?()
                }) {
                    HStack {
                        Image(systemName: "square.and.pencil")
                        Text("新对话")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                }
                .padding(.top, 8)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
        }
        .onAppear {
            // 每次视图出现时，确保从chatRecord加载消息
            if let record = chatRecord, messages.isEmpty {
                messages = record.messages
            }
            
            // 检查登录状态
            if let token = UserDefaults.standard.string(forKey: "userToken"),
               let email = UserDefaults.standard.string(forKey: "userEmail") {
                isLoggedIn = true
                userEmail = email
                remainingChats = Int.max // 登录用户无限制
            }
        }
        .onChange(of: chatRecord?.id) { _ in
            if let record = chatRecord {
                messages = record.messages
            } else {
                messages = []
            }
        }
        .sheet(isPresented: $showLoginSheet) {
            LoginView()
        }
    }
    
    private func sendMessage() {
        let userMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !userMessage.isEmpty else { return }
        
        // 检查未登录用户的对话次数
        if !isLoggedIn && remainingChats <= 0 {
            let errorMessage = Message(content: "您已达到未登录用户的对话次数限制，请登录后继续使用", isUser: false, timestamp: Date())
            messages.append(errorMessage)
            return
        }
        
        // 添加用户消息
        let userMessageObj = Message(content: userMessage, isUser: true, timestamp: Date())
        messages.append(userMessageObj)
        messageText = ""
        
        // 如果是未登录用户，减少剩余对话次数
        if !isLoggedIn {
            remainingChats -= 1
        }
        
        isLoading = true
        
        // 根据深度思考状态选择模型
        let model = isDeepThinking ? "deepseek-ai/DeepSeek-R1" : "deepseek-ai/DeepSeek-V3"
        print("使用模型: \(model)")
        
        // 发送到API - 明确传递模型参数
        chatService.sendMessage(userMessage, model: model) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let response):
                    let aiMessage = Message(
                        content: response.content,
                        reasoningContent: response.reasoningContent,
                        isUser: false,
                        timestamp: Date()
                    )
                    messages.append(aiMessage)
                    
                    // 修改保存聊天记录的逻辑
                    if let record = chatRecord {
                        // 更新现有聊天记录
                        let updatedRecord = ChatRecord(
                            id: record.id,
                            title: record.title,
                            lastMessage: response.content,
                            timestamp: Date(),
                            messages: messages
                        )
                        chatStore.updateChatRecord(updatedRecord)
                        onUpdateChatRecord?(updatedRecord)
                    } else if messages.count >= 2 {  // 只在有对话内容时创建新记录
                        // 创建新记录并更新绑定
                        let newRecord = chatStore.addChatRecord(messages)
                        chatRecord = newRecord  // 更新绑定，防止重复创建
                        onUpdateChatRecord?(newRecord)
                    }
                    
                case .failure(let error):
                    let errorMessage = Message(content: "抱歉，发生了错误：\(error.localizedDescription)", isUser: false, timestamp: Date())
                    messages.append(errorMessage)
                }
            }
        }
    }
}

// 添加一个自定义的Toggle样式，使其看起来像一个按钮
struct CustomToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            // 通过点击改变配置的isOn值
            configuration.isOn.toggle()
        }) {
            HStack {
                configuration.label
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
            }
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(configuration.isOn ? Color.green : Color.gray.opacity(0.15))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ChatView()
        .environmentObject(ChatStore())
} 
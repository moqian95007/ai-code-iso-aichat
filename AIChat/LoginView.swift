import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isRegistering = false
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @EnvironmentObject var chatStore: ChatStore
    
    // 添加一个登录成功的回调
    var onLoginSuccess: (() -> Void)?
    
    private let authService = AuthService()
    
    // 添加一个计算属性来检查表单是否有效
    private var isFormValid: Bool {
        if email.isEmpty || password.isEmpty {
            return false
        }
        
        if isRegistering && password != confirmPassword {
            return false
        }
        
        return true
    }
    
    // 添加一个属性来获取具体的错误信息
    private var formValidationMessage: String? {
        if email.isEmpty || password.isEmpty {
            return "请填写邮箱和密码"
        }
        
        if isRegistering && password != confirmPassword {
            return "两次输入的密码不一致"
        }
        
        return nil
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Logo或标题
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue)
                    .padding(.top, 40)
                
                Text(isRegistering ? "创建账号" : "欢迎回来")
                    .font(.title2)
                    .bold()
                
                VStack(spacing: 15) {
                    TextField("邮箱", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .onChange(of: email) { _ in
                            print("邮箱输入：\(email)")
                        }
                    
                    SecureField("密码", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: password) { _ in
                            print("密码输入：\(password.count)个字符")
                        }
                    
                    if isRegistering {
                        SecureField("确认密码", text: $confirmPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: confirmPassword) { _ in
                                print("确认密码输入：\(confirmPassword.count)个字符")
                            }
                    }
                }
                .padding(.horizontal)
                
                // 显示表单验证错误
                if let message = formValidationMessage {
                    Text(message)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                Button(action: {
                    print("按钮点击：\(isRegistering ? "注册" : "登录")")
                    handleAuthAction()
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text(isRegistering ? "注册" : "登录")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(isFormValid ? Color.blue : Color.gray)
                .cornerRadius(10)
                .padding(.horizontal)
                .disabled(!isFormValid || isLoading)
                
                // 显示网络请求错误
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                Button(action: {
                    isRegistering.toggle()
                    // 切换时清空确认密码
                    confirmPassword = ""
                    print("切换到\(isRegistering ? "注册" : "登录")模式")
                }) {
                    Text(isRegistering ? "已有账号？点击登录" : "没有账号？点击注册")
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
            .navigationBarItems(trailing: Button("关闭") {
                dismiss()
            })
        }
    }
    
    private func handleAuthAction() {
        print("开始处理\(isRegistering ? "注册" : "登录")请求")
        
        // 再次验证表单
        guard isFormValid else {
            errorMessage = formValidationMessage
            print("验证失败：\(formValidationMessage ?? "未知错误")")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        print("准备发送请求...")
        
        let completion: (Result<User, Error>) -> Void = { [self] result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let user):
                    print("认证成功：保存用户信息")
                    // 保存用户信息到 UserDefaults
                    UserDefaults.standard.set(user.token, forKey: "userToken")
                    UserDefaults.standard.set(user.email, forKey: "userEmail")
                    UserDefaults.standard.set(user.id, forKey: "userId")
                    
                    // 上传现有的聊天记录
                    if !chatStore.chatRecords.isEmpty {
                        print("准备上传 \(chatStore.chatRecords.count) 条聊天记录")
                        authService.uploadChatRecords(chatRecords: chatStore.chatRecords, userId: user.id) { uploadResult in
                            switch uploadResult {
                            case .success(_):
                                print("所有聊天记录上传完成")
                                
                                // 上传完成后下载服务器上的聊天记录
                                self.authService.downloadChatRecords(userId: user.id) { downloadResult in
                                    DispatchQueue.main.async {
                                        switch downloadResult {
                                        case .success(let downloadedRecords):
                                            print("下载了 \(downloadedRecords.count) 条聊天记录")
                                            self.chatStore.mergeChatRecords(downloadedRecords: downloadedRecords)
                                        case .failure(let error):
                                            print("下载聊天记录失败：\(error.localizedDescription)")
                                            // 下载失败不影响登录流程，只记录日志
                                        }
                                    }
                                }
                                
                            case .failure(let error):
                                print("上传聊天记录失败：\(error.localizedDescription)")
                                // 上传失败也尝试下载
                                self.authService.downloadChatRecords(userId: user.id) { downloadResult in
                                    DispatchQueue.main.async {
                                        switch downloadResult {
                                        case .success(let downloadedRecords):
                                            print("下载了 \(downloadedRecords.count) 条聊天记录")
                                            self.chatStore.mergeChatRecords(downloadedRecords: downloadedRecords)
                                        case .failure(let error):
                                            print("下载聊天记录失败：\(error.localizedDescription)")
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        // 如果没有本地聊天记录，直接下载
                        authService.downloadChatRecords(userId: user.id) { downloadResult in
                            DispatchQueue.main.async {
                                switch downloadResult {
                                case .success(let downloadedRecords):
                                    print("下载了 \(downloadedRecords.count) 条聊天记录")
                                    self.chatStore.mergeChatRecords(downloadedRecords: downloadedRecords)
                                case .failure(let error):
                                    print("下载聊天记录失败：\(error.localizedDescription)")
                                }
                            }
                        }
                    }
                    
                    // 调用登录成功回调
                    onLoginSuccess?()
                    dismiss()
                    
                case .failure(let error):
                    print("认证失败：\(error.localizedDescription)")
                    errorMessage = error.localizedDescription
                }
            }
        }
        
        if isRegistering {
            print("调用注册服务...")
            // 注册成功后直接关闭登录界面，用户已经自动登录
            authService.register(email: email, password: password, completion: completion)
        } else {
            print("调用登录服务...")
            authService.login(email: email, password: password, completion: completion)
        }
    }
}

#Preview {
    LoginView()
} 
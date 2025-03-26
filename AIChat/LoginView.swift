import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isRegistering = false
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let authService = AuthService()
    
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
                    
                    SecureField("密码", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if isRegistering {
                        SecureField("确认密码", text: $confirmPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .padding(.horizontal)
                
                Button(action: handleAuthAction) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text(isRegistering ? "注册" : "登录")
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                .disabled(isLoading || (isRegistering && password != confirmPassword))
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: {
                    isRegistering.toggle()
                    // 切换时清空确认密码
                    confirmPassword = ""
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
        guard !email.isEmpty && !password.isEmpty else {
            errorMessage = "请填写邮箱和密码"
            return
        }
        
        if isRegistering && password != confirmPassword {
            errorMessage = "两次输入的密码不一致"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let completion: (Result<User, Error>) -> Void = { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let user):
                    // 保存用户信息到 UserDefaults
                    UserDefaults.standard.set(user.token, forKey: "userToken")
                    UserDefaults.standard.set(user.email, forKey: "userEmail")
                    UserDefaults.standard.set(user.id, forKey: "userId")
                    dismiss()
                    
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
        
        if isRegistering {
            authService.register(email: email, password: password, completion: completion)
        } else {
            authService.login(email: email, password: password, completion: completion)
        }
    }
}

#Preview {
    LoginView()
} 
import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isRegistering = false
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
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
                
                Button(action: {
                    // TODO: 实现登录/注册逻辑
                }) {
                    Text(isRegistering ? "注册" : "登录")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(isRegistering && password != confirmPassword)
                
                if isRegistering && password != confirmPassword && !password.isEmpty && !confirmPassword.isEmpty {
                    Text("两次输入的密码不一致")
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
}

#Preview {
    LoginView()
} 
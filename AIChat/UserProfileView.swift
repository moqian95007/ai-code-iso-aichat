import SwiftUI

struct UserProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var userEmail: String
    @EnvironmentObject var chatStore: ChatStore
    
    // 用于处理退出登录的闭包
    var onLogout: () -> Void
    
    init(email: String, onLogout: @escaping () -> Void) {
        self._userEmail = State(initialValue: email)
        self.onLogout = onLogout
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // 头像
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding(.top, 40)
                
                // 用户信息
                VStack(spacing: 10) {
                    Text("您的账号")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text(userEmail)
                        .font(.title2)
                        .bold()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                Spacer()
                
                // 退出登录按钮
                Button(action: {
                    // 清空聊天记录
                    chatStore.clearChatRecords()
                    // 调用退出登录闭包
                    onLogout()
                    dismiss()
                }) {
                    Text("退出登录")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .navigationBarItems(trailing: Button("关闭") {
                dismiss()
            })
            .navigationTitle("个人中心")
        }
    }
}

#Preview {
    UserProfileView(email: "test@example.com", onLogout: {})
        .environmentObject(ChatStore())
} 
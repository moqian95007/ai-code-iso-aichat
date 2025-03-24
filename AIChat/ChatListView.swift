import SwiftUI

struct ChatListView: View {
    @State private var searchText = ""
    @EnvironmentObject var chatStore: ChatStore
    @State private var showingDeleteAlert = false
    @State private var recordToDelete: ChatRecord?
    var onSelectChatRecord: ((ChatRecord) -> Void)?
    
    var filteredRecords: [ChatRecord] {
        if searchText.isEmpty {
            return chatStore.chatRecords
        }
        return chatStore.chatRecords.filter { record in
            record.title.localizedCaseInsensitiveContains(searchText) ||
            record.lastMessage.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var groupedRecords: [(String, [ChatRecord])] {
        let calendar = Calendar.current
        
        return Dictionary(grouping: filteredRecords) { record in
            if calendar.isDateInToday(record.timestamp) {
                return "今天"
            } else if calendar.isDateInYesterday(record.timestamp) {
                return "昨天"
            } else {
                return "更早"
            }
        }
        .sorted { group1, group2 in
            let order = ["今天", "昨天", "更早"]
            return order.firstIndex(of: group1.key)! < order.firstIndex(of: group2.key)!
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索栏
                SearchBar(text: $searchText)
                    .padding()
                
                if chatStore.chatRecords.isEmpty {
                    VStack {
                        Spacer()
                        Text("暂无聊天记录")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(groupedRecords, id: \.0) { section in
                            Section(header: Text(section.0)) {
                                ForEach(section.1) { record in
                                    if let selectAction = onSelectChatRecord {
                                        Button(action: {
                                            selectAction(record)
                                        }) {
                                            ChatRecordRow(record: record)
                                        }
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                recordToDelete = record
                                                showingDeleteAlert = true
                                            } label: {
                                                Label("删除", systemImage: "trash")
                                            }
                                        }
                                    } else {
                                        NavigationLink(destination: ChatView(chatRecord: record)) {
                                            ChatRecordRow(record: record)
                                        }
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                recordToDelete = record
                                                showingDeleteAlert = true
                                            } label: {
                                                Label("删除", systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("聊天记录")
            .alert("确认删除", isPresented: $showingDeleteAlert, presenting: recordToDelete) { record in
                Button("删除", role: .destructive) {
                    withAnimation {
                        chatStore.deleteChatRecord(record)
                    }
                }
                Button("取消", role: .cancel) {}
            } message: { record in
                Text("确定要删除这条聊天记录吗？此操作不可撤销。")
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("搜索聊天记录", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(8)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
    }
}

struct ChatRecordRow: View {
    let record: ChatRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(record.title)
                .font(.system(size: 17))
                .lineLimit(1)
                .foregroundColor(.primary)
            
            Text(record.lastMessage)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .lineLimit(1)
            
            Text(formatDate(record.timestamp))
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(date) {
            formatter.dateFormat = "HH:mm"
        } else {
            formatter.dateFormat = "MM-dd HH:mm"
        }
        return formatter.string(from: date)
    }
}

#Preview {
    ChatListView()
        .environmentObject(ChatStore())
} 
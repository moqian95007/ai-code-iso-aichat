//
//  ContentView.swift
//  AIChat
//
//  Created by moqian on 2025/3/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var chatStore = ChatStore()
    @State private var selectedTab = 0
    @State private var selectedChatRecord: ChatRecord?
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ChatView(
                chatRecord: $selectedChatRecord,
                onStartNewChat: {
                    selectedChatRecord = nil
                }
            )
            .tabItem {
                Label("聊天", systemImage: "message.fill")
            }
            .tag(0)
            
            ChatListView(onSelectChatRecord: { record in
                selectedChatRecord = record
                selectedTab = 0
            })
                .tabItem {
                    Label("记录", systemImage: "list.bullet")
                }
                .tag(1)
        }
        .environmentObject(chatStore)
    }
}

#Preview {
    ContentView()
}

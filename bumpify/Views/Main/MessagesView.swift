// MessagesView.swift - Ersetze deine bestehende MessagesView

import SwiftUI

struct MessagesView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var conversations: [BumpifyConversation] = []
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 16) {
                        HStack {
                            Text("💬 Chats")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Image(systemName: "square.and.pencil")
                                    .font(.title2)
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            
                            TextField("Suche in Chats...", text: $searchText)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding()
                    
                    // Conversations List
                    if conversations.isEmpty {
                        // Empty State
                        VStack(spacing: 20) {
                            Spacer()
                            
                            Image(systemName: "message.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("Noch keine Unterhaltungen")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text("Starte einen Bump, um neue Leute kennenzulernen!")
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            
                            Spacer()
                        }
                    } else {
                        // Conversations List
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredConversations) { conversation in
                                    ConversationRowView(conversation: conversation)
                                        .onTapGesture {
                                            // Navigate to chat detail
                                        }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
        }
        .onAppear {
            loadConversations()
        }
    }
    
    private var filteredConversations: [BumpifyConversation] {
        if searchText.isEmpty {
            return conversations
        }
        return conversations.filter { conversation in
            // In einer echten App würdest du hier nach Nutzernamen filtern
            conversation.messages.contains { message in
                message.text.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func loadConversations() {
        // Mock-Daten für Demo
        conversations = [
            BumpifyConversation(
                participants: [authManager.currentUser?.id ?? "", "user2"],
                messages: [
                    BumpifyMessage(
                        text: "Hey! War schön, dich heute zu treffen! 😊",
                        senderId: "user2",
                        receiverId: authManager.currentUser?.id ?? ""
                    ),
                    BumpifyMessage(
                        text: "Hi! Freut mich auch! Hast du Lust auf einen Kaffee?",
                        senderId: authManager.currentUser?.id ?? "",
                        receiverId: "user2"
                    )
                ]
            ),
            BumpifyConversation(
                participants: [authManager.currentUser?.id ?? "", "user3"],
                messages: [
                    BumpifyMessage(
                        text: "Cool, dass wir uns beim Joggen getroffen haben!",
                        senderId: "user3",
                        receiverId: authManager.currentUser?.id ?? ""
                    )
                ]
            )
        ]
    }
}

// MARK: - Conversation Row View
struct ConversationRowView: View {
    let conversation: BumpifyConversation
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile Image Placeholder
            Circle()
                .fill(Color.orange)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(getInitials())
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                )
            
            // Message Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(getOtherUserName())
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(getLastMessageTime())
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                if let lastMessage = conversation.lastMessage {
                    Text(lastMessage.text)
                        .font(.body)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                } else {
                    Text("Keine Nachrichten")
                        .font(.body)
                        .foregroundColor(.gray)
                        .italic()
                }
            }
            
            Spacer()
            
            // Unread Indicator (optional)
            if hasUnreadMessages() {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 12, height: 12)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func getInitials() -> String {
        // In einer echten App würdest du den anderen User aus der participants Liste laden
        return "U"
    }
    
    private func getOtherUserName() -> String {
        // In einer echten App würdest du den Namen des anderen Users anzeigen
        return "Chat Partner"
    }
    
    private func getLastMessageTime() -> String {
        guard let lastMessage = conversation.lastMessage else { return "" }
        
        let formatter = DateFormatter()
        let now = Date()
        let calendar = Calendar.current
        
        // Check if it's today
        if calendar.isDate(lastMessage.timestamp, inSameDayAs: now) {
            formatter.timeStyle = .short
            return formatter.string(from: lastMessage.timestamp)
        }
        
        // Check if it's yesterday
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now) ?? now
        if calendar.isDate(lastMessage.timestamp, inSameDayAs: yesterday) {
            return "Gestern"
        }
        
        // Otherwise show date
        formatter.dateStyle = .short
        return formatter.string(from: lastMessage.timestamp)
    }
    
    private func hasUnreadMessages() -> Bool {
        // Mock: Zeige manchmal ungelesene Nachrichten
        return conversation.messages.randomElement()?.isRead == false
    }
}

#Preview {
    MessagesView()
        .environmentObject(AuthenticationManager())
}

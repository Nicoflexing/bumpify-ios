// ChatDetailView.swift - Ersetze deine bestehende ChatDetailView

import SwiftUI

struct ChatDetailView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    let conversation: BumpifyConversation
    let otherUser: ChatUser // Vereinfachtes User Model für Chat
    
    @State private var messageText = ""
    @State private var messages: [BumpifyMessage] = []
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            chatHeader
            
            // Messages List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { message in
                        MessageBubble(
                            message: message,
                            isFromCurrentUser: message.senderId == (authManager.currentUser?.id ?? ""),
                            currentUserId: authManager.currentUser?.id ?? ""
                        )
                        .id(message.id)
                    }
                }
                .padding()
            }
            .background(Color.black)
            
            // Message Input
            messageInputView
        }
        .background(Color.black)
        .navigationBarHidden(true)
        .onAppear {
            loadMessages()
        }
    }
    
    // MARK: - Chat Header
    private var chatHeader: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            // Profile Image
            Circle()
                .fill(Color.orange)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(otherUser.initials)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(otherUser.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Online") // In einer echten App würdest du den echten Status anzeigen
                    .font(.caption)
                    .foregroundColor(.green)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "info.circle")
                    .font(.title2)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.black)
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    // MARK: - Message Input
    private var messageInputView: some View {
        HStack(spacing: 12) {
            TextField("Nachricht schreiben...", text: $messageText, axis: .vertical)
                .lineLimit(1...4)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(20)
                .foregroundColor(.white)
                .focused($isTextFieldFocused)
            
            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundColor(messageText.isEmpty ? .gray : .orange)
            }
            .disabled(messageText.isEmpty)
        }
        .padding()
        .background(Color.black)
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1),
            alignment: .top
        )
    }
    
    // MARK: - Actions
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newMessage = BumpifyMessage(
            text: messageText.trimmingCharacters(in: .whitespacesAndNewlines),
            senderId: authManager.currentUser?.id ?? "",
            receiverId: otherUser.id,
            timestamp: Date(),
            isRead: false
        )
        
        messages.append(newMessage)
        messageText = ""
        
        // In einer echten App würdest du hier die Nachricht an dein Backend senden
        
        // Simuliere eine Antwort nach kurzer Zeit
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            simulateReply()
        }
    }
    
    private func simulateReply() {
        let replies = [
            "Das klingt super! 😊",
            "Ja, gerne!",
            "Wann hättest du Zeit?",
            "Kein Problem! 👍",
            "Das ist eine gute Idee!",
            "Lass uns das machen!"
        ]
        
        let randomReply = replies.randomElement() ?? "Danke für deine Nachricht!"
        
        let replyMessage = BumpifyMessage(
            text: randomReply,
            senderId: otherUser.id,
            receiverId: authManager.currentUser?.id ?? "",
            timestamp: Date(),
            isRead: false
        )
        
        messages.append(replyMessage)
    }
    
    private func loadMessages() {
        messages = conversation.messages.sorted { $0.timestamp < $1.timestamp }
    }
    
    private func scrollToBottom(proxy: Any) {
        // Function removed - using simple ScrollView now
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: BumpifyMessage
    let isFromCurrentUser: Bool
    let currentUserId: String
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.body)
                    .foregroundColor(isFromCurrentUser ? .white : .black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        Group {
                            if isFromCurrentUser {
                                LinearGradient(colors: [Color.orange, Color.red], startPoint: .leading, endPoint: .trailing)
                            } else {
                                Color.white
                            }
                        }
                    )
                    .cornerRadius(16)
                
                Text(formatMessageTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: isFromCurrentUser ? .trailing : .leading)
            
            if !isFromCurrentUser {
                Spacer()
            }
        }
    }
    
    private func formatMessageTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Simplified Chat User Model
struct ChatUser {
    let id: String
    let name: String
    let initials: String
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
        
        let components = name.components(separatedBy: " ")
        let firstInitial = components.first?.first?.uppercased() ?? ""
        let lastInitial = components.count > 1 ? components.last?.first?.uppercased() ?? "" : ""
        self.initials = "\(firstInitial)\(lastInitial)"
    }
}

// MARK: - Preview
#Preview {
    let sampleConversation = BumpifyConversation(
        participants: ["user1", "user2"],
        messages: [
            BumpifyMessage(text: "Hey! Schön dich kennenzulernen!", senderId: "user2", receiverId: "user1"),
            BumpifyMessage(text: "Hi! Freut mich auch! 😊", senderId: "user1", receiverId: "user2"),
            BumpifyMessage(text: "Hast du Lust auf einen Kaffee später?", senderId: "user2", receiverId: "user1")
        ]
    )
    
    let sampleUser = ChatUser(id: "user2", name: "Anna Schmidt")
    
    ChatDetailView(conversation: sampleConversation, otherUser: sampleUser)
        .environmentObject(AuthenticationManager())
}

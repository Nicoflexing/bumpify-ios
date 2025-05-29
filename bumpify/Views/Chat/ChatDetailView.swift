import SwiftUI

struct ChatDetailView: View {
    let conversation: BumpifyConversation
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var messageText = ""
    @State private var messages: [BumpifyMessage] = []
    @State private var isTyping = false
    
    private var otherUser: BumpifyUser? {
        guard let currentUserId = authManager.getCurrentUserId() else { return nil }
        return conversation.otherParticipant(currentUserId: currentUserId)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.12, blue: 0.18).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom Header
                    chatHeader
                    
                    // Messages List
                    messagesSection
                    
                    // Message Input
                    messageInputSection
                }
            }
        }
        .onAppear {
            loadMessages()
        }
    }
    
    // MARK: - Chat Header
    private var chatHeader: some View {
        HStack(spacing: 16) {
            // Back Button
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.1))
            }
            
            // Profile Image
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Group {
                        if let user = otherUser {
                            Text(user.firstName.prefix(1))
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                )
            
            // User Info
            VStack(alignment: .leading, spacing: 2) {
                Text(otherUser?.fullName ?? "Unbekannt")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(isTyping ? "schreibt..." : "zuletzt aktiv vor 2 Min")
                    .font(.caption)
                    .foregroundColor(isTyping ? Color(red: 1.0, green: 0.5, blue: 0.1) : .white.opacity(0.6))
            }
            
            Spacer()
            
            // More Options
            Button(action: {
                // Show options menu
            }) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
        .background(Color(red: 0.1, green: 0.12, blue: 0.18))
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    // MARK: - Messages Section
    private var messagesSection: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // Bump Context Card
                bumpContextCard
                
                // Messages
                ForEach(messages) { message in
                    MessageBubble(
                        message: message,
                        isFromCurrentUser: authManager.isCurrentUser(message.senderId),
                        otherUser: otherUser
                    )
                }
                
                // Typing Indicator
                if isTyping {
                    TypingIndicator(user: otherUser)
                }
            }
            .padding()
        }
        .flipsForRightToLeftLayoutDirection(false)
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    // MARK: - Bump Context Card
    private var bumpContextCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "location.circle.fill")
                    .font(.title2)
                    .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.2))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ihr habt euch via Bump kennengelernt!")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Text("Gestern um 14:30 • Murphy's Pub")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
            }
            
            if let user = otherUser, !user.interests.isEmpty {
                HStack {
                    Text("Gemeinsame Interessen:")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    ForEach(user.interests.prefix(3), id: \.self) { interest in
                        Text(interest)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color(red: 1.0, green: 0.5, blue: 0.1).opacity(0.2))
                            .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.1))
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(red: 1.0, green: 0.4, blue: 0.2).opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Message Input Section
    private var messageInputSection: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1)
            
            HStack(spacing: 12) {
                // Attachment Button
                Button(action: {
                    // Add attachment
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                // Text Input
                HStack {
                    TextField("Nachricht schreiben...", text: $messageText, axis: .vertical)
                        .lineLimit(1...4)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                .background(Color.white.opacity(0.1))
                .cornerRadius(20)
                
                // Send Button
                Button(action: sendMessage) {
                    Image(systemName: messageText.isEmpty ? "mic.fill" : "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(messageText.isEmpty ? .white.opacity(0.6) : Color(red: 1.0, green: 0.5, blue: 0.1))
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            .background(Color(red: 0.1, green: 0.12, blue: 0.18))
        }
    }
    
    // MARK: - Helper Methods
    private func sendMessage() {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty,
              let currentUserId = authManager.getCurrentUserId() else { return }
        
        let newMessage = BumpifyMessage(
            text: trimmedText,
            senderId: currentUserId,
            timestamp: Date()
        )
        
        messages.append(newMessage)
        messageText = ""
        
        // Simulate other user typing and responding
        simulateOtherUserResponse()
    }
    
    private func simulateOtherUserResponse() {
        guard let otherUser = otherUser else { return }
        
        // Show typing indicator
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isTyping = true
        }
        
        // Send response after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            isTyping = false
            
            let responses = [
                "Das klingt interessant! 😊",
                "Ja, das denke ich auch!",
                "Haha, definitiv! 😄",
                "Stimmt, da hast du recht!",
                "Das wäre cool!",
                "Auf jeden Fall! Wann hast du Zeit?"
            ]
            
            let randomResponse = responses.randomElement() ?? "Interessant!"
            
            let responseMessage = BumpifyMessage(
                text: randomResponse,
                senderId: otherUser.id,
                timestamp: Date()
            )
            
            withAnimation(.easeInOut) {
                messages.append(responseMessage)
            }
        }
    }
    
    private func loadMessages() {
        messages = conversation.messages
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: BumpifyMessage
    let isFromCurrentUser: Bool
    let otherUser: BumpifyUser?
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                // Message Content
                HStack {
                    if !isFromCurrentUser {
                        // Other user's profile pic
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text(otherUser?.firstName.prefix(1) ?? "?")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                    }
                    
                    VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 2) {
                        Text(message.text)
                            .font(.body)
                            .foregroundColor(isFromCurrentUser ? .white : .white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                isFromCurrentUser ?
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.4, blue: 0.2),
                                        Color(red: 1.0, green: 0.6, blue: 0.0)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ) :
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.15)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(
                                RoundedRectangle(cornerRadius: 16)
                            )
                        
                        // Timestamp
                        Text(formatTime(message.timestamp))
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.horizontal, 4)
                    }
                }
            }
            
            if !isFromCurrentUser {
                Spacer(minLength: 60)
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Typing Indicator
struct TypingIndicator: View {
    let user: BumpifyUser?
    @State private var animationOffset = false
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 32, height: 32)
                .overlay(
                    Text(user?.firstName.prefix(1) ?? "?")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .scaleEffect(animationOffset ? 1.2 : 0.8)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: animationOffset
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Spacer(minLength: 60)
        }
        .onAppear {
            animationOffset = true
        }
    }
}

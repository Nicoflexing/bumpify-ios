// ChatDetailView.swift - Verbesserte Version
// Ersetze deine bestehende ChatDetailView.swift komplett mit diesem Code

import SwiftUI

struct ChatDetailView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    let conversation: BumpifyConversation
    let otherUser: ChatUser
    
    @State private var messageText = ""
    @State private var messages: [BumpifyMessage] = []
    @State private var isTyping = false
    @State private var showingUserProfile = false
    @State private var showingImagePicker = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Enhanced Header
            chatHeader
            
            // Messages List with better styling
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Date header
                        Text("Heute")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.vertical, 8)
                        
                        ForEach(messages) { message in
                            EnhancedMessageBubble(
                                message: message,
                                isFromCurrentUser: message.senderId == (authManager.currentUser?.id ?? ""),
                                currentUserId: authManager.currentUser?.id ?? ""
                            )
                            .id(message.id)
                        }
                        
                        // Typing indicator
                        if isTyping {
                            TypingIndicator()
                        }
                    }
                    .padding()
                }
                .background(Color.black)
                .onTapGesture {
                    isTextFieldFocused = false
                }
                .onChange(of: messages.count) { _, _ in
                    if let lastMessage = messages.last {
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Enhanced Message Input
            enhancedMessageInput
        }
        .background(Color.black)
        .navigationBarHidden(true)
        .onAppear {
            loadMessages()
        }
        .sheet(isPresented: $showingUserProfile) {
            UserProfileSheet(user: otherUser)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerSheet()
        }
    }
    
    // MARK: - Enhanced Chat Header
    private var chatHeader: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Circle().fill(Color.white.opacity(0.1)))
            }
            
            // Enhanced Profile Section
            Button(action: { showingUserProfile = true }) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 45, height: 45)
                        
                        Text(otherUser.initials)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        // Online status
                        Circle()
                            .fill(Color.green)
                            .frame(width: 14, height: 14)
                            .overlay(
                                Circle()
                                    .stroke(Color.black, lineWidth: 2)
                            )
                            .offset(x: 16, y: 16)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(otherUser.name)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Online")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            
            Spacer()
            
            // Chat Actions
            HStack(spacing: 8) {
                Button(action: {}) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Circle().fill(Color.white.opacity(0.1)))
                }
                
                Button(action: {}) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Circle().fill(Color.white.opacity(0.1)))
                }
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
    
    // MARK: - Enhanced Message Input
    private var enhancedMessageInput: some View {
        VStack(spacing: 0) {
            // Input area
            HStack(spacing: 12) {
                // Attachment button
                Button(action: { showingImagePicker = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
                
                // Message input
                HStack(spacing: 8) {
                    TextField("Nachricht schreiben...", text: $messageText, axis: .vertical)
                        .lineLimit(1...4)
                        .font(.body)
                        .foregroundColor(.white)
                        .focused($isTextFieldFocused)
                        .onChange(of: messageText) { _, newValue in
                            if !newValue.isEmpty && !isTyping {
                                simulateTyping()
                            }
                        }
                    
                    // Emoji button
                    Button(action: {}) {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
                
                // Send button
                Button(action: sendMessage) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: messageText.isEmpty ? [.gray, .gray] : [.orange, .red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "arrow.up")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .disabled(messageText.isEmpty)
                .scaleEffect(messageText.isEmpty ? 0.8 : 1.0)
                .animation(.spring(response: 0.3), value: messageText.isEmpty)
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
        
        withAnimation(.easeOut(duration: 0.3)) {
            messages.append(newMessage)
        }
        messageText = ""
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Simulate reply
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            simulateReply()
        }
    }
    
    private func simulateReply() {
        let replies = [
            "Das klingt super! 😊",
            "Ja, gerne! 👍",
            "Wann hättest du Zeit?",
            "Kein Problem!",
            "Das ist eine gute Idee! 💡",
            "Lass uns das machen! 🎉"
        ]
        
        let randomReply = replies.randomElement() ?? "Danke für deine Nachricht!"
        
        let replyMessage = BumpifyMessage(
            text: randomReply,
            senderId: otherUser.id,
            receiverId: authManager.currentUser?.id ?? "",
            timestamp: Date(),
            isRead: false
        )
        
        withAnimation(.easeOut(duration: 0.3)) {
            messages.append(replyMessage)
            isTyping = false
        }
    }
    
    private func simulateTyping() {
        isTyping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isTyping = false
        }
    }
    
    private func loadMessages() {
        messages = conversation.messages.sorted { $0.timestamp < $1.timestamp }
    }
}

// MARK: - Enhanced Message Bubble
struct EnhancedMessageBubble: View {
    let message: BumpifyMessage
    let isFromCurrentUser: Bool
    let currentUserId: String
    
    @State private var showTime = false
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                // Message bubble
                HStack {
                    if !isFromCurrentUser {
                        VStack {
                            Spacer()
                            Text(formatMessageTime(message.timestamp))
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .opacity(showTime ? 1 : 0)
                        }
                    }
                    
                    Text(message.text)
                        .font(.body)
                        .foregroundColor(isFromCurrentUser ? .white : .black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            Group {
                                if isFromCurrentUser {
                                    LinearGradient(
                                        colors: [Color.orange, Color.red],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                } else {
                                    Color.white
                                }
                            }
                        )
                        .clipShape(
                            RoundedRectangle(cornerRadius: 18)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    
                    if isFromCurrentUser {
                        VStack {
                            Spacer()
                            HStack(spacing: 4) {
                                Text(formatMessageTime(message.timestamp))
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                    .opacity(showTime ? 1 : 0)
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption2)
                                    .foregroundColor(.green)
                                    .opacity(showTime ? 1 : 0)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: isFromCurrentUser ? .trailing : .leading)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showTime.toggle()
                }
            }
            
            if !isFromCurrentUser {
                Spacer(minLength: 60)
            }
        }
    }
    
    private func formatMessageTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Typing Indicator
struct TypingIndicator: View {
    @State private var animationPhase = 0
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .scaleEffect(animationPhase == index ? 1.2 : 0.8)
                        .opacity(animationPhase == index ? 1.0 : 0.5)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.1))
            .cornerRadius(18)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        animationPhase = (animationPhase + 1) % 3
                    }
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - User Profile Sheet
struct UserProfileSheet: View {
    let user: ChatUser
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("👤 Profil von \(user.name)")
                        .font(.title)
                        .foregroundColor(.white)
                    
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text(user.initials)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        )
                    
                    Text("Hier würden weitere Profilinformationen stehen")
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Schließen") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
    }
}

// MARK: - Image Picker Sheet
struct ImagePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    Text("📷 Bild senden")
                        .font(.title)
                        .foregroundColor(.white)
                    
                    Text("Bildauswahl würde hier implementiert")
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Schließen") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
    }
}

// MARK: - Chat User Model (falls nicht vorhanden)
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

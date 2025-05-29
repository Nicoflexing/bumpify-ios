import SwiftUI

struct ChatDetailView: View {
    let conversation: Conversation
    @State private var messageText = ""
    @State private var messages: [Message]
    @Environment(\.dismiss) private var dismiss
    
    init(conversation: Conversation) {
        self.conversation = conversation
        self._messages = State(initialValue: conversation.messages)
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Chat Header
                ChatHeaderView(user: conversation.user) {
                    dismiss()
                }
                
                // Messages
                ScrollView {
                    LazyVStack(spacing: 12) {
                        // Bump Context Card
                        BumpContextCard(user: conversation.user)
                        
                        ForEach(messages) { message in
                            MessageBubbleView(message: message)
                        }
                    }
                    .padding()
                }
                
                // Message Input
                MessageInputView(
                    messageText: $messageText,
                    onSend: sendMessage
                )
            }
        }
        .navigationBarHidden(true)
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newMessage = Message(
            id: UUID().uuidString,
            text: messageText,
            isFromCurrentUser: true,
            timestamp: Date()
        )
        
        messages.append(newMessage)
        messageText = ""
        
        // Simulate response after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let responses = [
                "Das ist interessant! 😊",
                "Erzähl mir mehr davon",
                "Cool! Wie lange machst du das schon?",
                "Das hätte ich nicht gedacht 🤔"
            ]
            
            if let response = responses.randomElement() {
                let responseMessage = Message(
                    id: UUID().uuidString,
                    text: response,
                    isFromCurrentUser: false,
                    timestamp: Date()
                )
                messages.append(responseMessage)
            }
        }
    }
}

struct ChatHeaderView: View {
    let user: User
    let onBack: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.orange)
            }
            
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: user.profileImage)
                    .font(.title3)
                    .foregroundColor(.orange)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(user.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Online")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "info.circle")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
    }
}

struct BumpContextCard: View {
    let user: User
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "location.circle.fill")
                .font(.title)
                .foregroundColor(.orange)
            
            Text("Ihr habt euch begegnet!")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Café Central • vor 2 Stunden")
                .font(.caption)
                .foregroundColor(.gray)
            
            if !user.interests.isEmpty {
                HStack {
                    Text("Gemeinsame Interessen:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    ForEach(user.interests.prefix(2), id: \.self) { interest in
                        Text(interest)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
        .padding(.bottom)
    }
}

struct MessageBubbleView: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isFromCurrentUser {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.text)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(18, corners: [.topLeft, .topRight, .bottomLeft])
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.text)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .foregroundColor(.white)
                        .cornerRadius(18, corners: [.topLeft, .topRight, .bottomRight])
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct MessageInputView: View {
    @Binding var messageText: String
    let onSend: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            TextField("Nachricht schreiben...", text: $messageText)
                .padding()
                .background(Color.white.opacity(0.1))
                .foregroundColor(.white)
                .cornerRadius(20)
            
            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .font(.title2)
                    .foregroundColor(messageText.isEmpty ? .gray : .orange)
            }
            .disabled(messageText.isEmpty)
        }
        .padding()
        .background(Color.black)
    }
}

// Custom Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

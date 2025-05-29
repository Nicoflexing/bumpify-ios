import SwiftUI

struct MessagesView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedSegment = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Nachrichten")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {}) {
                            ZStack {
                                Image(systemName: "person.2.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.orange)
                                
                                // Badge for new matches
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 12, height: 12)
                                    .offset(x: 12, y: -12)
                            }
                        }
                    }
                    .padding()
                    
                    // Segment Control
                    Picker("Messages", selection: $selectedSegment) {
                        Text("Chats").tag(0)
                        Text("Matches").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .padding(.bottom)
                    
                    // Content
                    if selectedSegment == 0 {
                        ChatsListView()
                    } else {
                        MatchesListView()
                    }
                }
            }
        }
        .onAppear {
            loadMockData()
        }
    }
    
    private func loadMockData() {
        if appState.conversations.isEmpty {
            appState.conversations = [
                Conversation(
                    id: "1",
                    user: User(id: "1", name: "Anna", age: 26, interests: ["Musik", "Reisen"], profileImage: "person.circle.fill"),
                    messages: [
                        Message(id: "1", text: "Hey! Coole Begegnung eben 😊", isFromCurrentUser: false, timestamp: Date().addingTimeInterval(-3600)),
                        Message(id: "2", text: "Hi Anna! Ja, war ein interessanter Zufall 🙂", isFromCurrentUser: true, timestamp: Date().addingTimeInterval(-3000))
                    ],
                    lastMessage: Date().addingTimeInterval(-3000)
                ),
                Conversation(
                    id: "2",
                    user: User(id: "2", name: "Max", age: 28, interests: ["Sport", "Fotografie"], profileImage: "person.circle.fill"),
                    messages: [
                        Message(id: "3", text: "Warst du auch im Coffee Shop?", isFromCurrentUser: false, timestamp: Date().addingTimeInterval(-7200))
                    ],
                    lastMessage: Date().addingTimeInterval(-7200)
                )
            ]
        }
        
        if appState.matches.isEmpty {
            appState.matches = [
                Match(
                    id: "1",
                    user: User(id: "3", name: "Lisa", age: 24, interests: ["Kunst", "Café"], profileImage: "person.circle.fill"),
                    matchedAt: Date().addingTimeInterval(-1800),
                    location: "Café Central"
                ),
                Match(
                    id: "2",
                    user: User(id: "4", name: "Tom", age: 30, interests: ["Wandern", "Bücher"], profileImage: "person.circle.fill"),
                    matchedAt: Date().addingTimeInterval(-5400),
                    location: "Stadtpark"
                )
            ]
        }
    }
}

struct ChatsListView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                if appState.conversations.isEmpty {
                    EmptyChatsView()
                } else {
                    ForEach(appState.conversations) { conversation in
                        NavigationLink(destination: ChatDetailView(conversation: conversation)) {
                            ChatRowView(conversation: conversation)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
}

struct ChatRowView: View {
    let conversation: Conversation
    
    var body: some View {
        HStack(spacing: 15) {
            // Profile Image
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: conversation.user.profileImage)
                    .font(.title2)
                    .foregroundColor(.orange)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conversation.user.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(timeAgo(from: conversation.lastMessage))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                if let lastMessage = conversation.messages.last {
                    Text(lastMessage.text)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                // Interests
                HStack {
                    ForEach(conversation.user.interests.prefix(2), id: \.self) { interest in
                        Text(interest)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(10)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct MatchesListView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                if appState.matches.isEmpty {
                    EmptyMatchesView()
                } else {
                    ForEach(appState.matches) { match in
                        MatchCardView(match: match)
                    }
                }
            }
            .padding()
        }
    }
}

struct MatchCardView: View {
    let match: Match
    @State private var showingChat = false
    
    var body: some View {
        VStack(spacing: 15) {
            // Match Header
            HStack {
                Text("Neues Match! 🎉")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                Spacer()
                
                Text(timeAgo(from: match.matchedAt))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // User Info
            HStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: match.user.profileImage)
                        .font(.title)
                        .foregroundColor(.orange)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(match.user.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("\(match.user.age) Jahre")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("📍 \(match.location)")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                Spacer()
            }
            
            // Interests
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(match.user.interests, id: \.self) { interest in
                        Text(interest)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 1)
            }
            
            // Action Buttons
            HStack(spacing: 15) {
                Button("Später") {
                    // Handle later action
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.1))
                .foregroundColor(.gray)
                .cornerRadius(10)
                
                Button("Chat starten") {
                    showingChat = true
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.orange, .red],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
        .sheet(isPresented: $showingChat) {
            ChatDetailView(
                conversation: Conversation(
                    id: match.id,
                    user: match.user,
                    messages: [],
                    lastMessage: Date()
                )
            )
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct EmptyChatsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "message.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .padding()
            
            Text("Noch keine Chats")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Starte den Bump-Modus um neue Leute zu treffen und Gespräche zu beginnen")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct EmptyMatchesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .padding()
            
            Text("Noch keine Matches")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Aktiviere den Bump-Modus und like interessante Profile um Matches zu erhalten")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

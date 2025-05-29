
import SwiftUI

struct MessagesView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var conversations: [BumpifyConversation] = []
    @State private var searchText = ""
    @State private var selectedConversation: BumpifyConversation?
    @State private var showingNewMatch = false
    
    var filteredConversations: [BumpifyConversation] {
        if searchText.isEmpty {
            return conversations.sorted { $0.lastMessageAt > $1.lastMessageAt }
        } else {
            return conversations.filter { conversation in
                guard let currentUserId = authManager.getCurrentUserId(),
                      let otherUser = conversation.otherParticipant(currentUserId: currentUserId) else {
                    return false
                }
                return otherUser.fullName.localizedCaseInsensitiveContains(searchText)
            }.sorted { $0.lastMessageAt > $1.lastMessageAt }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.12, blue: 0.18).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerSection
                    
                    // Search Bar
                    searchSection
                    
                    // Conversations List
                    conversationsSection
                }
            }
        }
        .sheet(item: $selectedConversation) { conversation in
            ChatDetailView(conversation: conversation)
        }
        .sheet(isPresented: $showingNewMatch) {
            NewMatchView()
        }
        .onAppear {
            loadMockConversations()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("💬 Chats")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("\(conversations.count) Unterhaltungen")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Button(action: {
                showingNewMatch = true
            }) {
                Image(systemName: "square.and.pencil")
                    .font(.title2)
                    .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.1))
                    .padding(8)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding()
    }
    
    // MARK: - Search Section
    private var searchSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.6))
            
            TextField("Chats durchsuchen...", text: $searchText)
                .foregroundColor(.white)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    // MARK: - Conversations Section
    private var conversationsSection: some View {
        Group {
            if filteredConversations.isEmpty {
                if conversations.isEmpty {
                    emptyStateView
                } else {
                    noSearchResultsView
                }
            } else {
                conversationsList
            }
        }
    }
    
    private var conversationsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(filteredConversations) { conversation in
                    ConversationRow(
                        conversation: conversation,
                        currentUserId: authManager.getCurrentUserId() ?? UUID()
                    )
                    .onTapGesture {
                        selectedConversation = conversation
                    }
                    
                    if conversation.id != filteredConversations.last?.id {
                        Divider()
                            .background(Color.white.opacity(0.1))
                            .padding(.leading, 80)
                    }
                }
            }
            .padding(.bottom, 100)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "message.circle")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.3))
            
            VStack(spacing: 8) {
                Text("Noch keine Chats")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.7))
                
                Text("Starte den Bump-Modus, um Menschen in deiner Nähe zu finden und neue Unterhaltungen zu beginnen!")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                // Navigate to Bump tab - would need TabView binding
            }) {
                HStack {
                    Image(systemName: "location.circle.fill")
                    Text("Bump-Modus starten")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.4, blue: 0.2),
                            Color(red: 1.0, green: 0.6, blue: 0.0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            
            Spacer()
        }
    }
    
    private var noSearchResultsView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.3))
            
            Text("Keine Ergebnisse für '\(searchText)'")
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
            
            Text("Versuche einen anderen Suchbegriff")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.5))
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Load Mock Data
    private func loadMockConversations() {
        guard let currentUserId = authManager.getCurrentUserId() else { return }
        
        let mockUsers = [
            BumpifyUser(
                firstName: "Anna",
                lastName: "Schmidt",
                email: "anna@test.de",
                age: 25,
                interests: ["Musik", "Reisen"]
            ),
            BumpifyUser(
                firstName: "Max",
                lastName: "Mueller",
                email: "max@test.de",
                age: 28,
                interests: ["Sport", "Kaffee"]
            ),
            BumpifyUser(
                firstName: "Lisa",
                lastName: "Weber",
                email: "lisa@test.de",
                age: 24,
                interests: ["Kunst", "Fotografie"]
            ),
            BumpifyUser(
                firstName: "Tom",
                lastName: "Fischer",
                email: "tom@test.de",
                age: 30,
                interests: ["Gaming", "Technik"]
            ),
            BumpifyUser(
                firstName: "Sarah",
                lastName: "Klein",
                email: "sarah@test.de",
                age: 26,
                interests: ["Yoga", "Kochen"]
            )
        ]
        
        let currentUser = authManager.currentUser ?? BumpifyUser(
            firstName: "Du",
            lastName: "",
            email: "you@test.de"
        )
        
        conversations = [
            BumpifyConversation(
                participants: [currentUser, mockUsers[0]],
                messages: [
                    BumpifyMessage(
                        text: "Hey! Schön dich kennengelernt zu haben 😊",
                        senderId: mockUsers[0].id
                    ),
                    BumpifyMessage(
                        text: "Hallo Anna! Ja, das war ein toller Zufall!",
                        senderId: currentUserId
                    ),
                    BumpifyMessage(
                        text: "Hast du Lust auf einen Kaffee morgen?",
                        senderId: mockUsers[0].id,
                        timestamp: Date().addingTimeInterval(-300)
                    )
                ],
                lastMessageAt: Date().addingTimeInterval(-300)
            ),
            BumpifyConversation(
                participants: [currentUser, mockUsers[1]],
                messages: [
                    BumpifyMessage(
                        text: "Hi! Cooles Café hier",
                        senderId: currentUserId,
                        timestamp: Date().addingTimeInterval(-7200)
                    ),
                    BumpifyMessage(
                        text: "Stimmt! Kommst du öfter her?",
                        senderId: mockUsers[1].id,
                        timestamp: Date().addingTimeInterval(-7000)
                    ),
                    BumpifyMessage(
                        text: "Ja, arbeite ganz in der Nähe. Vielleicht sieht man sich mal wieder!",
                        senderId: currentUserId,
                        timestamp: Date().addingTimeInterval(-6800)
                    )
                ],
                lastMessageAt: Date().addingTimeInterval(-6800)
            ),
            BumpifyConversation(
                participants: [currentUser, mockUsers[2]],
                messages: [
                    BumpifyMessage(
                        text: "Danke für den Tipp mit der Ausstellung!",
                        senderId: currentUserId,
                        timestamp: Date().addingTimeInterval(-86400)
                    ),
                    BumpifyMessage(
                        text: "Gerne! War sie gut?",
                        senderId: mockUsers[2].id,
                        timestamp: Date().addingTimeInterval(-86000)
                    )
                ],
                lastMessageAt: Date().addingTimeInterval(-86000)
            ),
            BumpifyConversation(
                participants: [currentUser, mockUsers[3]],
                messages: [
                    BumpifyMessage(
                        text: "Coole Gaming-Session gestern! 🎮",
                        senderId: mockUsers[3].id,
                        timestamp: Date().addingTimeInterval(-172800)
                    ),
                    BumpifyMessage(
                        text: "Auf jeden Fall! Müssen wir wiederholen",
                        senderId: currentUserId,
                        timestamp: Date().addingTimeInterval(-172600)
                    )
                ],
                lastMessageAt: Date().addingTimeInterval(-172600)
            ),
            BumpifyConversation(
                participants: [currentUser, mockUsers[4]],
                messages: [
                    BumpifyMessage(
                        text: "Das Yoga-Studio war super! Danke für den Tipp 🧘‍♀️",
                        senderId: currentUserId,
                        timestamp: Date().addingTimeInterval(-259200)
                    )
                ],
                lastMessageAt: Date().addingTimeInterval(-259200)
            )
        ]
    }
}

// MARK: - Conversation Row
struct ConversationRow: View {
    let conversation: BumpifyConversation
    let currentUserId: UUID
    
    private var otherUser: BumpifyUser? {
        conversation.otherParticipant(currentUserId: currentUserId)
    }
    
    private var hasUnreadMessages: Bool {
        conversation.messages.contains { !$0.isRead && $0.senderId != currentUserId }
    }
    
    private var isOnline: Bool {
        // Mock online status
        [true, false, true, false, true].randomElement() ?? false
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Profile Image
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.4, blue: 0.2).opacity(0.3),
                                Color(red: 1.0, green: 0.6, blue: 0.0).opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                if let user = otherUser {
                    if let profileImage = user.profileImage {
                        // TODO: Load actual image
                        Image(systemName: "person.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.8))
                    } else {
                        Text(user.firstName.prefix(1) + user.lastName.prefix(1))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                // Online indicator
                if isOnline {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Circle()
                                .stroke(Color(red: 0.1, green: 0.12, blue: 0.18), lineWidth: 2)
                        )
                        .offset(x: 20, y: 20)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(otherUser?.fullName ?? "Unbekannt")
                        .font(.headline)
                        .fontWeight(hasUnreadMessages ? .bold : .medium)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(timeAgoString(from: conversation.lastMessageAt))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                HStack {
                    if let lastMessage = conversation.lastMessage {
                        HStack(spacing: 4) {
                            // Message indicator
                            if lastMessage.senderId == currentUserId {
                                Image(systemName: lastMessage.isRead ? "checkmark.circle.fill" : "checkmark.circle")
                                    .font(.caption)
                                    .foregroundColor(lastMessage.isRead ? .green : .white.opacity(0.6))
                            }
                            
                            Text(lastMessage.text)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(hasUnreadMessages ? 0.9 : 0.7))
                                .lineLimit(2)
                                .fontWeight(hasUnreadMessages ? .medium : .regular)
                        }
                    } else {
                        Text("Neue Unterhaltung")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .italic()
                    }
                    
                    Spacer()
                    
                    if hasUnreadMessages {
                        Circle()
                            .fill(Color(red: 1.0, green: 0.5, blue: 0.1))
                            .frame(width: 8, height: 8)
                    }
                }
                
                // Shared interests or location
                if let user = otherUser, !user.interests.isEmpty {
                    HStack {
                        Image(systemName: "heart.fill")
                            .font(.caption2)
                            .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.1))
                        
                        Text("Gemeinsame Interessen: \(user.interests.prefix(2).joined(separator: ", "))")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                            .lineLimit(1)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(Color.clear)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - New Match View (Placeholder)
struct NewMatchView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.12, blue: 0.18).ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.pink)
                    
                    Text("💕 Neue Matches")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Hier siehst du bald deine neuen Matches und kannst Unterhaltungen starten!")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Spacer()
                }
                .padding(.top, 60)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.1))
                }
            }
        }
    }
}

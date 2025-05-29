// MessagesView.swift - Korrigierte Version ohne Fehler

import SwiftUI

struct MessagesView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var conversations: [BumpifyConversation] = []
    @State private var newMatches: [NewMatch] = [] // Eigene Match-Struktur
    @State private var searchText = ""
    @State private var showingNewMatches = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with Welcome Message (similar to HomeView)
                        headerView
                        
                        // Chat Stats (similar to HomeView quick stats)
                        chatStatsView
                        
                        // New Matches Section (similar to recent bumps)
                        if !newMatches.isEmpty {
                            newMatchesSection
                        }
                        
                        // Search Bar
                        searchBarView
                        
                        // Conversations Section
                        conversationsSection
                        
                        Spacer().frame(height: 100) // Tab bar space
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showingNewMatches) {
            NewMatchesDetailView(matches: newMatches)
        }
        .onAppear {
            loadConversations()
        }
    }
    
    // MARK: - Header View (similar to HomeView)
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("💬 Deine Chats")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Bleib in Kontakt mit deinen Matches")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: { showingNewMatches = true }) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "heart.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    
                    // Notification badge for new matches
                    if !newMatches.isEmpty {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Text("\(newMatches.count)")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                            .offset(x: 15, y: -15)
                    }
                }
            }
        }
    }
    
    // MARK: - Chat Stats (using existing StatCard from HomeView)
    private var chatStatsView: some View {
        HStack(spacing: 16) {
            ChatStatCard(
                icon: "message.fill",
                title: "Aktive Chats",
                value: "\(conversations.count)",
                color: .orange
            )
            
            ChatStatCard(
                icon: "heart.fill",
                title: "Neue Matches",
                value: "\(newMatches.count)",
                color: .red
            )
            
            ChatStatCard(
                icon: "clock.fill",
                title: "Heute",
                value: "\(conversations.filter { isToday($0.lastMessage?.timestamp ?? Date()) }.count)",
                color: .blue
            )
        }
    }
    
    // MARK: - New Matches Section
    private var newMatchesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("💖 Neue Matches")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Alle anzeigen") {
                    showingNewMatches = true
                }
                .font(.caption)
                .foregroundColor(.orange)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(newMatches.prefix(5)) { match in
                        NewMatchCard(match: match)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.horizontal, -16)
        }
    }
    
    // MARK: - Search Bar
    private var searchBarView: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Chats durchsuchen...", text: $searchText)
                .foregroundColor(.white)
                .autocapitalization(.none)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Conversations Section
    private var conversationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("📱 Deine Unterhaltungen")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            if filteredConversations.isEmpty {
                ChatEmptyStateView(
                    icon: "message.circle",
                    title: searchText.isEmpty ? "Noch keine Chats" : "Keine Ergebnisse",
                    subtitle: searchText.isEmpty ? "Starte einen Bump, um neue Leute kennenzulernen!" : "Versuche einen anderen Suchbegriff"
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(filteredConversations) { conversation in
                        NavigationLink(destination: SimpleChatDetailView(conversation: conversation)) {
                            StylishConversationRow(conversation: conversation)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var filteredConversations: [BumpifyConversation] {
        if searchText.isEmpty {
            return conversations
        }
        return conversations.filter { conversation in
            conversation.messages.contains { message in
                message.text.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // MARK: - Helper Functions
    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
    
    private func loadConversations() {
        // Mock-Daten für Demo
        conversations = [
            BumpifyConversation(
                participants: [authManager.currentUser?.id ?? "", "user2"],
                messages: [
                    BumpifyMessage(
                        text: "Hey! War schön, dich heute im Café zu treffen! ☕️",
                        senderId: "user2",
                        receiverId: authManager.currentUser?.id ?? ""
                    ),
                    BumpifyMessage(
                        text: "Hi Anna! Freut mich auch! Das war ein netter Zufall 😊",
                        senderId: authManager.currentUser?.id ?? "",
                        receiverId: "user2"
                    )
                ]
            ),
            BumpifyConversation(
                participants: [authManager.currentUser?.id ?? "", "user3"],
                messages: [
                    BumpifyMessage(
                        text: "Cool, dass wir uns beim Joggen getroffen haben! 🏃‍♂️",
                        senderId: "user3",
                        receiverId: authManager.currentUser?.id ?? ""
                    )
                ]
            )
        ]
        
        // Mock neue Matches
        newMatches = [
            NewMatch(
                id: "match1",
                userName: "Lisa Weber",
                userInitials: "LW",
                location: "Stadtbibliothek",
                timestamp: Date().addingTimeInterval(-1800)
            ),
            NewMatch(
                id: "match2",
                userName: "Tom Fischer",
                userInitials: "TF",
                location: "Fitnessstudio",
                timestamp: Date().addingTimeInterval(-3600)
            )
        ]
    }
}

// MARK: - Custom Components (eigene Implementierung)

// Stat Card für Chats (basiert auf deiner StatCard)
struct ChatStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

// Stylish Conversation Row
struct StylishConversationRow: View {
    let conversation: BumpifyConversation
    
    var body: some View {
        HStack(spacing: 16) {
            // Profile Image mit Gradient
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Text(getInitials())
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Online indicator
                Circle()
                    .fill(Color.green)
                    .frame(width: 16, height: 16)
                    .overlay(
                        Circle()
                            .stroke(Color.black, lineWidth: 2)
                    )
                    .offset(x: 20, y: 20)
            }
            
            // Message Content
            VStack(alignment: .leading, spacing: 6) {
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
                    HStack {
                        Text(lastMessage.text)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        // Unread indicator
                        if hasUnreadMessages() {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 10, height: 10)
                        }
                    }
                } else {
                    Text("Neue Unterhaltung starten...")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .italic()
                }
                
                // Bump location context
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption2)
                        .foregroundColor(.orange)
                    
                    Text("Begegnung heute")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(hasUnreadMessages() ? Color.orange.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
    
    private func getInitials() -> String {
        let names = ["AS", "MW", "LK", "TF", "SK"]
        return names.randomElement() ?? "U"
    }
    
    private func getOtherUserName() -> String {
        let names = ["Anna Schmidt", "Max Weber", "Lisa Klein", "Tom Fischer", "Sarah Klein"]
        return names.randomElement() ?? "Chat Partner"
    }
    
    private func getLastMessageTime() -> String {
        guard let lastMessage = conversation.lastMessage else { return "" }
        
        let formatter = DateFormatter()
        let now = Date()
        let calendar = Calendar.current
        
        if calendar.isDate(lastMessage.timestamp, inSameDayAs: now) {
            formatter.timeStyle = .short
            return formatter.string(from: lastMessage.timestamp)
        }
        
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now) ?? now
        if calendar.isDate(lastMessage.timestamp, inSameDayAs: yesterday) {
            return "Gestern"
        }
        
        formatter.dateStyle = .short
        return formatter.string(from: lastMessage.timestamp)
    }
    
    private func hasUnreadMessages() -> Bool {
        return conversation.messages.count.isMultiple(of: 2)
    }
}

// New Match Model (eigene einfache Struktur)
struct NewMatch: Identifiable {
    let id: String
    let userName: String
    let userInitials: String
    let location: String
    let timestamp: Date
}

// New Match Card
struct NewMatchCard: View {
    let match: NewMatch
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Text(match.userInitials)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // New match indicator
                Circle()
                    .fill(Color.green)
                    .frame(width: 18, height: 18)
                    .overlay(
                        Image(systemName: "heart.fill")
                            .font(.caption2)
                            .foregroundColor(.white)
                    )
                    .offset(x: 20, y: -20)
            }
            
            VStack(spacing: 4) {
                Text(match.userName.split(separator: " ").first?.description ?? "")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(match.location)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Button("Chat") {
                // Start chat action
            }
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(Color.orange)
            .cornerRadius(12)
        }
        .frame(width: 100)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

// Chat Empty State View (basiert auf deiner EmptyStateView)
struct ChatEmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

// Simple Chat Detail View (ohne komplexe Parameter)
struct SimpleChatDetailView: View {
    let conversation: BumpifyConversation
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                Text("Chat Detail")
                    .font(.title)
                    .foregroundColor(.white)
                
                Text("Nachrichten: \(conversation.messages.count)")
                    .foregroundColor(.orange)
                
                Text("Hier würde der Chat erscheinen")
                    .foregroundColor(.gray)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Chat")
    }
}

// New Matches Detail View
struct NewMatchesDetailView: View {
    let matches: [NewMatch]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button("Schließen") {
                            dismiss()
                        }
                        .foregroundColor(.orange)
                        
                        Spacer()
                        
                        Text("💖 Neue Matches")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button("Fertig") {
                            dismiss()
                        }
                        .font(.caption)
                        .foregroundColor(.orange)
                    }
                    .padding()
                    
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(matches) { match in
                                ExpandedMatchCard(match: match)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
    }
}

// Expanded Match Card
struct ExpandedMatchCard: View {
    let match: NewMatch
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Text(match.userInitials)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(match.userName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        Text(match.location)
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                    
                    Text(timeAgo(from: match.timestamp))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: {}) {
                    HStack {
                        Image(systemName: "xmark")
                        Text("Später")
                    }
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                }
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "message.fill")
                        Text("Chat starten")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
    
    private func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        
        if interval < 3600 {
            let minutes = Int(interval / 60)
            return "vor \(minutes) Min."
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "vor \(hours) Std."
        } else {
            let days = Int(interval / 86400)
            return "vor \(days) Tag(en)"
        }
    }
}

#Preview {
    MessagesView()
        .environmentObject(AuthenticationManager())
}

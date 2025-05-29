// MessagesView.swift - Angepasst an Home/Bump Design

import SwiftUI

struct MessagesView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var conversations: [BumpifyConversation] = []
    @State private var newMatches: [NewMatch] = []
    @State private var searchText = ""
    @State private var showingNewMatches = false
    @State private var animateStats = false
    @State private var showingNotificationBanner = false
    @State private var isRefreshing = false
    
    var body: some View {
        ZStack {
            // Background - Matching Home/Bump Design
            backgroundGradient
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Pull-to-Refresh Indicator
                    if isRefreshing {
                        refreshIndicator
                    }
                    
                    // Header - Matching Home/Bump style
                    headerSection
                    
                    // Stats Cards - Matching Home/Bump
                    statsSection
                    
                    // New Matches Section
                    if !newMatches.isEmpty {
                        newMatchesSection
                    }
                    
                    // Search Bar with glass effect
                    searchBarSection
                    
                    // Conversations Section
                    conversationsSection
                    
                    // Bottom padding for tab bar
                    Spacer().frame(height: 100)
                }
                .padding(.top, 60)
                .padding(.horizontal, 20)
            }
            .refreshable {
                await performRefresh()
            }
            
            // Floating particles - Matching Home/Bump
            floatingParticles
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            loadConversations()
            startAnimations()
        }
        .sheet(isPresented: $showingNewMatches) {
            NewMatchesDetailView(matches: newMatches)
        }
    }
    
    // MARK: - Background - Matching Home/Bump
    private var backgroundGradient: some View {
        ZStack {
            Color(red: 0.12, green: 0.16, blue: 0.24)
                .ignoresSafeArea()
            
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.4, blue: 0.2).opacity(0.1),
                    Color.clear,
                    Color(red: 1.0, green: 0.6, blue: 0.0).opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }
    
    // MARK: - Floating Particles - Matching Home/Bump
    private var floatingParticles: some View {
        ForEach(0..<5, id: \.self) { i in
            Circle()
                .fill(Color.orange.opacity(Double.random(in: 0.05...0.15)))
                .frame(width: CGFloat.random(in: 12...22))
                .offset(
                    x: CGFloat.random(in: -150...150),
                    y: CGFloat.random(in: -300...300) + (animateStats ? -18 : 18)
                )
                .animation(
                    Animation.easeInOut(duration: Double.random(in: 4.5...6.5))
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.3),
                    value: animateStats
                )
        }
    }
    
    // MARK: - Pull-to-Refresh Indicator
    private var refreshIndicator: some View {
        HStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                .scaleEffect(0.8)
            
            Text("Aktualisiere Chats...")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .background(glassBackground)
        .cornerRadius(25)
        .transition(.scale.combined(with: .opacity))
    }
    
    // MARK: - Header Section - Matching Home/Bump
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("💬 Deine Chats")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Bleib in Kontakt mit deinen Matches")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Button(action: {
                showingNewMatches = true
            }) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                    
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.pink)
                    
                    // Notification badge
                    if !newMatches.isEmpty {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Text("\(min(newMatches.count, 9))")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .offset(x: 18, y: -18)
                    }
                }
            }
        }
    }
    
    // MARK: - Stats Section - Matching Home/Bump
    private var statsSection: some View {
        HStack(spacing: 16) {
            ChatStatCard(
                icon: "message.fill",
                title: "Aktive Chats",
                value: "\(conversations.count)",
                color: .orange,
                animate: animateStats
            )
            
            ChatStatCard(
                icon: "heart.fill",
                title: "Neue Matches",
                value: "\(newMatches.count)",
                color: .pink,
                animate: animateStats
            )
            
            ChatStatCard(
                icon: "clock.fill",
                title: "Heute",
                value: "\(conversations.filter { isToday($0.lastMessage?.timestamp ?? Date()) }.count)",
                color: .blue,
                animate: animateStats
            )
        }
    }
    
    // MARK: - New Matches Section
    private var newMatchesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("💖 Neue Matches")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Alle anzeigen") {
                    showingNewMatches = true
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.orange)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(newMatches.prefix(5)) { match in
                        NewMatchCard(match: match)
                    }
                }
                .padding(.horizontal, 1)
            }
        }
    }
    
    // MARK: - Search Bar with glass effect
    private var searchBarSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
            
            TextField("Chats durchsuchen...", text: $searchText)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .autocapitalization(.none)
        }
        .padding(16)
        .background(glassBackground)
        .cornerRadius(16)
    }
    
    // MARK: - Conversations Section
    private var conversationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("📱 Deine Unterhaltungen")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            if filteredConversations.isEmpty {
                EmptyStateView(
                    icon: "message.circle",
                    title: searchText.isEmpty ? "Noch keine Chats" : "Keine Ergebnisse",
                    subtitle: searchText.isEmpty ? "Starte einen Bump, um neue Leute kennenzulernen!" : "Versuche einen anderen Suchbegriff"
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(filteredConversations) { conversation in
                        ConversationCard(conversation: conversation)
                    }
                }
            }
        }
    }
    
    // MARK: - Glass Background
    private var glassBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThinMaterial)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
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
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 1.0)) {
            animateStats = true
        }
    }
    
    @MainActor
    private func performRefresh() async {
        isRefreshing = true
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        // Reload data
        loadConversations()
        
        isRefreshing = false
    }
    
    private func loadConversations() {
        // Mock data
        conversations = [
            BumpifyConversation(
                participants: [authManager.currentUser?.id ?? "", "user2"],
                messages: [
                    BumpifyMessage(
                        text: "Hey! War schön, dich heute im Café zu treffen! ☕️",
                        senderId: "user2",
                        receiverId: authManager.currentUser?.id ?? "",
                        timestamp: Date().addingTimeInterval(-1800)
                    ),
                    BumpifyMessage(
                        text: "Hi Anna! Freut mich auch! Das war ein netter Zufall 😊",
                        senderId: authManager.currentUser?.id ?? "",
                        receiverId: "user2",
                        timestamp: Date().addingTimeInterval(-1700)
                    )
                ]
            ),
            BumpifyConversation(
                participants: [authManager.currentUser?.id ?? "", "user3"],
                messages: [
                    BumpifyMessage(
                        text: "Cool, dass wir uns beim Joggen getroffen haben! 🏃‍♂️",
                        senderId: "user3",
                        receiverId: authManager.currentUser?.id ?? "",
                        timestamp: Date().addingTimeInterval(-3600)
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

// MARK: - Chat Stat Card - Matching Home/Bump design
struct ChatStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let animate: Bool
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
            }
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(glassBackground)
        .cornerRadius(16)
        .onAppear {
            if animate {
                withAnimation(
                    Animation.easeInOut(duration: 1.2)
                        .repeatForever(autoreverses: true)
                ) {
                    isAnimating = true
                }
            }
        }
    }
    
    private var glassBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThinMaterial)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}

// MARK: - Conversation Card - Enhanced glass design
struct ConversationCard: View {
    let conversation: BumpifyConversation
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Navigate to chat detail
        }) {
            HStack(spacing: 16) {
                // Avatar with gradient and status
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
                        .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    Text(getInitials())
                        .font(.system(size: 20, weight: .bold))
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
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(getLastMessageTime())
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    if let lastMessage = conversation.lastMessage {
                        HStack {
                            Text(lastMessage.text)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
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
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                            .italic()
                    }
                    
                    // Bump location context
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                        
                        Text("Begegnung heute")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding(16)
            .background(glassBackground)
            .cornerRadius(16)
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0) { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        } perform: {}
    }
    
    private var glassBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThinMaterial)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(isPressed ? 0.08 : 0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(hasUnreadMessages() ? Color.orange.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1)
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

// MARK: - New Match Card - Enhanced design
struct NewMatchCard: View {
    let match: NewMatch
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Handle match tap
        }) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.pink, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .shadow(color: Color.pink.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    Text(match.userInitials)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    // New match indicator
                    Circle()
                        .fill(Color.green)
                        .frame(width: 18, height: 18)
                        .overlay(
                            Image(systemName: "heart.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.white)
                        )
                        .offset(x: 20, y: -20)
                }
                
                VStack(spacing: 4) {
                    Text(match.userName.split(separator: " ").first?.description ?? "")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(match.location)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }
                
                Button("Chat") {
                    // Start chat action
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color.pink)
                .cornerRadius(12)
            }
            .frame(width: 100)
            .padding(16)
            .background(glassBackground)
            .cornerRadius(16)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0) { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        } perform: {}
    }
    
    private var glassBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThinMaterial)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(isPressed ? 0.08 : 0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}

// MARK: - Empty State View - Matching design
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.3))
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(glassBackground)
        .cornerRadius(16)
    }
    
    private var glassBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThinMaterial)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}

// MARK: - New Match Model (if not already defined)
struct NewMatch: Identifiable {
    let id: String
    let userName: String
    let userInitials: String
    let location: String
    let timestamp: Date
}

// MARK: - New Matches Detail View
struct NewMatchesDetailView: View {
    let matches: [NewMatch]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.12, green: 0.16, blue: 0.24)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("💖 Neue Matches")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Du hast \(matches.count) neue Matches!")
                        .foregroundColor(.white.opacity(0.7))
                    
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

#Preview {
    MessagesView()
        .environmentObject(AuthenticationManager())
}

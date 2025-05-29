// HomeView.swift - Korrigierte Version ohne CGSize-Fehler

import SwiftUI

struct InteractiveHomeView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var recentBumps: [RecentBump] = []
    @State private var nearbyHotspots: [HomeHotspot] = []
    @State private var showingProfile = false
    @State private var animateStats = false
    @State private var currentTime = Date()
    
    // MARK: - Interactive Features State
    @State private var isRefreshing = false
    @State private var newNotifications: [BumpNotification] = []
    @State private var showingNotificationBanner = false
    @State private var showingBumpDetail = false
    @State private var selectedBump: RecentBump?
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let notificationTimer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Background
            backgroundGradient
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Pull-to-Refresh Indicator
                    if isRefreshing {
                        refreshIndicator
                    }
                    
                    // Header with live updates
                    headerSection
                    
                    // Live notification banner
                    if showingNotificationBanner && !newNotifications.isEmpty {
                        liveNotificationBanner
                    }
                    
                    // Time and Weather Widget
                    timeWeatherWidget
                    
                    // Animated Stats Cards
                    statsSection
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Recent Bumps
                    recentBumpsSection
                    
                    // Nearby Hotspots
                    nearbyHotspotsSection
                    
                    // Bottom padding for tab bar
                    Spacer().frame(height: 100)
                }
                .padding(.top, 60)
                .padding(.horizontal, 20)
            }
            .refreshable {
                await performRefresh()
            }
            
            // Floating elements
            floatingElements
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            loadHomeData()
            startAnimations()
            simulateNewBumps()
        }
        .onReceive(timer) { input in
            currentTime = input
        }
        .onReceive(notificationTimer) { _ in
            simulateNewNotification()
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView()
        }
        .sheet(item: $selectedBump) { bump in
            BumpDetailView(bump: bump)
        }
    }
    
    // MARK: - Background
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
            
            floatingParticles
        }
    }
    
    // MARK: - Floating Particles
    private var floatingParticles: some View {
        ForEach(0..<6, id: \.self) { i in
            Circle()
                .fill(Color.orange.opacity(Double.random(in: 0.05...0.15)))
                .frame(width: CGFloat.random(in: 15...25))
                .offset(
                    x: CGFloat.random(in: -150...150),
                    y: CGFloat.random(in: -300...300) + (animateStats ? -20 : 20)
                )
                .animation(
                    Animation.easeInOut(duration: Double.random(in: 4...6))
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
            
            Text("Aktualisiere...")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .background(glassBackground)
        .cornerRadius(25)
        .transition(.scale.combined(with: .opacity))
    }
    
    // MARK: - Live Notification Banner
    private var liveNotificationBanner: some View {
        VStack(spacing: 0) {
            ForEach(newNotifications.prefix(1)) { notification in
                HStack(spacing: 12) {
                    // Animated pulse indicator
                    ZStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 12, height: 12)
                        
                        Circle()
                            .fill(Color.green.opacity(0.3))
                            .frame(width: 24, height: 24)
                            .scaleEffect(animateStats ? 1.5 : 1.0)
                            .opacity(animateStats ? 0.0 : 1.0)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("🎉 Neuer Bump!")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(notification.message)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            showingNotificationBanner = false
                        }
                        triggerHapticFeedback(.success)
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(8)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                    }
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.green.opacity(0.8), Color.mint.opacity(0.6)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: Color.green.opacity(0.3), radius: 10, x: 0, y: 5)
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
                .onTapGesture {
                    triggerHapticFeedback(.impact(.medium))
                    handleNotificationTap(notification)
                }
            }
        }
        .onAppear {
            // Auto-dismiss after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation(.spring()) {
                    showingNotificationBanner = false
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text(getGreeting())
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Text("Hallo \(authManager.currentUser?.firstName ?? "User")! 👋")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 4) {
                    Text("Bereit für neue Begegnungen?")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    // Live activity indicator
                    if animateStats {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                            .scaleEffect(animateStats ? 1.2 : 0.8)
                            .animation(
                                Animation.easeInOut(duration: 1.0)
                                    .repeatForever(autoreverses: true),
                                value: animateStats
                            )
                    }
                }
            }
            
            Spacer()
            
            // Profile button with notification badge
            Button(action: {
                triggerHapticFeedback(.impact(.light))
                showingProfile = true
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.orange, Color.red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    Text(authManager.currentUser?.initials ?? "U")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Notification badge
                    if newNotifications.count > 1 {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Text("\(min(newNotifications.count, 9))")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .offset(x: 18, y: -18)
                    }
                }
            }
        }
    }
    
    // MARK: - Time & Weather Widget
    private var timeWeatherWidget: some View {
        Button(action: {
            triggerHapticFeedback(.impact(.light))
        }) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(currentTime, style: .time)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(currentTime, style: .date)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.yellow)
                        .rotationEffect(.degrees(animateStats ? 10 : -10))
                        .animation(
                            Animation.easeInOut(duration: 3.0)
                                .repeatForever(autoreverses: true),
                            value: animateStats
                        )
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("22°C")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Sonnig")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .padding(20)
            .background(glassBackground)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        HStack(spacing: 16) {
            InteractiveStatCard(
                icon: "heart.fill",
                title: "Matches",
                value: "12",
                color: .pink,
                delay: 0.0,
                animate: animateStats
            ) {
                triggerHapticFeedback(.impact(.medium))
            }
            
            InteractiveStatCard(
                icon: "location.fill",
                title: "Bumps heute",
                value: "\(recentBumps.count)",
                color: .orange,
                delay: 0.2,
                animate: animateStats
            ) {
                triggerHapticFeedback(.impact(.medium))
            }
            
            InteractiveStatCard(
                icon: "person.2.fill",
                title: "In der Nähe",
                value: "8",
                color: .blue,
                delay: 0.4,
                animate: animateStats
            ) {
                triggerHapticFeedback(.impact(.medium))
            }
        }
    }
    
    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("⚡ Schnellaktionen")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                EnhancedQuickActionCard(
                    icon: "location.circle.fill",
                    title: "Bump starten",
                    subtitle: "Jetzt aktiv werden",
                    gradient: [Color.orange, Color.red],
                    hapticType: .impact(.heavy)
                ) {
                    // Start bump mode
                }
                
                EnhancedQuickActionCard(
                    icon: "plus.circle.fill",
                    title: "Hotspot erstellen",
                    subtitle: "Event planen",
                    gradient: [Color.green, Color.mint],
                    hapticType: .impact(.medium)
                ) {
                    // Create hotspot
                }
            }
            
            HStack(spacing: 12) {
                EnhancedQuickActionCard(
                    icon: "map.fill",
                    title: "Karte öffnen",
                    subtitle: "Umgebung erkunden",
                    gradient: [Color.blue, Color.cyan],
                    hapticType: .impact(.light)
                ) {
                    // Open map
                }
                
                EnhancedQuickActionCard(
                    icon: "message.fill",
                    title: "Neue Chats",
                    subtitle: "\(newNotifications.count) ungelesen",
                    gradient: [Color.purple, Color.pink],
                    hapticType: .impact(.light)
                ) {
                    // Open messages
                }
            }
        }
    }
    
    // MARK: - Recent Bumps Section (Vereinfacht)
    private var recentBumpsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("📍 Letzte Begegnungen")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Alle anzeigen") {
                    triggerHapticFeedback(.impact(.light))
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.orange)
            }
            
            if recentBumps.isEmpty {
                EmptyStatePlaceholder(
                    icon: "location.slash",
                    title: "Keine Begegnungen",
                    subtitle: "Starte einen Bump, um neue Leute zu treffen!"
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(recentBumps) { bump in
                        SimpleBumpCard(bump: bump) {
                            selectedBump = bump
                            showingBumpDetail = true
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Nearby Hotspots
    private var nearbyHotspotsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🔥 Hotspots in der Nähe")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Karte öffnen") {
                    triggerHapticFeedback(.impact(.light))
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.orange)
            }
            
            if nearbyHotspots.isEmpty {
                EmptyStatePlaceholder(
                    icon: "map",
                    title: "Keine Hotspots",
                    subtitle: "Erstelle den ersten Hotspot in deiner Nähe!"
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(nearbyHotspots) { hotspot in
                            TappableHotspotCard(hotspot: hotspot) {
                                triggerHapticFeedback(.impact(.medium))
                            }
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
        }
    }
    
    // MARK: - Floating Elements
    private var floatingElements: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Button(action: {
                    triggerHapticFeedback(.impact(.heavy))
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange, Color.red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                            .shadow(color: Color.orange.opacity(0.4), radius: 15, x: 0, y: 8)
                        
                        Image(systemName: "location.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
                }
                .scaleEffect(animateStats ? 1.1 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true),
                    value: animateStats
                )
            }
            .padding(.trailing, 20)
            .padding(.bottom, 120)
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
    
    // MARK: - Helper Functions
    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Guten Morgen"
        case 12..<17: return "Guten Tag"
        case 17..<22: return "Guten Abend"
        default: return "Gute Nacht"
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 1.0)) {
            animateStats = true
        }
    }
    
    @MainActor
    private func performRefresh() async {
        isRefreshing = true
        triggerHapticFeedback(.impact(.medium))
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        // Reload data
        loadHomeData()
        
        isRefreshing = false
        triggerHapticFeedback(.success)
    }
    
    private func simulateNewNotification() {
        let messages = [
            "Lisa ist in deiner Nähe! 📍",
            "Max möchte dich kennenlernen 👋",
            "Anna hat dich geliked! 💖",
            "Neues Event in der Nähe: Happy Hour 🍹"
        ]
        
        if Bool.random() && newNotifications.count < 3 {
            let notification = BumpNotification(
                id: UUID().uuidString,
                message: messages.randomElement() ?? "Neue Aktivität!",
                timestamp: Date(),
                type: .newBump
            )
            
            newNotifications.append(notification)
            
            withAnimation(.spring()) {
                showingNotificationBanner = true
            }
            
            triggerHapticFeedback(.success)
        }
    }
    
    private func simulateNewBumps() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            simulateNewNotification()
        }
    }
    
    private func handleNotificationTap(_ notification: BumpNotification) {
        print("Notification tapped: \(notification.message)")
    }
    
    private func triggerHapticFeedback(_ type: HapticFeedbackType) {
        switch type {
        case .success:
            let impactFeedback = UINotificationFeedbackGenerator()
            impactFeedback.notificationOccurred(.success)
        case .impact(let intensity):
            let impactFeedback = UIImpactFeedbackGenerator(style: intensity)
            impactFeedback.impactOccurred()
        case .selection:
            let selectionFeedback = UISelectionFeedbackGenerator()
            selectionFeedback.selectionChanged()
        }
    }
    
    private func loadHomeData() {
        // Mock data
        recentBumps = [
            RecentBump(
                id: "1",
                userName: "Anna Schmidt",
                userInitials: "AS",
                location: "Café Central",
                timestamp: Date().addingTimeInterval(-3600),
                isMatched: true,
                avatar: "person.circle.fill"
            ),
            RecentBump(
                id: "2",
                userName: "Max Weber",
                userInitials: "MW",
                location: "Stadtpark",
                timestamp: Date().addingTimeInterval(-7200),
                isMatched: false,
                avatar: "person.circle.fill"
            ),
            RecentBump(
                id: "3",
                userName: "Lisa Klein",
                userInitials: "LK",
                location: "Universitätsbibliothek",
                timestamp: Date().addingTimeInterval(-1800),
                isMatched: false,
                avatar: "person.circle.fill"
            )
        ]
        
        nearbyHotspots = [
            HomeHotspot(
                id: "1",
                name: "After Work Drinks",
                description: "Entspannte Runde nach der Arbeit",
                location: "Murphy's Pub",
                type: .user,
                participantCount: 5,
                maxParticipants: 8,
                startTime: Date().addingTimeInterval(3600),
                endTime: Date().addingTimeInterval(7200)
            ),
            HomeHotspot(
                id: "2",
                name: "Happy Hour",
                description: "20% auf alle Getränke",
                location: "Café Central",
                type: .business,
                participantCount: 12,
                maxParticipants: nil,
                startTime: Date(),
                endTime: Date().addingTimeInterval(7200)
            )
        ]
    }
}

// MARK: - Interactive Components

struct InteractiveStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let delay: Double
    let animate: Bool
    let action: () -> Void
    
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.0
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(color)
                }
                
                Text(value)
                    .font(.system(size: 24, weight: .bold))
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
            .scaleEffect(isPressed ? 0.95 : (scale * (animate ? 1.0 : 0.8)))
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .spring(response: 0.6, dampingFraction: 0.8)
                    .delay(delay)
                ) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
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

struct EnhancedQuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let gradient: [Color]
    let hapticType: HapticFeedbackType
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            triggerHapticFeedback(hapticType)
            action()
        }) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
            }
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
    
    private func triggerHapticFeedback(_ type: HapticFeedbackType) {
        switch type {
        case .success:
            let impactFeedback = UINotificationFeedbackGenerator()
            impactFeedback.notificationOccurred(.success)
        case .impact(let intensity):
            let impactFeedback = UIImpactFeedbackGenerator(style: intensity)
            impactFeedback.impactOccurred()
        case .selection:
            let selectionFeedback = UISelectionFeedbackGenerator()
            selectionFeedback.selectionChanged()
        }
    }
}

// MARK: - Vereinfachte Bump Card (ohne CGSize)
struct SimpleBumpCard: View {
    let bump: RecentBump
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Avatar with status indicator
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: bump.isMatched ? [.green, .mint] : [.orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Text(bump.userInitials)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Status indicator
                    Circle()
                        .fill(bump.isMatched ? Color.green : Color.orange)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .offset(x: 18, y: -18)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(bump.userName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                        
                        Text(bump.location)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(timeAgo(from: bump.timestamp))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                    
                    if bump.isMatched {
                        Text("Match! 💖")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.green)
                    } else {
                        Text("Warten...")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding(16)
            .background(glassBackground)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
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
    
    private func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        
        if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d"
        }
    }
}

struct TappableHotspotCard: View {
    let hotspot: HomeHotspot
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(hotspot.type.color.opacity(0.2))
                            .frame(width: 30, height: 30)
                        
                        Image(systemName: hotspot.type.icon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(hotspot.type.color)
                    }
                    
                    Spacer()
                    
                    Text("\(hotspot.participantCount)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(hotspot.type.color.opacity(0.3))
                        .cornerRadius(10)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(hotspot.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(hotspot.location)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                    
                    Text(hotspot.description)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(2)
                }
                
                Spacer()
                
                Text("Beitreten")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(hotspot.type.color)
                    .cornerRadius(8)
            }
            .frame(width: 140, height: 140)
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

// MARK: - Bump Detail View
struct BumpDetailView: View {
    let bump: RecentBump
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.12, green: 0.16, blue: 0.24)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Bump Details")
                        .font(.title)
                        .foregroundColor(.white)
                    
                    Text(bump.userName)
                        .font(.title2)
                        .foregroundColor(.orange)
                    
                    Text(bump.location)
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

// MARK: - Empty State
struct EmptyStatePlaceholder: View {
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

// MARK: - Data Models

struct BumpNotification: Identifiable {
    let id: String
    let message: String
    let timestamp: Date
    let type: NotificationType
    
    enum NotificationType {
        case newBump, match, message, event
    }
}

enum HapticFeedbackType {
    case success
    case impact(UIImpactFeedbackGenerator.FeedbackStyle)
    case selection
}

struct RecentBump: Identifiable {
    let id: String
    let userName: String
    let userInitials: String
    let location: String
    let timestamp: Date
    let isMatched: Bool
    let avatar: String
}

struct HomeHotspot: Identifiable {
    let id: String
    let name: String
    let description: String
    let location: String
    let type: HomeHotspotType
    let participantCount: Int
    let maxParticipants: Int?
    let startTime: Date
    let endTime: Date
}

enum HomeHotspotType {
    case user, business
    
    var color: Color {
        switch self {
        case .user: return .orange
        case .business: return .green
        }
    }
    
    var icon: String {
        switch self {
        case .user: return "person.2.fill"
        case .business: return "building.2.fill"
        }
    }
}

#Preview {
    InteractiveHomeView()
        .environmentObject(AuthenticationManager())
}

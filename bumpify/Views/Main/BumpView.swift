// BumpView.swift - Korrigierte Version ohne Fehler
// Ersetzt die bestehende BumpView.swift komplett

import SwiftUI

struct BumpView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var bleManager = BumpifyBLEManager()
    
    @State private var isBumping = false
    @State private var activeTime = 0
    @State private var timer: Timer?
    @State private var pulseScale: Double = 1.0
    @State private var rotationAngle: Double = 0
    @State private var showSettings = false
    @State private var animateStats = false
    @State private var nearbyCount = 0
    
    // ✅ MATCH-INTEGRATION - KORRIGIERT
    @State private var showingMatchView = false
    @State private var matchedUser: BumpifyUser?
    @State private var matchLocation = ""
    
    var body: some View {
        ZStack {
            // Background - Matching HomeView
            backgroundGradient
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header - Matching HomeView style
                    headerSection
                    
                    // 🧪 TEST SEKTION - Zum einfachen Testen
                    testSection
                    
                    // Bluetooth Status Card
                    bluetoothStatusSection
                    
                    // Status Cards - Matching HomeView stats
                    statusCardsSection
                    
                    // Main Bump Visualization
                    mainBumpSection
                    
                    // Control Buttons
                    controlSection
                    
                    // Quick Settings
                    quickSettingsSection
                    
                    // Nearby Users
                    if !bleManager.nearbyUsers.isEmpty {
                        nearbyUsersSection
                    }
                    
                    // Bottom padding for tab bar
                    Spacer().frame(height: 100)
                }
                .padding(.top, 60)
                .padding(.horizontal, 20)
            }
            
            // Floating particles - Matching HomeView
            floatingParticles
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            startAnimations()
        }
        .onDisappear {
            stopAllTimers()
        }
        .sheet(isPresented: $showSettings) {
            BumpSettingsView()
        }
        // ✅ KORRIGIERTE MATCH VIEW PRESENTATION
        .fullScreenCover(isPresented: $showingMatchView) {
            if let currentUser = authManager.currentUser,
               let matchedUser = matchedUser {
                BumpMatchView(
                    user1: currentUser,
                    user2: matchedUser,
                    matchLocation: matchLocation
                )
                .environmentObject(authManager) // ✅ WICHTIG: EnvironmentObject weitergeben
            }
        }
        .onChange(of: bleManager.nearbyUsers) { _, newUsers in
            nearbyCount = newUsers.count
        }
        // ✅ AUTOMATISCHE MATCH-ERKENNUNG
        .onReceive(NotificationCenter.default.publisher(for: .bumpDetected)) { notification in
            if let bumpEvent = notification.object as? BumpEvent {
                handlePotentialMatch(bumpEvent)
            }
        }
    }
    
    // ✅ NEUE TEST SEKTION
    private var testSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🧪 Test-Bereich")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Test Match Button
                    TestButton(
                        icon: "heart.fill",
                        title: "Test Match",
                        subtitle: "Match Animation",
                        color: .pink
                    ) {
                        triggerTestMatch()
                    }
                    
                    // Test Bump Button
                    TestButton(
                        icon: "location.circle.fill",
                        title: "Test Bump",
                        subtitle: "Neue Begegnung",
                        color: .orange
                    ) {
                        triggerTestBump()
                    }
                    
                    // Random Match Button
                    TestButton(
                        icon: "shuffle",
                        title: "Zufalls-Match",
                        subtitle: "Random User",
                        color: .purple
                    ) {
                        triggerRandomMatch()
                    }
                }
                .padding(.horizontal, 1)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.yellow.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Background - Matching HomeView
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
    
    // MARK: - Floating Particles - Matching HomeView
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
    
    // MARK: - Header Section - Matching HomeView
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("⚡ Bump Modus")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text(getStatusText())
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Button(action: {
                showSettings = true
            }) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                    
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    // MARK: - Bluetooth Status Section
    private var bluetoothStatusSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("📡 Bluetooth Status")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                // Bluetooth Ready Status
                StatusIndicator(
                    icon: bleManager.bluetoothReady ? "checkmark.circle.fill" : "xmark.circle.fill",
                    title: "Bluetooth",
                    status: bleManager.bluetoothReady ? "Bereit" : "Nicht bereit",
                    color: bleManager.bluetoothReady ? .green : .red
                )
                
                // Scanning Status
                StatusIndicator(
                    icon: bleManager.isScanning ? "magnifyingglass.circle.fill" : "magnifyingglass.circle",
                    title: "Scanning",
                    status: bleManager.isScanning ? "Aktiv" : "Inaktiv",
                    color: bleManager.isScanning ? .blue : .gray
                )
                
                // Advertising Status
                StatusIndicator(
                    icon: bleManager.isAdvertising ? "antenna.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right.slash",
                    title: "Sichtbar",
                    status: bleManager.isAdvertising ? "Ja" : "Nein",
                    color: bleManager.isAdvertising ? .orange : .gray
                )
            }
        }
        .padding(20)
        .background(glassBackground)
        .cornerRadius(16)
    }
    
    // MARK: - Status Cards - Matching HomeView design
    private var statusCardsSection: some View {
        HStack(spacing: 16) {
            StatusCard(
                icon: isBumping ? "circle.fill" : "circle",
                title: "Status",
                value: isBumping ? "Aktiv" : "Inaktiv",
                color: isBumping ? .green : .gray,
                animate: isBumping
            )
            
            StatusCard(
                icon: "person.2.fill",
                title: "In der Nähe",
                value: "\(nearbyCount)",
                color: .orange,
                animate: isBumping
            )
            
            StatusCard(
                icon: "clock.fill",
                title: "Aktive Zeit",
                value: formatTime(activeTime),
                color: .blue,
                animate: isBumping
            )
        }
    }
    
    // MARK: - Main Bump Visualization
    private var mainBumpSection: some View {
        VStack(spacing: 30) {
            ZStack {
                // Outer rings with glass effect
                ForEach(0..<3, id: \.self) { ring in
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: isBumping ?
                                [Color.orange.opacity(0.6), Color.red.opacity(0.4)] :
                                [Color.white.opacity(0.2), Color.white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 200 + CGFloat(ring * 40))
                        .scaleEffect(isBumping ? 1.0 + CGFloat(ring) * 0.1 : 1.0)
                        .opacity(isBumping ? 1.0 - Double(ring) * 0.2 : 0.3)
                        .animation(
                            isBumping ?
                            Animation.easeInOut(duration: 2.0)
                                .repeatForever()
                                .delay(Double(ring) * 0.3) :
                            .default,
                            value: isBumping
                        )
                }
                
                // Center orb with glass effect
                ZStack {
                    // Glow background
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: isBumping ?
                                [Color.orange.opacity(0.4), Color.clear] :
                                [Color.white.opacity(0.1), Color.clear],
                                center: .center,
                                startRadius: 50,
                                endRadius: 100
                            )
                        )
                        .frame(width: 160, height: 160)
                        .blur(radius: 15)
                        .scaleEffect(pulseScale)
                    
                    // Main circle with glass effect
                    Circle()
                        .fill(.ultraThinMaterial)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: isBumping ?
                                        [Color.orange.opacity(0.3), Color.red.opacity(0.2)] :
                                        [Color.white.opacity(0.1), Color.white.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 2)
                        )
                        .frame(width: 120, height: 120)
                    
                    // Content
                    VStack(spacing: 8) {
                        Image(systemName: isBumping ? "wifi.circle" : "location.circle")
                            .font(.system(size: 36, weight: .medium))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(rotationAngle))
                        
                        if isBumping {
                            Text("Suche...")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
            }
            .frame(height: 300)
        }
    }
    
    // MARK: - Control Section
    private var controlSection: some View {
        VStack(spacing: 20) {
            // Main button - Matching HomeView gradient style
            Button(action: toggleBump) {
                HStack(spacing: 16) {
                    Image(systemName: isBumping ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 24, weight: .semibold))
                    
                    Text(isBumping ? "Bump Stoppen" : "Bump Starten")
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: isBumping ?
                                [Color.red, Color.red.opacity(0.8)] :
                                [Color.orange, Color.red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color.orange.opacity(0.3), radius: 15, x: 0, y: 8)
                )
            }
            .scaleEffect(isBumping ? 0.98 : 1.0)
            .animation(.spring(response: 0.3), value: isBumping)
        }
    }
    
    // MARK: - Nearby Users Section
    private var nearbyUsersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("👥 Nutzer in der Nähe")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            LazyVStack(spacing: 12) {
                ForEach(bleManager.nearbyUsers) { user in
                    NearbyUserCard(user: user) {
                        // ✅ DIREKT MATCH SIMULIEREN
                        simulateMatchWithNearbyUser(user)
                    }
                }
            }
        }
        .padding(20)
        .background(glassBackground)
        .cornerRadius(16)
    }
    
    // MARK: - Quick Settings - Matching HomeView cards
    private var quickSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("⚙️ Einstellungen")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                QuickSettingCard(
                    icon: "target",
                    title: "Reichweite",
                    subtitle: "10m Radius",
                    color: .blue
                ) {}
                
                QuickSettingCard(
                    icon: "person.2.fill",
                    title: "Filter",
                    subtitle: "Alle Nutzer",
                    color: .purple
                ) {}
            }
            
            HStack(spacing: 12) {
                QuickSettingCard(
                    icon: "bell.fill",
                    title: "Benachrichtigungen",
                    subtitle: "Aktiviert",
                    color: .green
                ) {}
                
                QuickSettingCard(
                    icon: "shield.fill",
                    title: "Privatsphäre",
                    subtitle: "Sicher",
                    color: .orange
                ) {}
            }
        }
    }
    
    // ✅ MARK: - KORRIGIERTE MATCH-FUNKTIONEN
    
    private func triggerTestMatch() {
        guard let currentUser = authManager.currentUser else {
            print("❌ Kein aktueller User verfügbar")
            return
        }
        
        let testUser = BumpifyUser(
            firstName: "Anna",
            lastName: "Schmidt",
            email: "anna@test.com",
            interests: ["Musik", "Reisen", "Fotografie"],
            age: 24,
            bio: "Liebt es neue Orte zu entdecken und spielt gerne Gitarre",
            location: "München"
        )
        
        presentMatch(with: testUser, at: "Café Central")
    }
    
    private func triggerTestBump() {
        // Simuliere einen normalen Bump ohne Match
        print("🎯 Test Bump ausgelöst!")
        triggerHapticFeedback(.impact(.medium))
        
        // Hier könnte eine Bump-Benachrichtigung gezeigt werden
        // showBumpNotification(...)
    }
    
    private func triggerRandomMatch() {
        guard let currentUser = authManager.currentUser else {
            print("❌ Kein aktueller User verfügbar")
            return
        }
        
        let randomUsers = [
            BumpifyUser(firstName: "Lisa", lastName: "Weber", email: "lisa@test.com", interests: ["Sport", "Kochen"], age: 26, bio: "Fitness-Enthusiastin", location: "Berlin"),
            BumpifyUser(firstName: "Max", lastName: "Fischer", email: "max@test.com", interests: ["Gaming", "Tech"], age: 28, bio: "Software Developer", location: "Hamburg"),
            BumpifyUser(firstName: "Sarah", lastName: "Klein", email: "sarah@test.com", interests: ["Kunst", "Design"], age: 25, bio: "Graphic Designer", location: "Köln"),
            BumpifyUser(firstName: "Tom", lastName: "Meyer", email: "tom@test.com", interests: ["Musik", "Film"], age: 27, bio: "Musician & Filmmaker", location: "Frankfurt")
        ]
        
        let randomUser = randomUsers.randomElement()!
        let randomLocations = ["Stadtpark", "Bibliothek", "Einkaufszentrum", "Restaurant", "Fitnessstudio"]
        let randomLocation = randomLocations.randomElement()!
        
        presentMatch(with: randomUser, at: randomLocation)
    }
    
    private func simulateMatchWithNearbyUser(_ detectedUser: DetectedUser) {
        guard let currentUser = authManager.currentUser else {
            print("❌ Kein aktueller User verfügbar")
            return
        }
        
        // Konvertiere DetectedUser zu BumpifyUser für Match
        let user = BumpifyUser(
            firstName: detectedUser.name,
            lastName: "",
            email: "user@bumpify.com",
            interests: ["Bumpify User"],
            age: 25,
            bio: "Ein echter Bumpify-Nutzer in deiner Nähe!",
            location: "In der Nähe"
        )
        
        presentMatch(with: user, at: "Aktuelle Position")
    }
    
    private func presentMatch(with user: BumpifyUser, at location: String) {
        guard authManager.currentUser != nil else {
            print("❌ Kein aktueller User verfügbar für Match")
            return
        }
        
        triggerHapticFeedback(.success)
        
        matchedUser = user
        matchLocation = location
        
        // Kurze Verzögerung für bessere UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showingMatchView = true
        }
    }
    
    private func handlePotentialMatch(_ bumpEvent: BumpEvent) {
        guard authManager.currentUser != nil else { return }
        
        // ✅ FEHLER BEHOBEN - Korrekte random Syntax
        if Bool.random() && Double.random(in: 0.0...1.0) < 0.3 {
            // Konvertiere BumpEvent zu Match
            let user = BumpifyUser(
                firstName: bumpEvent.detectedUser.name,
                lastName: "",
                email: "bumped@bumpify.com",
                interests: ["Real Bump"],
                age: 25,
                bio: "Echte Begegnung über Bluetooth!",
                location: bumpEvent.location
            )
            
            presentMatch(with: user, at: bumpEvent.location)
        }
    }
    
    // MARK: - Helper Functions
    private func toggleBump() {
        isBumping.toggle()
        
        if isBumping {
            startTimer()
            // BLE Manager starten
            if let userId = authManager.currentUser?.id {
                bleManager.startBumpMode(userID: userId)
                print("🚀 BLE Manager gestartet für User: \(userId)")
            }
        } else {
            stopTimer()
            activeTime = 0
            nearbyCount = 0
            // BLE Manager stoppen
            bleManager.stopBumpMode()
            print("⏹️ BLE Manager gestoppt")
        }
    }
    
    private func startAnimations() {
        withAnimation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            pulseScale = 1.1
            animateStats = true
        }
        
        withAnimation(Animation.linear(duration: 8.0).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if isBumping {
                activeTime += 1
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func stopAllTimers() {
        timer?.invalidate()
        timer = nil
    }
    
    private func getStatusText() -> String {
        if isBumping {
            return "Aktiv seit \(formatTime(activeTime)) • \(nearbyCount) Nutzer gefunden"
        } else {
            return "Bereit zum Starten"
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", minutes, secs)
    }
    
    private func triggerHapticFeedback(_ type: BumpHapticFeedbackType) {
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
}

// ✅ MARK: - NEUE TEST BUTTON KOMPONENTE
struct TestButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            triggerHaptic()
            action()
        }) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(color)
                }
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .frame(width: 80)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(isPressed ? 0.3 : 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.4), lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0) { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        } perform: {}
    }
    
    private func triggerHaptic() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
}

// MARK: - ERWEITERTE NEARBY USER CARD
struct NearbyUserCard: View {
    let user: DetectedUser
    let onTap: (() -> Void)?
    
    init(user: DetectedUser, onTap: (() -> Void)? = nil) {
        self.user = user
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            HStack(spacing: 12) {
                // Avatar
                Circle()
                    .fill(Color.orange)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(user.name.prefix(1))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                
                // User Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("\(String(format: "%.1f", user.distance))m entfernt")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Signal Strength + Match Button
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 2) {
                        ForEach(0..<4) { index in
                            Rectangle()
                                .fill(signalColor(rssi: user.rssi, bar: index))
                                .frame(width: 4, height: CGFloat(6 + index * 2))
                                .cornerRadius(1)
                        }
                    }
                    
                    if onTap != nil {
                        Text("Tap = Match")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.orange.opacity(0.8))
                    }
                    
                    Text("\(user.rssi) dBm")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(onTap != nil ? 0.08 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(onTap == nil)
    }
    
    private func signalColor(rssi: Int, bar: Int) -> Color {
        let strength = min(4, max(0, (rssi + 100) / 10))
        return bar < strength ? .green : .gray.opacity(0.3)
    }
}

// MARK: - Helper Views (definiert hier um Konflikte zu vermeiden)
struct StatusIndicator: View {
    let icon: String
    let title: String
    let status: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(color)
            
            Text(status)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct StatusCard: View {
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
                    Animation.easeInOut(duration: 1.0)
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

struct QuickSettingCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(color)
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
}

struct BumpSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.12, green: 0.16, blue: 0.24)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("⚙️ Bump Einstellungen")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Hier kannst du deine Bump-Einstellungen anpassen")
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
    }
}

// MARK: - Haptic Feedback Type
enum BumpHapticFeedbackType {
    case success
    case impact(UIImpactFeedbackGenerator.FeedbackStyle)
    case selection
}

#Preview {
    BumpView()
        .environmentObject(AuthenticationManager())
}

// BumpView.swift - Angepasste Version mit BumpRequestOverlay
// Ersetze deine BumpView.swift mit diesem Code

import SwiftUI
import CoreLocation

// MARK: - Datenmodelle
struct BumpRequestData: Identifiable {
    let id: String
    let detectedUser: DetectedUser
    let location: String?
    let timestamp: Date
    var status: BumpRequestStatusData
}

enum BumpRequestStatusData {
    case pending
    case accepted
    case declined
    case expired
}

enum BumpHapticFeedbackType {
    case success
    case impact(UIImpactFeedbackGenerator.FeedbackStyle)
    case selection
}

struct BumpView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var bleManager = BumpifyBLEManager()
    @StateObject private var locationManager = BumpLocationManager()
    
    @State private var isBumping = false
    @State private var activeTime = 0
    @State private var timer: Timer?
    @State private var pulseScale: Double = 1.0
    @State private var rotationAngle: Double = 0
    @State private var showSettings = false
    @State private var animateStats = false
    @State private var nearbyCount = 0
    
    // ✅ BUMP REQUEST OVERLAY STATES (GEÄNDERT!)
    @State private var showingBumpRequestOverlay = false
    @State private var currentBumpRequest: BumpRequestData?
    @State private var pendingBumpRequests: [BumpRequestData] = []
    @State private var showingLocationPermission = false
    
    // ✅ MATCH OVERLAY STATES
    @State private var showingMatchOverlay = false
    @State private var matchedUser: BumpifyUser?
    @State private var matchLocation = ""
    
    var body: some View {
        ZStack {
            // Background
            backgroundGradient
            
            // Main Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // 🧪 TEST SEKTION
                    testSection
                    
                    // Bluetooth & Location Status
                    statusSection
                    
                    // Status Cards
                    statusCardsSection
                    
                    // Main Bump Visualization
                    mainBumpSection
                    
                    // ✅ ENTFERNT: Eingebettete Bump Request Sektion
                    // Die wird jetzt als Overlay angezeigt!
                    
                    // Control Buttons
                    controlSection
                    
                    // Pending Requests (nur Info-Anzeige, kein Tap mehr)
                    if !pendingBumpRequests.isEmpty && !showingBumpRequestOverlay {
                        pendingRequestsInfoSection
                    }
                    
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
            
            // Floating particles
            floatingParticles
        }
        // ✅ OVERLAYS HIER - AUSSERHALB DES MAIN ZSTACK
        .overlay(
            Group {
                // ✅ BUMP REQUEST OVERLAY
                if showingBumpRequestOverlay,
                   let request = currentBumpRequest {
                    BumpRequestOverlay(
                        isShowing: $showingBumpRequestOverlay,
                        request: request,
                        onAccept: {
                            acceptBumpRequest()
                        },
                        onDecline: {
                            declineBumpRequest()
                        }
                    )
                    .environmentObject(authManager)
                    .transition(.opacity)
                    .animation(.spring(), value: showingBumpRequestOverlay)
                }
            }
        )
        .overlay(
            Group {
                // ✅ MATCH OVERLAY
                if showingMatchOverlay,
                   let currentUser = authManager.currentUser,
                   let matchedUser = matchedUser {
                    BumpMatchOverlay(
                        isShowing: $showingMatchOverlay,
                        user1: currentUser,
                        user2: matchedUser,
                        matchLocation: matchLocation
                    )
                    .environmentObject(authManager)
                    .transition(.opacity)
                    .animation(.spring(), value: showingMatchOverlay)
                }
            }
        )
        .ignoresSafeArea(edges: .top)
        .onAppear {
            startAnimations()
            requestLocationPermission()
        }
        .onDisappear {
            stopAllTimers()
        }
        .sheet(isPresented: $showSettings) {
            BumpSettingsViewInternal()
        }
        .onChange(of: bleManager.nearbyUsers) { _, newUsers in
            nearbyCount = newUsers.count
        }
        .onReceive(NotificationCenter.default.publisher(for: .bumpDetected)) { notification in
            if let bumpEvent = notification.object as? BumpEvent {
                handleNewBumpDetection(bumpEvent)
            }
        }
        .alert("Standort für Bump-Orte", isPresented: $showingLocationPermission) {
            Button("Erlauben") {
                locationManager.requestLocationPermission()
            }
            Button("Später", role: .cancel) {}
        } message: {
            Text("Bumpify möchte deinen Standort speichern, damit du und deine Matches wissen, wo ihr euch begegnet seid.")
        }
    }
    
    // ✅ NEUE PENDING REQUESTS INFO SEKTION (ohne Tap-Funktionalität)
    private var pendingRequestsInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📋 Wartende Bump-Anfragen (\(pendingBumpRequests.count))")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Text("Du hast \(pendingBumpRequests.count) weitere Bump-Anfrage\(pendingBumpRequests.count == 1 ? "" : "n") in der Warteschlange.")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(pendingBumpRequests) { request in
                        PendingRequestInfoCardInternal(request: request)
                    }
                }
                .padding(.horizontal, 1)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // ✅ STATUS SEKTION
    private var statusSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("📡 System Status")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                SystemStatusCardInternal(
                    icon: bleManager.bluetoothReady ? "checkmark.circle.fill" : "xmark.circle.fill",
                    title: "Bluetooth",
                    status: bleManager.bluetoothReady ? "Bereit" : "Nicht bereit",
                    color: bleManager.bluetoothReady ? .green : .red
                )
                
                SystemStatusCardInternal(
                    icon: locationManager.hasLocationPermission ? "location.circle.fill" : "location.slash.circle.fill",
                    title: "Standort",
                    status: locationManager.hasLocationPermission ? "Erlaubt" : "Nicht erlaubt",
                    color: locationManager.hasLocationPermission ? .green : .orange
                )
                
                SystemStatusCardInternal(
                    icon: bleManager.isScanning ? "magnifyingglass.circle.fill" : "magnifyingglass.circle",
                    title: "Suche",
                    status: bleManager.isScanning ? "Aktiv" : "Inaktiv",
                    color: bleManager.isScanning ? .blue : .gray
                )
            }
        }
        .padding(16)
        .background(glassBackground)
        .cornerRadius(16)
    }
    
    // ✅ BUMP REQUEST FUNCTIONS (ANGEPASST!)
    
    private func handleNewBumpDetection(_ bumpEvent: BumpEvent) {
        print("🎯 Neue Bump-Erkennung: \(bumpEvent.detectedUser.name)")
        
        locationManager.getCurrentLocation { location in
            let locationName = location ?? "Unbekannter Ort"
            
            let request = BumpRequestData(
                id: UUID().uuidString,
                detectedUser: bumpEvent.detectedUser,
                location: locationName,
                timestamp: Date(),
                status: .pending
            )
            
            DispatchQueue.main.async {
                // ✅ GEÄNDERT: Prüfe ob bereits ein Overlay angezeigt wird
                if !showingBumpRequestOverlay && !showingMatchOverlay {
                    // Zeige sofort das Overlay
                    currentBumpRequest = request
                    showingBumpRequestOverlay = true
                    triggerBumpHapticFeedback(.impact(.heavy))
                } else {
                    // Füge zur Warteschlange hinzu
                    pendingBumpRequests.append(request)
                }
            }
        }
    }
    
    private func acceptBumpRequest() {
        guard let request = currentBumpRequest else { return }
        
        print("✅ Bump-Anfrage akzeptiert: \(request.detectedUser.name)")
        triggerBumpHapticFeedback(.success)
        
        var acceptedRequest = request
        acceptedRequest.status = .accepted
        
        // ✅ Simuliere Antwort des anderen Nutzers
        simulateOtherUserResponse(for: acceptedRequest)
        
        // ✅ Schließe das Request Overlay (nicht das gesamte System)
        dismissCurrentRequestOverlay()
    }
    
    private func declineBumpRequest() {
        guard let request = currentBumpRequest else { return }
        
        print("❌ Bump-Anfrage abgelehnt: \(request.detectedUser.name)")
        triggerBumpHapticFeedback(.impact(.light))
        
        // ✅ Schließe das Request Overlay
        dismissCurrentRequestOverlay()
    }
    
    private func simulateOtherUserResponse(for request: BumpRequestData) {
        let responseTime = Double.random(in: 2.0...4.0)
        let willAccept = Bool.random()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + responseTime) {
            if willAccept {
                createMatch(from: request)
            } else {
                showBumpDeclined(for: request)
            }
        }
    }
    
    private func createMatch(from request: BumpRequestData) {
        print("🎉 MATCH erstellt mit \(request.detectedUser.name)!")
        
        let matchUser = BumpifyUser(
            firstName: request.detectedUser.name.components(separatedBy: " ").first ?? request.detectedUser.name,
            lastName: request.detectedUser.name.components(separatedBy: " ").count > 1 ?
                      request.detectedUser.name.components(separatedBy: " ").dropFirst().joined(separator: " ") : "",
            email: "match@bumpify.com",
            interests: ["Bumpify Match", "Begegnungen"],
            age: Int.random(in: 22...35),
            bio: "Ihr habt euch über Bumpify kennengelernt!",
            location: request.location ?? "Unbekannt"
        )
        
        matchedUser = matchUser
        matchLocation = request.location ?? "Unbekannter Ort"
        
        // ✅ Zeige Match Overlay
        withAnimation(.spring()) {
            showingMatchOverlay = true
        }
        
        triggerBumpHapticFeedback(.success)
    }
    
    private func showBumpDeclined(for request: BumpRequestData) {
        print("😔 Bump abgelehnt von \(request.detectedUser.name)")
        triggerBumpHapticFeedback(.impact(.light))
        
        // Optional: Zeige eine kurze Info-Nachricht
        // Hier könntest du ein Toast oder eine kurze Meldung anzeigen
    }
    
    // ✅ NEUE DISMISS FUNKTION FÜR REQUEST OVERLAY
    private func dismissCurrentRequestOverlay() {
        currentBumpRequest = nil
        showingBumpRequestOverlay = false
        
        // Nach kurzer Verzögerung nächste Anfrage anzeigen
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            showNextPendingRequest()
        }
    }
    
    private func showNextPendingRequest() {
        if !pendingBumpRequests.isEmpty && !showingMatchOverlay {
            let nextRequest = pendingBumpRequests.removeFirst()
            currentBumpRequest = nextRequest
            
            withAnimation(.spring()) {
                showingBumpRequestOverlay = true
            }
        }
    }
    
    private func requestLocationPermission() {
        if !locationManager.hasLocationPermission {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showingLocationPermission = true
            }
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
    
    // Test Section
    private var testSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🧪 Test-Bereich")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    TestButtonInternal(
                        icon: "location.circle.fill",
                        title: "Test Bump",
                        subtitle: "Bump Overlay",
                        color: .orange
                    ) {
                        triggerTestBump()
                    }
                    
                    TestButtonInternal(
                        icon: "heart.fill",
                        title: "Test Match",
                        subtitle: "Match Overlay",
                        color: .pink
                    ) {
                        triggerTestMatch()
                    }
                    
                    TestButtonInternal(
                        icon: "location.fill",
                        title: "GPS Test",
                        subtitle: "Ort abrufen",
                        color: .blue
                    ) {
                        testLocationRetrieval()
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
            
            Button(action: { showSettings = true }) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 50, height: 50)
                        .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 1))
                    
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private var statusCardsSection: some View {
        HStack(spacing: 16) {
            StatusCardInternal(
                icon: isBumping ? "circle.fill" : "circle",
                title: "Status",
                value: isBumping ? "Aktiv" : "Inaktiv",
                color: isBumping ? .green : .gray,
                animate: isBumping
            )
            
            StatusCardInternal(
                icon: "person.2.fill",
                title: "In der Nähe",
                value: "\(nearbyCount)",
                color: .orange,
                animate: isBumping
            )
            
            StatusCardInternal(
                icon: "clock.fill",
                title: "Aktive Zeit",
                value: formatTime(activeTime),
                color: .blue,
                animate: isBumping
            )
        }
    }
    
    private var mainBumpSection: some View {
        VStack(spacing: 30) {
            ZStack {
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
                
                ZStack {
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
                        .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 2))
                        .frame(width: 120, height: 120)
                    
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
    
    private var controlSection: some View {
        VStack(spacing: 20) {
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
    
    private var quickSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("⚙️ Einstellungen")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                QuickSettingCardInternal(
                    icon: "target",
                    title: "Reichweite",
                    subtitle: "10m Radius",
                    color: .blue
                ) {}
                
                QuickSettingCardInternal(
                    icon: "person.2.fill",
                    title: "Filter",
                    subtitle: "Alle Nutzer",
                    color: .purple
                ) {}
            }
        }
    }
    
    private var nearbyUsersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("👥 Nutzer in der Nähe")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            LazyVStack(spacing: 12) {
                ForEach(bleManager.nearbyUsers) { user in
                    NearbyUserCardInternal(user: user) {
                        simulateMatchWithNearbyUser(user)
                    }
                }
            }
        }
        .padding(20)
        .background(glassBackground)
        .cornerRadius(16)
    }
    
    // ✅ TEST FUNCTIONS (ANGEPASST!)
    
    private func triggerTestBump() {
        // ✅ GEÄNDERT: Zeigt jetzt das schöne Overlay
        let testUserNames = ["Anna Schmidt", "Max Weber", "Lisa Klein", "Tom Fischer", "Sarah Müller", "David Klein"]
        let testLocations = ["Café Central", "Stadtpark", "Universitätsbibliothek", "Murphy's Pub", "Fitnessstudio", "Bahnhof"]
        
        let testUser = DetectedUser(
            id: "test-user-\(Int.random(in: 1000...9999))",
            name: testUserNames.randomElement() ?? "Test User",
            rssi: Int.random(in: -80...(-60)),
            distance: Double.random(in: 5.0...15.0),
            firstDetected: Date(),
            lastSeen: Date(),
            services: [],
            manufacturerData: nil
        )
        
        let testEvent = BumpEvent(
            id: UUID().uuidString,
            detectedUser: testUser,
            timestamp: Date(),
            location: testLocations.randomElement() ?? "Test Location",
            distance: testUser.distance,
            duration: 2.0
        )
        
        // ✅ Verwende das neue Overlay-System
        handleNewBumpDetection(testEvent)
    }
    
    private func triggerTestMatch() {
        let testUser = BumpifyUser(
            firstName: "Test",
            lastName: "Match",
            email: "test@bumpify.com",
            interests: ["Testing", "Development"],
            age: 25,
            bio: "Test Match User",
            location: "Test Location"
        )
        
        matchedUser = testUser
        matchLocation = "Test Café"
        
        withAnimation(.spring()) {
            showingMatchOverlay = true
        }
    }
    
    private func testLocationRetrieval() {
        locationManager.getCurrentLocation { location in
            print("📍 Aktueller Ort: \(location ?? "Nicht verfügbar")")
        }
    }
    
    private func simulateMatchWithNearbyUser(_ detectedUser: DetectedUser) {
        let user = BumpifyUser(
            firstName: detectedUser.name,
            lastName: "",
            email: "user@bumpify.com",
            interests: ["Bumpify User"],
            age: 25,
            bio: "Ein echter Bumpify-Nutzer in deiner Nähe!",
            location: "In der Nähe"
        )
        
        matchedUser = user
        matchLocation = "Aktuelle Position"
        
        withAnimation(.spring()) {
            showingMatchOverlay = true
        }
    }
    
    // Helper Functions
    private func toggleBump() {
        isBumping.toggle()
        
        if isBumping {
            startTimer()
            if let userId = authManager.currentUser?.id {
                bleManager.startBumpMode(userID: userId)
            }
        } else {
            stopTimer()
            activeTime = 0
            nearbyCount = 0
            bleManager.stopBumpMode()
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
    
    private func triggerBumpHapticFeedback(_ type: BumpHapticFeedbackType) {
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

// ✅ UI KOMPONENTEN (vollständig)

struct TestButtonInternal: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
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
}

struct StatusCardInternal: View {
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
        .background(cardGlassBackground)
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
    
    private var cardGlassBackground: some View {
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

struct SystemStatusCardInternal: View {
    let icon: String
    let title: String
    let status: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(color)
            
            Text(status)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 9, weight: .medium))
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

struct NearbyUserCardInternal: View {
    let user: DetectedUser
    let onTap: (() -> Void)?
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(user.name.prefix(1))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("\(String(format: "%.1f", user.distance))m entfernt")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if onTap != nil {
                        Text("Tap = Test")
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
}

struct QuickSettingCardInternal: View {
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
            .background(settingGlassBackground)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var settingGlassBackground: some View {
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

struct PendingRequestInfoCardInternal: View {
    let request: BumpRequestData
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(request.detectedUser.name.prefix(2).uppercased())
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
            
            VStack(spacing: 4) {
                Text(request.detectedUser.name)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text("In Warteschlange")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.blue)
            }
        }
        .frame(width: 80)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct BumpSettingsViewInternal: View {
    @Environment(\.dismiss) private var dismiss
    @State private var detectionRange: Double = 10.0
    @State private var enableVibration = true
    @State private var enableSound = true
    
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

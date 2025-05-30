// BumpView.swift - Komplette Version mit BumpMatchOverlay
// Ersetze deine bestehende BumpView.swift komplett mit diesem Code

import SwiftUI
import CoreLocation

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
    
    // ✅ BUMP REQUEST STATES
    @State private var showingBumpRequest = false
    @State private var currentBumpRequest: BumpRequestData?
    @State private var pendingBumpRequests: [BumpRequestData] = []
    @State private var showingLocationPermission = false
    
    // ✅ MATCH OVERLAY INTEGRATION (GEÄNDERT!)
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
                    
                    // ✅ BUMP REQUEST SEKTION
                    if showingBumpRequest && currentBumpRequest != nil {
                        bumpRequestSection
                    }
                    
                    // Control Buttons
                    controlSection
                    
                    // Pending Requests
                    if !pendingBumpRequests.isEmpty && !showingBumpRequest {
                        pendingRequestsSection
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
        // ✅ OVERLAY HIER AUSSERHALB DES ZSTACK - GANZ OBEN!
        .overlay(
            Group {
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
    
    // ✅ BUMP REQUEST SEKTION
    private var bumpRequestSection: some View {
        VStack(spacing: 20) {
            // Animation Header
            VStack(spacing: 12) {
                // Bump Animation Icons
                HStack(spacing: 20) {
                    // Dein Avatar
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 60, height: 60)
                        
                        Text(authManager.currentUser?.initials ?? "Me")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    // Bump Animation
                    ZStack {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .stroke(Color.orange.opacity(0.7), lineWidth: 2)
                                .frame(width: 20 + CGFloat(index * 10))
                                .scaleEffect(animateStats ? 2.0 : 1.0)
                                .opacity(animateStats ? 0.0 : 1.0)
                                .animation(
                                    Animation.easeOut(duration: 1.0)
                                        .repeatForever()
                                        .delay(Double(index) * 0.2),
                                    value: animateStats
                                )
                        }
                        
                        Image(systemName: "wifi.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.orange)
                    }
                    
                    // Anderer User Avatar
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.blue, .teal], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 60, height: 60)
                        
                        Text(currentBumpRequest?.detectedUser.name.prefix(2).uppercased() ?? "??")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                // Bump Text
                VStack(spacing: 8) {
                    Text("🎯 Bump erkannt!")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    if let request = currentBumpRequest {
                        Text("You just bumped into \(request.detectedUser.name)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.orange)
                            .multilineTextAlignment(.center)
                        
                        if let location = request.location, !location.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.blue)
                                
                                Text(location)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(12)
                        }
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.05))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.orange.opacity(0.3), lineWidth: 2)
            )
            
            // Action Buttons
            VStack(spacing: 12) {
                Button(action: acceptBumpRequest) {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("Bump akzeptieren")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                
                Button(action: declineBumpRequest) {
                    HStack(spacing: 12) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("Ablehnen")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white.opacity(0.9))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
            }
            
            Text("Ein Bump entsteht nur, wenn beide Personen zustimmen")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .transition(.asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        ))
    }
    
    // ✅ PENDING REQUESTS SEKTION
    private var pendingRequestsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📋 Wartende Bump-Anfragen")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(pendingBumpRequests) { request in
                        PendingRequestCardInternal(request: request) {
                            showBumpRequest(request)
                        }
                    }
                }
                .padding(.horizontal, 1)
            }
        }
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
    
    // ✅ BUMP REQUEST FUNCTIONS
    
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
                if !showingBumpRequest {
                    currentBumpRequest = request
                    showingBumpRequest = true
                    triggerBumpHapticFeedback(.impact(.heavy))
                } else {
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
        
        simulateOtherUserResponse(for: acceptedRequest)
        dismissCurrentRequest()
    }
    
    private func declineBumpRequest() {
        guard let request = currentBumpRequest else { return }
        
        print("❌ Bump-Anfrage abgelehnt: \(request.detectedUser.name)")
        triggerBumpHapticFeedback(.impact(.light))
        
        dismissCurrentRequest()
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
    
    // ✅ GEÄNDERTE MATCH FUNKTION - Verwendet jetzt Overlay!
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
        
        // ✅ KORRIGIERT: Verwende das schöne Overlay anstatt fullScreenCover
        withAnimation(.spring()) {
            showingMatchOverlay = true
        }
        
        triggerBumpHapticFeedback(.success)
    }
    
    private func showBumpDeclined(for request: BumpRequestData) {
        print("😔 Bump abgelehnt von \(request.detectedUser.name)")
        triggerBumpHapticFeedback(.impact(.light))
    }
    
    private func dismissCurrentRequest() {
        withAnimation(.spring()) {
            showingBumpRequest = false
            currentBumpRequest = nil
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showNextPendingRequest()
        }
    }
    
    private func showNextPendingRequest() {
        if !pendingBumpRequests.isEmpty {
            let nextRequest = pendingBumpRequests.removeFirst()
            showBumpRequest(nextRequest)
        }
    }
    
    private func showBumpRequest(_ request: BumpRequestData) {
        currentBumpRequest = request
        withAnimation(.spring()) {
            showingBumpRequest = true
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
                        subtitle: "Simuliere Bump",
                        color: .orange
                    ) {
                        triggerTestBump()
                    }
                    
                    TestButtonInternal(
                        icon: "heart.fill",
                        title: "Test Match",
                        subtitle: "Match Animation",
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
    
    // ✅ TEST FUNCTIONS
    
    private func triggerTestBump() {
        // ✅ GEÄNDERT: Zurück zum echten Bump-Flow mit Anfrage
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
        
        // ✅ Zeige die Bump-Anfrage (Akzeptieren/Ablehnen)
        handleNewBumpDetection(testEvent)
    }
    
    // ✅ GEÄNDERTE TEST MATCH FUNKTION - Verwendet jetzt Overlay!
    private func triggerTestMatch() {
        // ✅ KORRIGIERT: Entferne die ungenutzte Variable
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
        
        // ✅ GEÄNDERT: Verwende das Overlay
        withAnimation(.spring()) {
            showingMatchOverlay = true
        }
    }
    
    private func testLocationRetrieval() {
        locationManager.getCurrentLocation { location in
            print("📍 Aktueller Ort: \(location ?? "Nicht verfügbar")")
        }
    }
    
    // ✅ GEÄNDERTE SIMULATE MATCH FUNKTION - Verwendet jetzt Overlay!
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
        
        // ✅ GEÄNDERT: Verwende das Overlay
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

// ✅ INTERNE UI KOMPONENTEN (um Konflikte zu vermeiden)

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

struct PendingRequestCardInternal: View {
    let request: BumpRequestData
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.orange)
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
                    
                    Text("Wartet...")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.orange)
                }
            }
            .frame(width: 80)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
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

// ✅ DATENMODELLE

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

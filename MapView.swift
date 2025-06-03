// MapView.swift - Neuer umfassender Explore Bereich
// Ersetze deine MapView.swift komplett mit diesem Code

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @StateObject private var businessBumpManager = BusinessBumpManager()
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 49.2041, longitude: 7.3066), // Zweibrücken
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    // Filter States
    @State private var showingFilters = false
    @State private var showUserEvents = true
    @State private var showBusinessEvents = true
    @State private var showBusinessBumps = true
    @State private var showBonusCards = true
    
    // Navigation States
    @State private var showingCreateHotspot = false
    @State private var selectedBusinessBump: BusinessBump?
    @State private var showingBusinessBumpDetail = false
    @State private var selectedHotspot: MapHotspot?
    @State private var showingHotspotDetail = false
    @State private var selectedBonusCard: MapBonusCard?
    @State private var showingBonusCardDetail = false
    @State private var showingAllBonusCards = false
    
    // Map Enhancement States
    @State private var mapInteractionMode: MapInteractionMode = .explore
    @State private var pendingHotspotLocation: CLLocationCoordinate2D?
    
    // Animation States
    @State private var animateStats = false
    @State private var currentTime = Date()
    
    // Sample Data
    @State private var nearbyHotspots: [MapHotspot] = []
    @State private var bonusCards: [MapBonusCard] = []
    
    let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    
    enum MapInteractionMode {
        case explore
        case createHotspot
    }
    
    var body: some View {
        ZStack {
            // Background - Matching HomeView
            backgroundGradient
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header - HomeView Style
                    headerSection
                    
                    // Interactive Map Section
                    interactiveMapSection
                    
                    // Quick Stats - HomeView Style
                    exploreStatsSection
                    
                    // Business Bumps Section
                    businessBumpsSection
                    
                    // Hotspots Section
                    hotspotsSection
                    
                    // Bonus Cards Section (Zukunft)
                    bonusCardsSection
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Bottom padding for tab bar
                    Spacer().frame(height: 100)
                }
                .padding(.top, 60)
                .padding(.horizontal, 20)
            }
            .refreshable {
                await refreshExploreData()
            }
            
            // Floating particles - HomeView Style
            floatingParticles
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            loadExploreData()
            startAnimations()
        }
        .onReceive(timer) { input in
            currentTime = input
            refreshDataPeriodically()
        }
        .sheet(isPresented: $showingFilters) {
            MapFiltersView()
        }
        .sheet(isPresented: $showingCreateHotspot) {
            CreateHotspotView()
        }
        .sheet(item: $selectedBusinessBump) { businessBump in
            BusinessBumpDetailView(businessBump: businessBump)
        }
        .sheet(item: $selectedHotspot) { hotspot in
            HotspotDetailView(hotspot: convertToHotspot(hotspot))
        }
        .sheet(isPresented: $showingBonusCardDetail) {
            if let card = selectedBonusCard {
                BonusCardDetailView(bonusCard: card)
            }
        }
        .sheet(isPresented: $showingAllBonusCards) {
            BonusCardsListView()
        }
    }
    
    // MARK: - Background - HomeView Style
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
    
    // MARK: - Floating Particles - HomeView Style
    private var floatingParticles: some View {
        ForEach(0..<5, id: \.self) { i in
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
    
    // MARK: - Header Section - HomeView Style
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("🧭 Explore")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 4) {
                    Text("explore the world around you")
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
            
            // Filter button
            Button(action: {
                triggerHapticFeedback(.impact(.light))
                showingFilters = true
            }) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .shadow(color: Color.orange.opacity(0.2), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                    
                    // Filter active indicator
                    if !showUserEvents || !showBusinessEvents || !showBusinessBumps {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 12, height: 12)
                            .offset(x: 18, y: -18)
                    }
                }
            }
        }
    }
    
    // MARK: - Interactive Map Section
    private var interactiveMapSection: some View {
        VStack(spacing: 16) {
            // Section Header
            HStack {
                Image(systemName: "map.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Interaktive Karte")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 8) {
                        // GPS Status Indicator
                        HStack(spacing: 4) {
                            Circle()
                                .fill(locationManager.authorizationStatus == .authorizedWhenInUse ? .green : .red)
                                .frame(width: 8, height: 8)
                            
                            Text(locationManager.authorizationStatus == .authorizedWhenInUse ? "GPS aktiv" : "GPS inaktiv")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    // Create Hotspot Toggle
                    Button(action: {
                        triggerHapticFeedback(.impact(.light))
                        withAnimation(.spring()) {
                            mapInteractionMode = mapInteractionMode == .explore ? .createHotspot : .explore
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(mapInteractionMode == .createHotspot ? .orange : Color.white.opacity(0.1))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: mapInteractionMode == .createHotspot ? "plus.circle.fill" : "plus.circle")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(mapInteractionMode == .createHotspot ? .white : .orange)
                        }
                    }
                    
                    Button("Vollbild") {
                        // Open fullscreen map
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)
                }
            }
            
            // Mode Indicator
            if mapInteractionMode == .createHotspot {
                HStack(spacing: 8) {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                    
                    Text("Tippe auf die Karte, um einen Hotspot zu erstellen")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.orange)
                    
                    Spacer()
                    
                    Button("Abbrechen") {
                        withAnimation(.spring()) {
                            mapInteractionMode = .explore
                        }
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.orange.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            ZStack {
                // Enhanced Map with Annotations
                Map(coordinateRegion: $region, annotationItems: mapAnnotations) { annotation in
                    MapAnnotation(coordinate: annotation.coordinate) {
                        MapMarkerView(annotation: annotation) {
                            handleAnnotationTap(annotation)
                        }
                    }
                }
                .frame(height: 250)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                )
                .onTapGesture { location in
                    if mapInteractionMode == .createHotspot {
                        handleMapTap(at: location)
                    }
                }
                
                // Map controls overlay
                VStack {
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 8) {
                            // GPS Location button
                            Button(action: {
                                centerOnUserLocation()
                            }) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .frame(width: 36, height: 36)
                                    .background(locationManager.authorizationStatus == .authorizedWhenInUse ? Color.blue : Color.gray)
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            }
                            
                            // Zoom controls
                            VStack(spacing: 2) {
                                Button("+") {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        region.span.latitudeDelta *= 0.5
                                        region.span.longitudeDelta *= 0.5
                                    }
                                }
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                                
                                Button("−") {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        region.span.latitudeDelta *= 2.0
                                        region.span.longitudeDelta *= 2.0
                                    }
                                }
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                            }
                        }
                    }
                    .padding(12)
                    
                    Spacer()
                }
            }
            .background(glassBackground)
            .cornerRadius(16)
            
            // Map Info Footer
            HStack(spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                    
                    Text(locationManager.userLocation != nil ? "GPS Position" : "Zweibrücken")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("Zuletzt aktualisiert: \(formatTime(currentTime))")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    // MARK: - Map Overlay Pins
    private var mapOverlayPins: some View {
        VStack {
            HStack {
                Spacer()
                
                if showUserEvents {
                    MapPin(type: .user, label: "After Work", color: .orange)
                        .offset(x: -40, y: -30)
                }
                
                Spacer()
            }
            
            HStack {
                if showBusinessEvents {
                    MapPin(type: .business, label: "Happy Hour", color: .green)
                        .offset(x: -70, y: 10)
                }
                
                Spacer()
                
                if showBusinessBumps {
                    MapPin(type: .businessBump, label: "20% Off", color: .purple)
                        .offset(x: 30, y: -10)
                }
            }
            
            Spacer()
            
            HStack {
                Spacer()
                
                if showUserEvents {
                    MapPin(type: .user, label: "Jogging", color: .orange)
                        .offset(x: 20, y: -20)
                }
            }
        }
        .padding(20)
    }
    
    // MARK: - Explore Stats Section - HomeView Style
    private var exploreStatsSection: some View {
        HStack(spacing: 12) {
            MapStatCard(
                icon: "person.2.fill",
                title: "Hotspots",
                value: "\(nearbyHotspots.count)",
                color: .orange,
                delay: 0.0,
                animate: animateStats
            ) {
                // Navigate to hotspots section
            }
            
            MapStatCard(
                icon: "building.2.fill",
                title: "Business",
                value: "\(businessBumpManager.nearbyBusinessBumps.count)",
                color: .green,
                delay: 0.2,
                animate: animateStats
            ) {
                // Navigate to business section
            }
            
            MapStatCard(
                icon: "gift.fill",
                title: "Goodies",
                value: "\(bonusCards.count)",
                color: .purple,
                delay: 0.4,
                animate: animateStats
            ) {
                showingAllBonusCards = true
            }
        }
    }
    
    // MARK: - Business Bumps Section
    private var businessBumpsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                Image(systemName: "building.2.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.green)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Business Angebote")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("\(businessBumpManager.nearbyBusinessBumps.count) Angebote in der Nähe")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Button("Alle") {
                    // Show all business bumps
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.green)
            }
            
            if businessBumpManager.nearbyBusinessBumps.isEmpty {
                MapEmptyState(
                    icon: "building.2",
                    title: "Keine Business Angebote",
                    subtitle: "Besuche lokale Geschäfte für exklusive Deals!"
                )
            } else {
                // Show top 2 business bumps
                VStack(spacing: 12) {
                    ForEach(businessBumpManager.nearbyBusinessBumps.prefix(2)) { businessBump in
                        CompactBusinessBumpCard(bump: businessBump) {
                            selectedBusinessBump = businessBump
                            showingBusinessBumpDetail = true
                            businessBumpManager.markAsClicked(businessBump)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Hotspots Section
    private var hotspotsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Aktive Hotspots")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("\(nearbyHotspots.count) Events in der Umgebung")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Button("Alle") {
                    // Show all hotspots
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.orange)
            }
            
            if nearbyHotspots.isEmpty {
                MapEmptyState(
                    icon: "person.2",
                    title: "Keine aktiven Hotspots",
                    subtitle: "Erstelle den ersten Hotspot in deiner Nähe!"
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(nearbyHotspots) { hotspot in
                            MapHotspotCard(hotspot: hotspot) {
                                selectedHotspot = hotspot
                                showingHotspotDetail = true
                            }
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
        }
    }
    
    // MARK: - Bonus Cards Section (Zukunft)
    private var bonusCardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                Image(systemName: "gift.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.purple)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Bonus Karten")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Sammle Punkte und erhalte Belohnungen")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Button("Alle") {
                    showingAllBonusCards = true
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.purple)
            }
            
            if bonusCards.isEmpty {
                MapEmptyState(
                    icon: "gift",
                    title: "Bonus Karten kommen bald",
                    subtitle: "Sammle Punkte bei deinen Lieblings-Geschäften!"
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(bonusCards) { card in
                            MapBonusCardView(card: card) {
                                selectedBonusCard = card
                                showingBonusCardDetail = true
                            }
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
        }
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("⚡ Schnellaktionen")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    ExploreQuickActionCard(
                        icon: "plus.circle.fill",
                        title: "Hotspot erstellen",
                        subtitle: "Neuen Treffpunkt anlegen",
                        gradient: [Color.orange, Color.red]
                    ) {
                        showingCreateHotspot = true
                    }
                    
                    ExploreQuickActionCard(
                        icon: "location.magnifyingglass",
                        title: "Umgebung scannen",
                        subtitle: "Nach neuen Angeboten suchen",
                        gradient: [Color.blue, Color.cyan]
                    ) {
                        businessBumpManager.refreshBusinessBumps()
                        triggerHapticFeedback(.success)
                    }
                }
                
                HStack(spacing: 12) {
                    ExploreQuickActionCard(
                        icon: "square.and.arrow.down",
                        title: "Offline Karte",
                        subtitle: "Bereich herunterladen",
                        gradient: [Color.green, Color.mint]
                    ) {
                        // Download offline map
                    }
                    
                    ExploreQuickActionCard(
                        icon: "bell.fill",
                        title: "Benachrichtigungen",
                        subtitle: "Alerts für neue Angebote",
                        gradient: [Color.purple, Color.pink]
                    ) {
                        // Configure notifications
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
    
    // MARK: - Helper Functions
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 1.0)) {
            animateStats = true
        }
    }
    
    @MainActor
    private func refreshExploreData() async {
        triggerHapticFeedback(.impact(.medium))
        
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        loadExploreData()
        businessBumpManager.refreshBusinessBumps()
        
        triggerHapticFeedback(.success)
    }
    
    private func refreshDataPeriodically() {
        // Refresh data every 30 seconds
        businessBumpManager.refreshBusinessBumps()
    }
    
    private func loadExploreData() {
        nearbyHotspots = MapHotspot.sampleData
        // Extended bonus cards sample data
        bonusCards = [
            MapBonusCard(
                id: "1",
                title: "Kaffee Sammler",
                description: "10 Kaffees = 1 gratis",
                businessName: "Café Central",
                points: 7,
                maxPoints: 10,
                color: .brown
            ),
            MapBonusCard(
                id: "2",
                title: "Fitness Punkte",
                description: "Trainiere regelmäßig",
                businessName: "Fitness First",
                points: 15,
                maxPoints: 20,
                color: .red
            ),
            MapBonusCard(
                id: "3",
                title: "Pizza Lover",
                description: "Jede 8. Pizza gratis",
                businessName: "Pizzeria Roma",
                points: 8,
                maxPoints: 8,
                color: .orange
            )
        ]
        businessBumpManager.simulateBusinessBumpsForTesting()
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func convertToHotspot(_ exploreHotspot: MapHotspot) -> Hotspot {
        return Hotspot(
            name: exploreHotspot.name,
            description: exploreHotspot.description,
            location: exploreHotspot.location,
            coordinate: BumpCoordinate(latitude: 49.2041, longitude: 7.3066),
            type: exploreHotspot.type == .user ? .user : .business,
            createdBy: "user",
            startTime: exploreHotspot.startTime,
            endTime: exploreHotspot.endTime,
            maxParticipants: exploreHotspot.maxParticipants
        )
    }
    
    private func triggerHapticFeedback(_ type: MapHapticFeedbackType) {
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

// MARK: - Map Components

struct MapPin: View {
    let type: MapPinType
    let label: String
    let color: Color
    @State private var isAnimating = false
    
    enum MapPinType {
        case user, business, businessBump
        
        var icon: String {
            switch self {
            case .user: return "person.2.fill"
            case .business: return "building.2.fill"
            case .businessBump: return "gift.fill"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Pulse ring
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 2)
                    .frame(width: 35, height: 35)
                    .scaleEffect(isAnimating ? 1.4 : 1.0)
                    .opacity(isAnimating ? 0.0 : 1.0)
                    .animation(
                        Animation.easeOut(duration: 2.0)
                            .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
                
                // Main pin
                Circle()
                    .fill(color)
                    .frame(width: 28, height: 28)
                    .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
                
                Image(systemName: type.icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(Color.black.opacity(0.7))
                .cornerRadius(6)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct MapStatCard: View {
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
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
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

struct MapQuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let gradient: [Color]
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
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
}

struct MapHotspotCard: View {
    let hotspot: MapHotspot
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
                
                Text("Teilnehmen")
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

struct MapBonusCardView: View {
    let card: MapBonusCard
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(card.color.opacity(0.2))
                            .frame(width: 30, height: 30)
                        
                        Image(systemName: "gift.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(card.color)
                    }
                    
                    Spacer()
                    
                    Text("\(card.points)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(card.color.opacity(0.3))
                        .cornerRadius(10)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(card.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(card.businessName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                    
                    Text(card.description)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(2)
                }
                
                Spacer()
                
                Text("Sammeln")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(card.color)
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

struct MapEmptyState: View {
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
        .background(
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
        )
    }
}

// MARK: - Data Models

struct MapHotspot: Identifiable {
    let id: String
    let name: String
    let description: String
    let location: String
    let type: MapHotspotType
    let participantCount: Int
    let maxParticipants: Int?
    let startTime: Date
    let endTime: Date
    
    enum MapHotspotType {
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
    
    static var sampleData: [MapHotspot] {
        return [
            MapHotspot(
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
            MapHotspot(
                id: "2",
                name: "Happy Hour",
                description: "20% auf alle Getränke",
                location: "Café Central",
                type: .business,
                participantCount: 12,
                maxParticipants: nil,
                startTime: Date(),
                endTime: Date().addingTimeInterval(7200)
            ),
            MapHotspot(
                id: "3",
                name: "Morning Jog",
                description: "Gemeinsam joggen gehen",
                location: "Stadtpark",
                type: .user,
                participantCount: 3,
                maxParticipants: 6,
                startTime: Date().addingTimeInterval(43200),
                endTime: Date().addingTimeInterval(46800)
            )
        ]
    }
}

struct MapBonusCard: Identifiable {
    let id: String
    let title: String
    let description: String
    let businessName: String
    let points: Int
    let maxPoints: Int
    let color: Color
    
    static var sampleData: [MapBonusCard] {
        return [
            MapBonusCard(
                id: "1",
                title: "Kaffee Sammler",
                description: "10 Kaffees = 1 gratis",
                businessName: "Café Central",
                points: 7,
                maxPoints: 10,
                color: .brown
            ),
            MapBonusCard(
                id: "2",
                title: "Fitness Punkte",
                description: "Trainiere regelmäßig",
                businessName: "Fitness First",
                points: 15,
                maxPoints: 20,
                color: .red
            )
        ]
    }
}

// MARK: - HapticFeedbackType
enum MapHapticFeedbackType {
    case success
    case impact(UIImpactFeedbackGenerator.FeedbackStyle)
    case selection
}

// MARK: - Map Annotations and GPS Functionality
extension MapView {
    
    // MARK: - Map Annotations
    var mapAnnotations: [MapAnnotationItem] {
        var annotations: [MapAnnotationItem] = []
        
        // Add hotspot annotations
        if showUserEvents || showBusinessEvents {
            for hotspot in nearbyHotspots {
                if (hotspot.type == .user && showUserEvents) || (hotspot.type == .business && showBusinessEvents) {
                    annotations.append(MapAnnotationItem(
                        id: hotspot.id,
                        coordinate: CLLocationCoordinate2D(
                            latitude: 49.2041 + Double.random(in: -0.005...0.005),
                            longitude: 7.3066 + Double.random(in: -0.005...0.005)
                        ),
                        type: hotspot.type == .user ? .hotspot : .business,
                        title: hotspot.name,
                        subtitle: hotspot.description
                    ))
                }
            }
        }
        
        // Add business bump annotations
        if showBusinessBumps {
            for businessBump in businessBumpManager.nearbyBusinessBumps.prefix(3) {
                annotations.append(MapAnnotationItem(
                    id: businessBump.id,
                    coordinate: CLLocationCoordinate2D(
                        latitude: 49.2041 + Double.random(in: -0.008...0.008),
                        longitude: 7.3066 + Double.random(in: -0.008...0.008)
                    ),
                    type: .business,
                    title: businessBump.businessName,
                    subtitle: businessBump.offerTitle
                ))
            }
        }
        
        return annotations
    }
    
    // MARK: - GPS Helper Functions
    private func centerOnUserLocation() {
        guard let userLocation = locationManager.userLocation else {
            locationManager.requestLocationPermission()
            return
        }
        
        withAnimation(.easeInOut(duration: 1.0)) {
            region = MKCoordinateRegion(
                center: userLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
    
    private func handleMapTap(at location: CGPoint) {
        // Convert tap location to coordinate (simplified)
        let coordinate = CLLocationCoordinate2D(
            latitude: region.center.latitude + Double.random(in: -0.005...0.005),
            longitude: region.center.longitude + Double.random(in: -0.005...0.005)
        )
        
        pendingHotspotLocation = coordinate
        showingCreateHotspot = true
        
        withAnimation(.spring()) {
            mapInteractionMode = .explore
        }
    }
    
    private func handleAnnotationTap(_ annotation: MapAnnotationItem) {
        switch annotation.type {
        case .hotspot:
            if let hotspot = nearbyHotspots.first(where: { $0.id == annotation.id }) {
                selectedHotspot = hotspot
                showingHotspotDetail = true
            }
        case .business:
            if let businessBump = businessBumpManager.nearbyBusinessBumps.first(where: { $0.id == annotation.id }) {
                selectedBusinessBump = businessBump
                showingBusinessBumpDetail = true
            }
        case .bonusCard:
            break
        }
    }
}

// MARK: - Map Annotation Item
struct MapAnnotationItem: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let type: AnnotationType
    let title: String
    let subtitle: String
    
    enum AnnotationType {
        case hotspot
        case business
        case bonusCard
    }
}

// MARK: - Map Marker View
struct MapMarkerView: View {
    let annotation: MapAnnotationItem
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                // Marker circle
                ZStack {
                    Circle()
                        .fill(markerColor)
                        .frame(width: 30, height: 30)
                        .shadow(color: markerColor.opacity(0.4), radius: 4, x: 0, y: 2)
                    
                    Image(systemName: markerIcon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                // Pointer
                Triangle()
                    .fill(markerColor)
                    .frame(width: 8, height: 8)
                    .offset(y: -2)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var markerColor: Color {
        switch annotation.type {
        case .hotspot: return .orange
        case .business: return .green
        case .bonusCard: return .purple
        }
    }
    
    private var markerIcon: String {
        switch annotation.type {
        case .hotspot: return "person.2.fill"
        case .business: return "building.2.fill"
        case .bonusCard: return "gift.fill"
        }
    }
}

// MARK: - Triangle Shape for Map Pointer
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startLocationUpdates() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            return
        }
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            startLocationUpdates()
        }
    }
}

#Preview {
    MapView()
}

// MapView.swift - Ersetze deine bestehende MapView komplett mit diesem Code
// Diese Version löst alle Konflikte und Fehler

import SwiftUI
import MapKit

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 49.2041, longitude: 7.3066), // Zweibrücken
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var showingFilters = false
    @State private var showingCreateHotspot = false
    @State private var animateStats = false
    
    var body: some View {
        ZStack {
            // Background - Matching Home/Bump Design
            backgroundGradient
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header - Matching Home/Bump style
                    headerSection
                    
                    // Map Container with Glass Effect
                    mapContainerSection
                    
                    // Stats Cards - Matching Home/Bump
                    statsSection
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Bottom padding for tab bar
                    Spacer().frame(height: 100)
                }
                .padding(.top, 60)
                .padding(.horizontal, 20)
            }
            
            // Floating particles - Matching Home/Bump
            floatingParticles
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            startAnimations()
        }
        .sheet(isPresented: $showingFilters) {
            MapFiltersView()
        }
        .sheet(isPresented: $showingCreateHotspot) {
            CreateHotspotView()
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
        ForEach(0..<4, id: \.self) { i in
            Circle()
                .fill(Color.orange.opacity(Double.random(in: 0.05...0.15)))
                .frame(width: CGFloat.random(in: 12...20))
                .offset(
                    x: CGFloat.random(in: -150...150),
                    y: CGFloat.random(in: -300...300) + (animateStats ? -15 : 15)
                )
                .animation(
                    Animation.easeInOut(duration: Double.random(in: 4.5...6.5))
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.4),
                    value: animateStats
                )
        }
    }
    
    // MARK: - Header Section - Matching Home/Bump
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("🗺️ Karte")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Entdecke Hotspots in deiner Umgebung")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Button(action: {
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
                    
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    // MARK: - Map Container
    private var mapContainerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                // Map with iOS 17+ compatible initializer
                Map(coordinateRegion: $region)
                    .frame(height: 350)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 2)
                    )
                
                // Simulated Hotspot Pins overlay
                simulatedHotspotPins
            }
            .background(glassBackground)
            .cornerRadius(20)
            
            // Location Info
            HStack(spacing: 12) {
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.orange)
                
                Text("Zweibrücken, Deutschland")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Zentrieren") {
                    // Center map action
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.orange)
            }
            .padding(16)
            .background(glassBackground)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Simulated Hotspot Pins
    private var simulatedHotspotPins: some View {
        VStack {
            HStack {
                Spacer()
                HotspotPin(type: .user, label: "After Work")
                    .offset(x: -30, y: -60)
                Spacer()
            }
            
            HStack {
                HotspotPin(type: .business, label: "Happy Hour")
                    .offset(x: -60, y: -10)
                
                Spacer()
                
                HotspotPin(type: .user, label: "Jogging")
                    .offset(x: 30, y: 20)
            }
            
            Spacer()
        }
        .padding(20)
    }
    
    // MARK: - Stats Section - Matching Home/Bump
    private var statsSection: some View {
        HStack(spacing: 16) {
            MapStatCard(
                icon: "person.2.fill",
                title: "User Events",
                value: "3",
                color: .orange,
                animate: animateStats
            )
            
            MapStatCard(
                icon: "building.2.fill",
                title: "Business",
                value: "5",
                color: .green,
                animate: animateStats
            )
            
            MapStatCard(
                icon: "clock.fill",
                title: "Heute aktiv",
                value: "8",
                color: .blue,
                animate: animateStats
            )
        }
    }
    
    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("⚡ Aktionen")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                QuickMapActionCard(
                    icon: "plus.circle.fill",
                    title: "Hotspot erstellen",
                    subtitle: "Neuen Treffpunkt anlegen",
                    gradient: [Color.orange, Color.red]
                ) {
                    showingCreateHotspot = true
                }
                
                QuickMapActionCard(
                    icon: "location.magnifyingglass",
                    title: "Umgebung erkunden",
                    subtitle: "Nahegelegene Spots finden",
                    gradient: [Color.blue, Color.cyan]
                ) {
                    // Explore action
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
}

// MARK: - Hotspot Pin Component
struct HotspotPin: View {
    let type: HotspotType
    let label: String
    @State private var isAnimating = false
    
    enum HotspotType {
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
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Pulse ring
                Circle()
                    .stroke(type.color.opacity(0.3), lineWidth: 2)
                    .frame(width: 40, height: 40)
                    .scaleEffect(isAnimating ? 1.3 : 1.0)
                    .opacity(isAnimating ? 0.0 : 1.0)
                    .animation(
                        Animation.easeOut(duration: 2.0)
                            .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
                
                // Main pin
                Circle()
                    .fill(type.color)
                    .frame(width: 30, height: 30)
                    .shadow(color: type.color.opacity(0.3), radius: 4, x: 0, y: 2)
                
                Image(systemName: type.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.black.opacity(0.7))
                .cornerRadius(6)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Map Stat Card
struct MapStatCard: View {
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
                        .delay(0.2)
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

// MARK: - Quick Map Action Card
struct QuickMapActionCard: View {
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





#Preview {
    MapView()
}

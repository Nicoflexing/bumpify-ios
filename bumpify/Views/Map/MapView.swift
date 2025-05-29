// MapView.swift - Ersetzt deine bestehende MapView.swift komplett

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
    @State private var selectedMapType = 0
    
    // Mock data
    @State private var nearbyHotspots = [
        MapHotspot(name: "After Work Drinks", type: .user, participantCount: 5),
        MapHotspot(name: "Happy Hour", type: .business, participantCount: 12),
        MapHotspot(name: "Morning Jog", type: .user, participantCount: 3),
        MapHotspot(name: "Coffee Break", type: .business, participantCount: 8)
    ]
    
    var body: some View {
        ZStack {
            // Background - Matching HomeView
            backgroundGradient
            
            VStack(spacing: 0) {
                // Header - Matching HomeView style
                headerSection
                
                // Stats Cards - Matching HomeView
                statsSection
                
                // Map Container with glass effect
                mapSection
                
                // Hotspot List
                hotspotListSection
            }
            
            // Floating particles - Matching HomeView
            floatingParticles
            
            // Floating Action Button
            floatingActionButton
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
        ForEach(0..<4, id: \.self) { i in
            Circle()
                .fill(Color.orange.opacity(Double.random(in: 0.05...0.15)))
                .frame(width: CGFloat.random(in: 10...20))
                .offset(
                    x: CGFloat.random(in: -150...150),
                    y: CGFloat.random(in: -300...300) + (animateStats ? -15 : 15)
                )
                .animation(
                    Animation.easeInOut(duration: Double.random(in: 5...7))
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.4),
                    value: animateStats
                )
        }
    }
    
    // MARK: - Header Section - Matching HomeView
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("🗺️ Karte")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Entdecke Hotspots in deiner Nähe")
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
        .padding(.horizontal, 20)
        .padding(.top, 60)
    }
    
    // MARK: - Stats Section - Matching HomeView
    private var statsSection: some View {
        HStack(spacing: 16) {
            MapStatCard(
                icon: "person.2.fill",
                title: "User Events",
                value: "\(nearbyHotspots.filter { $0.type == .user }.count)",
                color: .orange
            )
            
            MapStatCard(
                icon: "building.2.fill",
                title: "Business",
                value: "\(nearbyHotspots.filter { $0.type == .business }.count)",
                color: .green
            )
            
            MapStatCard(
                icon: "clock.fill",
                title: "Heute",
                value: "\(nearbyHotspots.count)",
                color: .blue
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    // MARK: - Map Section with glass effect
    private var mapSection: some View {
        VStack(spacing: 16) {
            // Map type selector
            HStack(spacing: 12) {
                MapTypeButton(title: "Standard", isSelected: selectedMapType == 0) {
                    selectedMapType = 0
                }
                MapTypeButton(title: "Satellite", isSelected: selectedMapType == 1) {
                    selectedMapType = 1
                }
                MapTypeButton(title: "Hybrid", isSelected: selectedMapType == 2) {
                    selectedMapType = 2
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // Map container with glass effect
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.05))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.1), lineWidth: 2)
                    )
                    .frame(height: 250)
                
                // Map placeholder with pins
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 246)
                    
                    // Simulated map pins
                    VStack {
                        HStack {
                            Spacer()
                            MapPin(type: .user, label: "After Work")
                                .offset(x: -30, y: -40)
                            Spacer()
                        }
                        
                        HStack {
                            MapPin(type: .business, label: "Happy Hour")
                                .offset(x: -60, y: -10)
                            
                            Spacer()
                            
                            MapPin(type: .user, label: "Coffee")
                                .offset(x: 40, y: 20)
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
                
                // Location indicator
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        
                        Text("Zweibrücken, Deutschland")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                    }
                    .padding(.bottom, 16)
                    .padding(.horizontal, 20)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Hotspot List Section
    private var hotspotListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🔥 Hotspots in der Nähe")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Alle anzeigen") {
                    // Show all hotspots
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.orange)
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(nearbyHotspots, id: \.id) { hotspot in
                        HotspotCard(hotspot: hotspot)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 120) // Space for tab bar
    }
    
    // MARK: - Floating Action Button
    private var floatingActionButton: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Button(action: {
                    showingCreateHotspot = true
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
                        
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .scaleEffect(animateStats ? 1.05 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true),
                    value: animateStats
                )
            }
            .padding(.trailing, 20)
            .padding(.bottom, 140)
        }
    }
    
    // MARK: - Helper Functions
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 1.0)) {
            animateStats = true
        }
    }
}

// MARK: - Map Stat Card - Matching HomeView design
struct MapStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(glassBackground)
        .cornerRadius(12)
    }
    
    private var glassBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.ultraThinMaterial)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}

// MARK: - Map Type Button
struct MapTypeButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ? Color.orange.opacity(0.3) : Color.white.opacity(0.1)
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 1)
                )
        }
    }
}

// MARK: - Map Pin
struct MapPin: View {
    let type: HotspotType
    let label: String
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Pulse ring
                Circle()
                    .stroke(type.color.opacity(0.3), lineWidth: 2)
                    .frame(width: 30, height: 30)
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
                    .frame(width: 20, height: 20)
                    .shadow(radius: 2)
                
                Image(systemName: type.icon)
                    .font(.caption2)
                    .foregroundColor(.white)
            }
            
            Text(label)
                .font(.caption2)
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

// MARK: - Hotspot Card - Matching HomeView design
struct HotspotCard: View {
    let hotspot: MapHotspot
    
    var body: some View {
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
                
                Text("Jetzt aktiv")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Button("Beitreten") {
                // Join hotspot
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(hotspot.type.color)
            .cornerRadius(8)
        }
        .frame(width: 140, height: 120)
        .padding(16)
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
struct MapHotspot: Identifiable {
    let id = UUID()
    let name: String
    let type: HotspotType
    let participantCount: Int
}

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

// MARK: - Filter View
struct MapFiltersView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.12, green: 0.16, blue: 0.24)
                    .ignoresSafeArea()
                
                VStack {
                    Text("🔍 Karten-Filter")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
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

// MARK: - Create Hotspot View
struct CreateHotspotView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.12, green: 0.16, blue: 0.24)
                    .ignoresSafeArea()
                
                VStack {
                    Text("➕ Hotspot erstellen")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Erstellen") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
    }
}

#Preview {
    MapView()
}

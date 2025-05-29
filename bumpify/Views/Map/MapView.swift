// MapView.swift - Aktualisierte Version mit MapFiltersView Verlinkung
// Ersetze deine bestehende MapView.swift komplett mit diesem Code

import SwiftUI
import MapKit

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 49.2041, longitude: 7.3066), // Zweibrücken
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var showingFilters = false
    @State private var showingCreateHotspot = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Text("🗺️ Karte")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // FILTER BUTTON - HIER IST DIE VERLINKUNG
                        Button(action: {
                            showingFilters = true
                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.title2)
                                .foregroundColor(.orange)
                                .padding(12)
                                .background(Circle().fill(Color.white.opacity(0.1)))
                        }
                    }
                    .padding()
                    
                    // Map Container
                    VStack(spacing: 15) {
                        ZStack {
                            Map(coordinateRegion: $region)
                                .frame(height: 400)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.orange, lineWidth: 2)
                                )
                            
                            // Simulated Hotspot Pins
                            VStack {
                                HStack {
                                    Spacer()
                                    HotspotPin(type: .user, label: "After Work")
                                        .offset(x: -50, y: -80)
                                    Spacer()
                                }
                                
                                HStack {
                                    HotspotPin(type: .business, label: "Happy Hour")
                                        .offset(x: -80, y: -20)
                                    
                                    Spacer()
                                    
                                    HotspotPin(type: .user, label: "Morning Jog")
                                        .offset(x: 40, y: 30)
                                }
                                
                                Spacer()
                            }
                            .padding()
                        }
                        
                        // Location Info
                        HStack {
                            Image(systemName: "location.circle.fill")
                                .foregroundColor(.orange)
                            
                            Text("Zweibrücken, Deutschland")
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    
                    // Hotspots Info
                    VStack(spacing: 15) {
                        Text("Hotspots in der Nähe")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 20) {
                            HotspotInfoCard(
                                icon: "person.2.fill",
                                title: "User Events",
                                count: "3",
                                color: .orange
                            )
                            
                            HotspotInfoCard(
                                icon: "building.2.fill",
                                title: "Business",
                                count: "5",
                                color: .green
                            )
                            
                            HotspotInfoCard(
                                icon: "clock.fill",
                                title: "Heute",
                                count: "8",
                                color: .blue
                            )
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Create Hotspot Button
                    Button(action: { showingCreateHotspot = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            
                            Text("Neuen Hotspot erstellen")
                                .font(.headline)
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
                        .cornerRadius(15)
                    }
                    .padding(.horizontal)
                }
            }
        }
        // HIER SIND DIE VERLINKUNGEN ZU DEN ANDEREN SCREENS
        .sheet(isPresented: $showingFilters) {
            MapFiltersView() // ← VERLINKUNG ZU MAPFILTERSVIEW
        }
        .sheet(isPresented: $showingCreateHotspot) {
            CreateHotspotView()
        }
    }
}

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
                    .shadow(radius: 3)
                
                Image(systemName: type.icon)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.black.opacity(0.7))
                .cornerRadius(8)
        }
        .onAppear {
            isAnimating = true
        }
        .onTapGesture {
            print("Hotspot angeklickt: \(label)")
        }
    }
}

struct HotspotInfoCard: View {
    let icon: String
    let title: String
    let count: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(count)
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

#Preview {
    MapView()
}

// MapView.swift - Figma Design Implementation

import SwiftUI
import MapKit

struct MapView: View {
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 49.2041, longitude: 7.3066),
            span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
        )
    )
    @State private var searchText = ""
    @State private var showingFilters = false
    @State private var selectedHotspot: FigmaHotspot?
    @State private var showingHotspotDetail = false
    
    // Sample hotspots matching the Figma design
    private let figmaHotspots: [FigmaHotspot] = [
        FigmaHotspot(id: "1", name: "Café Central", description: "Free Coffee Today! 2-4pm", coordinate: CLLocationCoordinate2D(latitude: 49.2041, longitude: 7.3066), type: .business, distance: "120m", icon: "cup.and.saucer.fill"),
        FigmaHotspot(id: "2", name: "Skatepark Treff", description: "Casual skating session, beginners welcome!", coordinate: CLLocationCoordinate2D(latitude: 49.2045, longitude: 7.3070), type: .user, distance: "180m", icon: "figure.skating"),
        FigmaHotspot(id: "3", name: "Yoga Studio", description: "Group session starting in 30 mins", coordinate: CLLocationCoordinate2D(latitude: 49.2038, longitude: 7.3062), type: .business, distance: "250m", icon: "figure.yoga"),
        FigmaHotspot(id: "4", name: "Study Group", description: "Mathematics study group", coordinate: CLLocationCoordinate2D(latitude: 49.2048, longitude: 7.3075), type: .user, distance: "320m", icon: "book.fill"),
        FigmaHotspot(id: "5", name: "Food Truck", description: "Best tacos in town!", coordinate: CLLocationCoordinate2D(latitude: 49.2035, longitude: 7.3058), type: .business, distance: "150m", icon: "fork.knife"),
        FigmaHotspot(id: "6", name: "Basketball Court", description: "Pick-up game starting now", coordinate: CLLocationCoordinate2D(latitude: 49.2052, longitude: 7.3080), type: .user, distance: "400m", icon: "basketball.fill"),
        FigmaHotspot(id: "7", name: "Art Gallery", description: "New exhibition opening", coordinate: CLLocationCoordinate2D(latitude: 49.2030, longitude: 7.3050), type: .business, distance: "500m", icon: "paintbrush.fill"),
        FigmaHotspot(id: "8", name: "Dog Park", description: "Daily dog meetup", coordinate: CLLocationCoordinate2D(latitude: 49.2055, longitude: 7.3085), type: .user, distance: "480m", icon: "pawprint.fill")
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with search and filters
                headerView
                
                // Map with custom styling
                mapView
                
                // Bottom hotspots list
                bottomHotspotsList
            }
        }
        .sheet(isPresented: $showingFilters) {
            FiltersSheet()
        }
        .sheet(item: $selectedHotspot) { hotspot in
            HotspotDetailSheet(hotspot: hotspot)
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            // Top navigation
            HStack {
                Text("bumpify")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.orange, Color.red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: {}) {
                        Image(systemName: "bell")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "line.3.horizontal")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                }
            }
            
            // Search bar with filters
            HStack(spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.6))
                    
                    TextField("Search hotspots...", text: $searchText)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .placeholder(when: searchText.isEmpty) {
                            Text("Search hotspots...")
                                .foregroundColor(.white.opacity(0.4))
                        }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                
                // Filter buttons
                Button(action: { showingFilters = true }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                        )
                }
                
                Button(action: {}) {
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                        )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .background(Color.black)
    }
    
    // MARK: - Map View
    private var mapView: some View {
        ZStack {
            // Dark style map
            if #available(iOS 17.0, *) {
                Map(position: $cameraPosition) {
                    ForEach(figmaHotspots) { hotspot in
                        Annotation(hotspot.name, coordinate: hotspot.coordinate) {
                            FigmaHotspotPin(hotspot: hotspot) {
                                selectedHotspot = hotspot
                                showingHotspotDetail = true
                            }
                        }
                    }
                }
                .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
                .mapControls {
                    MapCompass()
                        .mapControlVisibility(.hidden)
                }
            } else {
                // Fallback for older iOS versions
                FallbackMapView(hotspots: figmaHotspots)
            }
        }
        .clipShape(Rectangle())
    }
    
    // MARK: - Bottom Hotspots List
    private var bottomHotspotsList: some View {
        VStack(spacing: 0) {
            // Handle bar
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.white.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(figmaHotspots.prefix(3)) { hotspot in
                        FigmaHotspotCard(hotspot: hotspot) {
                            selectedHotspot = hotspot
                            showingHotspotDetail = true
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 100) // Tab bar space
            }
        }
        .frame(maxHeight: 280)
        .background(
            Color.black
                .clipShape(
                    RoundedRectangle(cornerRadius: 0)
                )
        )
    }
}

// MARK: - Figma Hotspot Model
struct FigmaHotspot: Identifiable {
    let id: String
    let name: String
    let description: String
    let coordinate: CLLocationCoordinate2D
    let type: HotspotPinType
    let distance: String
    let icon: String
    
    enum HotspotPinType {
        case user, business
        
        var color: Color {
            switch self {
            case .user: return Color.orange
            case .business: return Color.green
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .user: return Color.orange.opacity(0.2)
            case .business: return Color.green.opacity(0.2)
            }
        }
    }
}

// MARK: - Figma Hotspot Pin
struct FigmaHotspotPin: View {
    let hotspot: FigmaHotspot
    let onTap: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Shadow/glow effect
                Circle()
                    .fill(hotspot.type.color.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .blur(radius: 8)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                
                // Main pin background
                Circle()
                    .fill(hotspot.type.color)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                
                // Icon
                Image(systemName: hotspot.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .scaleEffect(isAnimating ? 1.1 : 1.0)
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
                    .delay(Double.random(in: 0...1))
            ) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Figma Hotspot Card
struct FigmaHotspotCard: View {
    let hotspot: FigmaHotspot
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon with background
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(hotspot.type.backgroundColor)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: hotspot.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(hotspot.type.color)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(hotspot.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(hotspot.description)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Distance
                Text(hotspot.distance)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Fallback Map View
struct FallbackMapView: UIViewRepresentable {
    let hotspots: [FigmaHotspot]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.preferredConfiguration = MKStandardMapConfiguration()
        mapView.overrideUserInterfaceStyle = .dark
        mapView.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 49.2041, longitude: 7.3066),
            span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
        )
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Update annotations if needed
    }
}

// MARK: - Sheets
struct FiltersSheet: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    Text("🔧 Filter")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    
                    Text("Hier kommen die Kartenfilter!")
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct HotspotDetailSheet: View {
    let hotspot: FigmaHotspot
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("📍 \(hotspot.name)")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    
                    Text(hotspot.description)
                        .font(.title3)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    Text("Entfernung: \(hotspot.distance)")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Hotspot Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - TextField Placeholder Extension
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    MapView()
}

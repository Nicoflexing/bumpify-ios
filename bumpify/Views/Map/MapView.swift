import SwiftUI
import MapKit

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 49.2041, longitude: 7.3066), // Zweibrücken
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var showingFilters = false
    @State private var showingCreateHotspot = false
    @State private var hotspots: [BumpifyHotspot] = []
    @State private var nearbyUsers: [BumpifyUser] = []
    @State private var selectedHotspot: BumpifyHotspot?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.12, blue: 0.18).ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Map Container
                    mapSection
                    
                    // Stats
                    statsSection
                    
                    // Create Hotspot Button
                    createHotspotButton
                }
            }
        }
        .sheet(isPresented: $showingFilters) {
            MapFiltersView()
        }
        .sheet(isPresented: $showingCreateHotspot) {
            CreateHotspotView()
        }
        .sheet(item: $selectedHotspot) { hotspot in
            HotspotDetailView(hotspot: hotspot)
        }
        .onAppear {
            loadMockData()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Text("🗺️ Karte")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: { showingFilters = true }) {
                Image(systemName: "slider.horizontal.3")
                    .font(.title2)
                    .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.1))
                    .padding(8)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Map Section
    private var mapSection: some View {
        VStack(spacing: 15) {
            ZStack {
                // Map
                Map(coordinateRegion: $region)
                    .frame(height: 400)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(red: 1.0, green: 0.5, blue: 0.1), lineWidth: 2)
                    )
                
                // Simulated Hotspot Pins (Overlay)
                VStack {
                    HStack {
                        Spacer()
                        HotspotPin(
                            hotspot: hotspots.first { $0.hotspotType == .user } ?? mockUserHotspot(),
                            action: { hotspot in selectedHotspot = hotspot }
                        )
                        .offset(x: -50, y: -80)
                        Spacer()
                    }
                    
                    HStack {
                        HotspotPin(
                            hotspot: hotspots.first { $0.hotspotType == .business } ?? mockBusinessHotspot(),
                            action: { hotspot in selectedHotspot = hotspot }
                        )
                        .offset(x: -80, y: -20)
                        
                        Spacer()
                        
                        HotspotPin(
                            hotspot: hotspots.last ?? mockUserHotspot(),
                            action: { hotspot in selectedHotspot = hotspot }
                        )
                        .offset(x: 40, y: 30)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            
            // Location Info
            HStack {
                Image(systemName: "location.circle.fill")
                    .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.1))
                
                Text("Zweibrücken, Deutschland")
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Mein Standort") {
                    // Center on user location
                }
                .font(.caption)
                .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.1))
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        VStack(spacing: 15) {
            Text("Hotspots in der Nähe")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                MapStatCard(
                    icon: "person.2.fill",
                    title: "User Events",
                    count: "\(hotspots.filter { $0.hotspotType == .user }.count)",
                    color: Color(red: 1.0, green: 0.4, blue: 0.2)
                )
                
                MapStatCard(
                    icon: "building.2.fill",
                    title: "Business",
                    count: "\(hotspots.filter { $0.hotspotType == .business }.count)",
                    color: .green
                )
                
                MapStatCard(
                    icon: "clock.fill",
                    title: "Heute",
                    count: "\(hotspots.filter { $0.isHappening }.count)",
                    color: .blue
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
        .padding(.horizontal)
    }
    
    // MARK: - Create Hotspot Button
    private var createHotspotButton: some View {
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
                    colors: [
                        Color(red: 1.0, green: 0.4, blue: 0.2),
                        Color(red: 1.0, green: 0.6, blue: 0.0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(15)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Load Mock Data
    private func loadMockData() {
        hotspots = [
            BumpifyHotspot(
                name: "After Work Drinks",
                description: "Entspannte Runde nach der Arbeit",
                location: BumpifyLocation(latitude: 49.2041, longitude: 7.3066, city: "Zweibrücken"),
                creatorId: UUID(),
                hotspotType: .user,
                startTime: Date(),
                endTime: Date().addingTimeInterval(7200),
                participants: [UUID(), UUID(), UUID()],
                maxParticipants: 10,
                category: .social
            ),
            BumpifyHotspot(
                name: "Happy Hour",
                description: "20% Rabatt auf alle Getränke",
                location: BumpifyLocation(latitude: 49.2045, longitude: 7.3070, city: "Zweibrücken"),
                creatorId: UUID(),
                hotspotType: .business,
                startTime: Date(),
                endTime: Date().addingTimeInterval(3600),
                participants: [UUID(), UUID()],
                category: .food
            ),
            BumpifyHotspot(
                name: "Morning Jog",
                description: "Gemeinsam joggen gehen",
                location: BumpifyLocation(latitude: 49.2038, longitude: 7.3062, city: "Zweibrücken"),
                creatorId: UUID(),
                hotspotType: .user,
                startTime: Date().addingTimeInterval(86400),
                endTime: Date().addingTimeInterval(90000),
                participants: [UUID()],
                maxParticipants: 5,
                category: .sports
            )
        ]
        
        nearbyUsers = [
            BumpifyUser(firstName: "Anna", lastName: "Schmidt", email: "anna@test.de", age: 25),
            BumpifyUser(firstName: "Max", lastName: "Mueller", email: "max@test.de", age: 28),
            BumpifyUser(firstName: "Lisa", lastName: "Weber", email: "lisa@test.de", age: 24)
        ]
    }
    
    // MARK: - Mock Helpers
    private func mockUserHotspot() -> BumpifyHotspot {
        return BumpifyHotspot(
            name: "Sample Event",
            description: "Sample Description",
            location: BumpifyLocation(latitude: 49.2041, longitude: 7.3066),
            creatorId: UUID(),
            hotspotType: .user,
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            category: .social
        )
    }
    
    private func mockBusinessHotspot() -> BumpifyHotspot {
        return BumpifyHotspot(
            name: "Sample Business",
            description: "Sample Offer",
            location: BumpifyLocation(latitude: 49.2041, longitude: 7.3066),
            creatorId: UUID(),
            hotspotType: .business,
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            category: .business
        )
    }
}

// MARK: - Supporting Views
struct HotspotPin: View {
    let hotspot: BumpifyHotspot
    let action: (BumpifyHotspot) -> Void
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Pulse ring
                Circle()
                    .stroke(hotspot.hotspotType.color.opacity(0.3), lineWidth: 2)
                    .frame(width: 40, height: 40)
                    .scaleEffect(isAnimating ? 1.3 : 1.0)
                    .opacity(isAnimating ? 0.0 : 1.0)
                    .animation(
                        Animation.easeOut(duration: 2.0)
                            .repeatForever()
                            .delay(Double.random(in: 0...1)),
                        value: isAnimating
                    )
                
                // Main pin
                Circle()
                    .fill(hotspot.hotspotType.color)
                    .frame(width: 30, height: 30)
                    .shadow(radius: 3)
                
                Image(systemName: hotspot.hotspotType.icon)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            
            Text(hotspot.name)
                .font(.caption2)
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.black.opacity(0.7))
                .cornerRadius(8)
                .lineLimit(1)
        }
        .onAppear {
            isAnimating = true
        }
        .onTapGesture {
            action(hotspot)
        }
    }
}

struct MapStatCard: View {
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

// MARK: - Map Filters View
struct MapFiltersView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategories: Set<BumpifyHotspot.HotspotCategory> = []
    @State private var selectedTypes: Set<BumpifyHotspot.HotspotType> = []
    @State private var maxDistance: Double = 5.0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.12, blue: 0.18).ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("🔍 Karten-Filter")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 20) {
                        // Distance Filter
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Entfernung: \(Int(maxDistance)) km")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Slider(value: $maxDistance, in: 1...20, step: 1)
                                .accentColor(Color(red: 1.0, green: 0.5, blue: 0.1))
                        }
                        
                        // Category Filter
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Kategorien")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                                ForEach(BumpifyHotspot.HotspotCategory.allCases, id: \.self) { category in
                                    CategoryFilterButton(
                                        category: category,
                                        isSelected: selectedCategories.contains(category)
                                    ) {
                                        if selectedCategories.contains(category) {
                                            selectedCategories.remove(category)
                                        } else {
                                            selectedCategories.insert(category)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Type Filter
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Typ")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            HStack(spacing: 12) {
                                ForEach(BumpifyHotspot.HotspotType.allCases, id: \.self) { type in
                                    TypeFilterButton(
                                        type: type,
                                        isSelected: selectedTypes.contains(type)
                                    ) {
                                        if selectedTypes.contains(type) {
                                            selectedTypes.remove(type)
                                        } else {
                                            selectedTypes.insert(type)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Apply Button
                    Button(action: {
                        // Apply filters
                        dismiss()
                    }) {
                        Text("Filter anwenden")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.4, blue: 0.2),
                                        Color(red: 1.0, green: 0.6, blue: 0.0)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Schließen") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.1))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Zurücksetzen") {
                        selectedCategories.removeAll()
                        selectedTypes.removeAll()
                        maxDistance = 5.0
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.1))
                }
            }
        }
    }
}

struct CategoryFilterButton: View {
    let category: BumpifyHotspot.HotspotCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: category.icon)
                    .font(.caption)
                
                Text(category.displayName)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected ?
                Color(red: 1.0, green: 0.5, blue: 0.1).opacity(0.3) :
                Color.white.opacity(0.1)
            )
            .foregroundColor(isSelected ? Color(red: 1.0, green: 0.5, blue: 0.1) : .white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color(red: 1.0, green: 0.5, blue: 0.1) : Color.clear, lineWidth: 1)
            )
        }
    }
}

struct TypeFilterButton: View {
    let type: BumpifyHotspot.HotspotType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: type.icon)
                    .font(.caption)
                
                Text(type == .user ? "Nutzer" : "Business")
                    .font(.caption)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                isSelected ?
                type.color.opacity(0.3) :
                Color.white.opacity(0.1)
            )
            .foregroundColor(isSelected ? type.color : .white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? type.color : Color.clear, lineWidth: 1)
            )
        }
    }
}

// MARK: - Hotspot Detail View
struct HotspotDetailView: View {
    let hotspot: BumpifyHotspot
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.12, blue: 0.18).ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Circle()
                            .fill(hotspot.hotspotType.color.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: hotspot.hotspotType.icon)
                                    .font(.system(size: 40))
                                    .foregroundColor(hotspot.hotspotType.color)
                            )
                        
                        Text(hotspot.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text(hotspot.description)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    
                    // Details
                    VStack(spacing: 16) {
                        HotspotDetailRow(
                            icon: "clock.fill",
                            title: "Zeit",
                            value: timeRangeString(start: hotspot.startTime, end: hotspot.endTime)
                        )
                        
                        HotspotDetailRow(
                            icon: "person.2.fill",
                            title: "Teilnehmer",
                            value: "\(hotspot.participantCount)" + (hotspot.maxParticipants != nil ? "/\(hotspot.maxParticipants!)" : "")
                        )
                        
                        if let city = hotspot.location.city {
                            HotspotDetailRow(
                                icon: "location.fill",
                                title: "Ort",
                                value: city
                            )
                        }
                        
                        HotspotDetailRow(
                            icon: "tag.fill",
                            title: "Kategorie",
                            value: hotspot.category.displayName
                        )
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(16)
                    
                    Spacer()
                    
                    // Action Button
                    if hotspot.isHappening && !hotspot.isFull {
                        Button(action: {
                            // Join hotspot
                            dismiss()
                        }) {
                            Text("Teilnehmen")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(hotspot.hotspotType.color)
                                .cornerRadius(12)
                        }
                    } else if hotspot.isFull {
                        Text("Hotspot ist voll")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(12)
                    } else {
                        Text("Hotspot ist nicht aktiv")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Schließen") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.1))
                }
            }
        }
    }
    
    private func timeRangeString(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
}

struct HotspotDetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.1))
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
    }
}

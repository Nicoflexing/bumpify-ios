import SwiftUI

struct BumpView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var isBumpActive = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var activeTime = 0
    @State private var timer: Timer?
    @State private var nearbyUsers: [BumpifyUser] = []
    @State private var recentBumps: [BumpEvent] = []
    @State private var showingFilters = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.12, blue: 0.18).ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header
                    headerSection
                    
                    // Status Cards
                    statusCardsSection
                    
                    Spacer()
                    
                    // Main Bump Visualization
                    bumpVisualizationSection
                    
                    Spacer()
                    
                    // Main Action Button
                    mainActionButton
                    
                    // Quick Actions
                    quickActionsSection
                }
            }
        }
        .sheet(isPresented: $showingFilters) {
            BumpFiltersView()
        }
        .onDisappear {
            stopTimer()
        }
        .onAppear {
            loadMockData()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("⚡ Bump Modus")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(isBumpActive ? "Du bist sichtbar" : "Du bist unsichtbar")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
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
    
    // MARK: - Status Cards Section
    private var statusCardsSection: some View {
        HStack(spacing: 15) {
            BumpStatusCard(
                icon: "circle.fill",
                title: "Status",
                value: isBumpActive ? "Aktiv" : "Inaktiv",
                color: isBumpActive ? .green : .gray
            )
            
            BumpStatusCard(
                icon: "person.2.fill",
                title: "In der Nähe",
                value: "\(nearbyUsers.count)",
                color: Color(red: 1.0, green: 0.4, blue: 0.2)
            )
            
            BumpStatusCard(
                icon: "clock.fill",
                title: "Aktive Zeit",
                value: formatTime(activeTime),
                color: .blue
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Bump Visualization Section
    private var bumpVisualizationSection: some View {
        ZStack {
            // Outer rings
            ForEach(0..<3, id: \.self) { ring in
                Circle()
                    .stroke(
                        isBumpActive ?
                        Color(red: 1.0, green: 0.4, blue: 0.2).opacity(0.3) :
                        Color.gray.opacity(0.2),
                        lineWidth: 2
                    )
                    .frame(width: 200 + CGFloat(ring * 40))
                    .scaleEffect(isBumpActive ? 1.0 + CGFloat(ring) * 0.1 : 1.0)
                    .opacity(isBumpActive ? 1.0 - Double(ring) * 0.3 : 0.5)
                    .animation(
                        isBumpActive ?
                        Animation.easeInOut(duration: 2.0)
                            .repeatForever()
                            .delay(Double(ring) * 0.3) :
                        .default,
                        value: isBumpActive
                    )
            }
            
            // Detected users (dots around the center)
            if isBumpActive && !nearbyUsers.isEmpty {
                ForEach(Array(nearbyUsers.enumerated()), id: \.offset) { index, user in
                    DetectedUserDot(user: user, index: index)
                }
            }
            
            // Center orb
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: isBumpActive ? [
                                Color(red: 1.0, green: 0.4, blue: 0.2),
                                Color(red: 1.0, green: 0.6, blue: 0.0)
                            ] : [.gray, .gray.opacity(0.5)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .scaleEffect(pulseScale)
                    .shadow(
                        color: isBumpActive ?
                        Color(red: 1.0, green: 0.4, blue: 0.2).opacity(0.5) :
                        .clear,
                        radius: 20
                    )
                
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            .onAppear {
                startPulseAnimation()
            }
            .onChange(of: isBumpActive) { oldValue, newValue in
                if newValue {
                    startPulseAnimation()
                    startTimer()
                } else {
                    stopPulseAnimation()
                    stopTimer()
                }
            }
        }
        .frame(height: 300)
    }
    
    // MARK: - Main Action Button
    private var mainActionButton: some View {
        Button(action: {
            withAnimation(.spring()) {
                isBumpActive.toggle()
            }
        }) {
            HStack(spacing: 15) {
                Image(systemName: isBumpActive ? "pause.fill" : "play.fill")
                    .font(.title2)
                
                Text(isBumpActive ? "Bump Stoppen" : "Bump Starten")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: isBumpActive ? [
                        .red,
                        .red.opacity(0.8)
                    ] : [
                        Color(red: 1.0, green: 0.4, blue: 0.2),
                        Color(red: 1.0, green: 0.6, blue: 0.0)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(
                color: isBumpActive ?
                .red.opacity(0.3) :
                Color(red: 1.0, green: 0.4, blue: 0.2).opacity(0.3),
                radius: 10
            )
        }
        .scaleEffect(isBumpActive ? 0.98 : 1.0)
        .animation(.spring(response: 0.3), value: isBumpActive)
        .padding(.horizontal)
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        HStack(spacing: 20) {
            QuickActionButton(
                icon: "slider.horizontal.3",
                title: "Filter"
            ) {
                showingFilters = true
            }
            
            QuickActionButton(
                icon: "target",
                title: "Reichweite"
            ) {
                // Adjust range
            }
            
            QuickActionButton(
                icon: "bolt.fill",
                title: "Boost"
            ) {
                // Super Bump
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Animation Methods
    private func startPulseAnimation() {
        withAnimation(
            Animation.easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
        ) {
            pulseScale = isBumpActive ? 1.1 : 1.0
        }
    }
    
    private func stopPulseAnimation() {
        withAnimation(.default) {
            pulseScale = 1.0
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if isBumpActive {
                activeTime += 1
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    // MARK: - Load Mock Data
    private func loadMockData() {
        nearbyUsers = [
            BumpifyUser(firstName: "Anna", lastName: "S.", email: "anna@test.de", age: 25, interests: ["Musik"]),
            BumpifyUser(firstName: "Max", lastName: "M.", email: "max@test.de", age: 28, interests: ["Sport"]),
            BumpifyUser(firstName: "Lisa", lastName: "W.", email: "lisa@test.de", age: 24, interests: ["Kunst"])
        ]
    }
}

// MARK: - Supporting Views
struct BumpStatusCard: View {
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
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct DetectedUserDot: View {
    let user: BumpifyUser
    let index: Int
    @State private var animationOffset = false
    
    private var position: (x: CGFloat, y: CGFloat) {
        let angle = Double(index) * (2 * .pi / 3) // Distribute around circle
        let radius: CGFloat = 80
        return (
            x: cos(angle) * radius,
            y: sin(angle) * radius
        )
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.4, blue: 0.2),
                            Color(red: 1.0, green: 0.6, blue: 0.0)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 20, height: 20)
                .shadow(radius: 3)
                .scaleEffect(animationOffset ? 1.2 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.3),
                    value: animationOffset
                )
            
            Text(user.firstName)
                .font(.caption2)
                .foregroundColor(.white)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(Color.black.opacity(0.6))
                .cornerRadius(4)
        }
        .offset(x: position.x, y: position.y)
        .onAppear {
            animationOffset = true
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.1))
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
}

// MARK: - Bump Filters View
struct BumpFiltersView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var ageRange: ClosedRange<Double> = 18...35
    @State private var maxDistance: Double = 10.0
    @State private var selectedInterests: Set<String> = []
    @State private var lookingFor: Set<UserPreferences.LookingForType> = [.friends]
    
    private let availableInterests = [
        "Musik", "Sport", "Reisen", "Kaffee", "Kunst", "Fotografie",
        "Bücher", "Gaming", "Kochen", "Tanzen", "Filme", "Natur"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.12, blue: 0.18).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        Text("🔍 Bump-Filter")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        VStack(spacing: 20) {
                            // Age Range
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Altersbereich: \(Int(ageRange.lowerBound))-\(Int(ageRange.upperBound)) Jahre")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                // Custom range slider would go here
                                HStack {
                                    Text("18")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                    
                                    Spacer()
                                    
                                    Text("65")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            
                            // Distance
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Entfernung: \(Int(maxDistance)) km")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Slider(value: $maxDistance, in: 1...50, step: 1)
                                    .accentColor(Color(red: 1.0, green: 0.5, blue: 0.1))
                            }
                            
                            // Looking For
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Ich suche nach:")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                                    ForEach(UserPreferences.LookingForType.allCases, id: \.self) { type in
                                        LookingForButton(
                                            type: type,
                                            isSelected: lookingFor.contains(type)
                                        ) {
                                            if lookingFor.contains(type) {
                                                lookingFor.remove(type)
                                            } else {
                                                lookingFor.insert(type)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Interests
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Interessen:")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                                    ForEach(availableInterests, id: \.self) { interest in
                                        InterestButton(
                                            interest: interest,
                                            isSelected: selectedInterests.contains(interest)
                                        ) {
                                            if selectedInterests.contains(interest) {
                                                selectedInterests.remove(interest)
                                            } else {
                                                selectedInterests.insert(interest)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
                
                // Apply Button
                VStack {
                    Spacer()
                    
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
                    .background(Color(red: 0.1, green: 0.12, blue: 0.18))
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
                        ageRange = 18...35
                        maxDistance = 10.0
                        selectedInterests.removeAll()
                        lookingFor = [.friends]
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.1))
                }
            }
        }
    }
}

struct LookingForButton: View {
    let type: UserPreferences.LookingForType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: type.icon)
                    .font(.caption)
                
                Text(type.displayName)
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

struct InterestButton: View {
    let interest: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(interest)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(
                    isSelected ?
                    Color(red: 1.0, green: 0.5, blue: 0.1).opacity(0.3) :
                    Color.white.opacity(0.1)
                )
                .foregroundColor(isSelected ? Color(red: 1.0, green: 0.5, blue: 0.1) : .white)
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? Color(red: 1.0, green: 0.5, blue: 0.1) : Color.clear, lineWidth: 1)
                )
        }
    }
}

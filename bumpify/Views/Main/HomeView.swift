import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var nearbyUsers: [BumpifyUser] = []
    @State private var recentMatches: [BumpifyMatch] = []
    @State private var activeHotspots: [BumpifyHotspot] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.12, blue: 0.18).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Stats Cards
                        statsSection
                        
                        // Recent Activity
                        recentActivitySection
                        
                        // Nearby Users Preview
                        nearbyUsersSection
                        
                        // Active Hotspots
                        hotspotsSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
        }
        .onAppear {
            loadMockData()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Willkommen zurück!")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    
                    if let user = authManager.currentUser {
                        Text("Hallo \(user.firstName)! 👋")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                // Profile Image
                Button(action: {}) {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.7))
                        )
                }
            }
        }
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        VStack(spacing: 16) {
            Text("📊 Deine Statistiken")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                StatCard(
                    icon: "person.2.fill",
                    title: "Bumps heute",
                    value: "12",
                    color: Color(red: 1.0, green: 0.4, blue: 0.2)
                )
                
                StatCard(
                    icon: "heart.fill",
                    title: "Neue Matches",
                    value: "3",
                    color: .pink
                )
                
                StatCard(
                    icon: "message.fill",
                    title: "Nachrichten",
                    value: "8",
                    color: .blue
                )
            }
        }
    }
    
    // MARK: - Recent Activity Section
    private var recentActivitySection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("🔥 Letzte Aktivität")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Alle anzeigen") {
                    // Navigate to full activity
                }
                .font(.caption)
                .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.1))
            }
            
            VStack(spacing: 12) {
                ForEach(recentMatches.prefix(3)) { match in
                    RecentActivityCard(match: match)
                }
                
                if recentMatches.isEmpty {
                    EmptyStateCard(
                        icon: "clock.fill",
                        title: "Keine Aktivität",
                        description: "Starte den Bump-Modus, um Aktivitäten zu sehen!"
                    )
                }
            }
        }
    }
    
    // MARK: - Nearby Users Section
    private var nearbyUsersSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("👥 In der Nähe")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(nearbyUsers.count) Personen")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(nearbyUsers.prefix(5)) { user in
                        NearbyUserCard(user: user)
                    }
                }
                .padding(.horizontal, 4)
            }
            
            if nearbyUsers.isEmpty {
                EmptyStateCard(
                    icon: "person.2.slash.fill",
                    title: "Niemand in der Nähe",
                    description: "Aktiviere den Bump-Modus, um andere Nutzer zu finden!"
                )
            }
        }
    }
    
    // MARK: - Hotspots Section
    private var hotspotsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("📍 Aktive Hotspots")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Alle anzeigen") {
                    // Navigate to map
                }
                .font(.caption)
                .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.1))
            }
            
            VStack(spacing: 12) {
                ForEach(activeHotspots.prefix(3)) { hotspot in
                    HotspotCard(hotspot: hotspot)
                }
                
                if activeHotspots.isEmpty {
                    EmptyStateCard(
                        icon: "mappin.slash",
                        title: "Keine Hotspots",
                        description: "Erstelle einen eigenen Hotspot oder warte auf Events in deiner Nähe!"
                    )
                }
            }
        }
    }
    
    // MARK: - Load Mock Data
    private func loadMockData() {
        // Mock nearby users
        nearbyUsers = [
            BumpifyUser(firstName: "Anna", lastName: "Schmidt", email: "anna@test.de", age: 25, interests: ["Musik", "Reisen"]),
            BumpifyUser(firstName: "Max", lastName: "Mueller", email: "max@test.de", age: 28, interests: ["Sport", "Kaffee"]),
            BumpifyUser(firstName: "Lisa", lastName: "Weber", email: "lisa@test.de", age: 24, interests: ["Kunst", "Fotografie"])
        ]
        
        // Mock recent matches
        recentMatches = [
            BumpifyMatch(user: nearbyUsers[0], sharedInterests: ["Musik"]),
            BumpifyMatch(user: nearbyUsers[1], sharedInterests: ["Sport", "Kaffee"])
        ]
        
        // Mock hotspots
        activeHotspots = [
            BumpifyHotspot(
                name: "After Work Drinks",
                description: "Entspannte Runde nach der Arbeit",
                location: BumpifyLocation(latitude: 49.2041, longitude: 7.3066),
                creatorId: UUID(),
                hotspotType: .user,
                startTime: Date(),
                endTime: Date().addingTimeInterval(3600),
                category: .social
            )
        ]
    }
}

// MARK: - Supporting Views
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

struct RecentActivityCard: View {
    let match: BumpifyMatch
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.pink.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "heart.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.pink)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Neues Match mit \(match.user.firstName)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                if !match.sharedInterests.isEmpty {
                    Text("Gemeinsame Interessen: \(match.sharedInterests.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            Spacer()
            
            Text(timeAgoString(from: match.matchedAt))
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct NearbyUserCard: View {
    let user: BumpifyUser
    
    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white.opacity(0.7))
                )
            
            Text(user.firstName)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            if let age = user.age {
                Text("\(age)")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .frame(width: 80)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct HotspotCard: View {
    let hotspot: BumpifyHotspot
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(hotspot.hotspotType.color.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: hotspot.hotspotType.icon)
                        .font(.system(size: 18))
                        .foregroundColor(hotspot.hotspotType.color)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(hotspot.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(hotspot.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(hotspot.participantCount)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(hotspot.hotspotType.color)
                
                Text("Teilnehmer")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct EmptyStateCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.3))
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.6))
            
            Text(description)
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

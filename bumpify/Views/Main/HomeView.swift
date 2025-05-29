// HomeView.swift - Ersetze deine bestehende HomeView

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var recentBumps: [RecentBump] = []
    @State private var nearbyHotspots: [Hotspot] = []
    @State private var showingProfile = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with Welcome Message
                        headerView
                        
                        // Quick Stats
                        quickStatsView
                        
                        // Recent Bumps Section
                        recentBumpsSection
                        
                        // Nearby Hotspots Section
                        nearbyHotspotsSection
                        
                        // Quick Actions
                        quickActionsView
                        
                        Spacer().frame(height: 100) // Tab bar space
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            loadHomeData()
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hallo \(authManager.currentUser?.firstName ?? "User")! 👋")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Bereit für neue Begegnungen?")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: { showingProfile = true }) {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(authManager.currentUser?.initials ?? "U")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    )
            }
        }
    }
    
    // MARK: - Quick Stats
    private var quickStatsView: some View {
        HStack(spacing: 16) {
            StatCard(
                icon: "person.2.fill",
                title: "Bumps heute",
                value: "3",
                color: .orange
            )
            
            StatCard(
                icon: "heart.fill",
                title: "Matches",
                value: "12",
                color: .red
            )
            
            StatCard(
                icon: "location.circle.fill",
                title: "In der Nähe",
                value: "8",
                color: .blue
            )
        }
    }
    
    // MARK: - Recent Bumps Section
    private var recentBumpsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("📍 Letzte Begegnungen")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Alle anzeigen") {
                    // Navigate to all bumps
                }
                .font(.caption)
                .foregroundColor(.orange)
            }
            
            if recentBumps.isEmpty {
                EmptyStateView(
                    icon: "location.slash",
                    title: "Keine Begegnungen",
                    subtitle: "Starte einen Bump, um neue Leute zu treffen!"
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(recentBumps) { bump in
                        RecentBumpCard(bump: bump)
                    }
                }
            }
        }
    }
    
    // MARK: - Nearby Hotspots Section
    private var nearbyHotspotsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🔥 Hotspots in der Nähe")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Karte öffnen") {
                    // Navigate to map
                }
                .font(.caption)
                .foregroundColor(.orange)
            }
            
            if nearbyHotspots.isEmpty {
                EmptyStateView(
                    icon: "map",
                    title: "Keine Hotspots",
                    subtitle: "Erstelle den ersten Hotspot in deiner Nähe!"
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(nearbyHotspots) { hotspot in
                            HotspotCard(hotspot: hotspot)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.horizontal, -16)
            }
        }
    }
    
    // MARK: - Quick Actions
    private var quickActionsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("⚡ Schnellaktionen")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                HomeQuickActionButton(
                    icon: "location.circle.fill",
                    title: "Bump starten",
                    color: .orange
                ) {
                    // Navigate to bump view
                }
                
                HomeQuickActionButton(
                    icon: "plus.circle.fill",
                    title: "Hotspot erstellen",
                    color: .green
                ) {
                    // Navigate to create hotspot
                }
            }
        }
    }
    
    // MARK: - Load Data
    private func loadHomeData() {
        // Mock data for recent bumps
        recentBumps = [
            RecentBump(
                id: "1",
                userName: "Anna Schmidt",
                userInitials: "AS",
                location: "Café Central",
                timestamp: Date().addingTimeInterval(-3600),
                isMatched: true
            ),
            RecentBump(
                id: "2",
                userName: "Max Weber",
                userInitials: "MW",
                location: "Stadtpark",
                timestamp: Date().addingTimeInterval(-7200),
                isMatched: false
            )
        ]
        
        // Mock data for nearby hotspots
        nearbyHotspots = [
            Hotspot(
                name: "After Work Drinks",
                description: "Entspannte Runde nach der Arbeit",
                location: "Murphy's Pub",
                coordinate: BumpCoordinate(latitude: 49.2041, longitude: 7.3066),
                type: .user,
                createdBy: "user1",
                startTime: Date().addingTimeInterval(3600),
                endTime: Date().addingTimeInterval(7200),
                participantIds: ["user1", "user2", "user3"],
                maxParticipants: 8
            ),
            Hotspot(
                name: "Happy Hour",
                description: "20% auf alle Getränke",
                location: "Café Central",
                coordinate: BumpCoordinate(latitude: 49.2035, longitude: 7.3070),
                type: .business,
                createdBy: "business1",
                startTime: Date(),
                endTime: Date().addingTimeInterval(7200)
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
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct RecentBump: Identifiable {
    let id: String
    let userName: String
    let userInitials: String
    let location: String
    let timestamp: Date
    let isMatched: Bool
}

struct RecentBumpCard: View {
    let bump: RecentBump
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(bump.isMatched ? Color.green : Color.gray)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(bump.userInitials)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(bump.userName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(bump.location)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(timeAgo(from: bump.timestamp))
                    .font(.caption)
                    .foregroundColor(.gray)
                
                if bump.isMatched {
                    Text("Match! 💖")
                        .font(.caption)
                        .foregroundColor(.green)
                } else {
                    Text("Warten...")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        
        if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d"
        }
    }
}

struct HotspotCard: View {
    let hotspot: Hotspot
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: hotspot.type.icon)
                    .font(.title3)
                    .foregroundColor(hotspot.type.color)
                
                Spacer()
                
                Text("\(hotspot.participantCount)/\(hotspot.maxParticipants ?? 99)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(hotspot.name)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .lineLimit(1)
            
            Text(hotspot.location)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(1)
            
            Spacer()
            
            Button("Beitreten") {
                // Join hotspot action
            }
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(hotspot.type.color)
            .cornerRadius(8)
        }
        .frame(width: 140, height: 120)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct HomeQuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthenticationManager())
}

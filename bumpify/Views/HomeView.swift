import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Hey! 👋")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                
                                Text("Entdecke neue Verbindungen")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Image(systemName: "bell")
                                    .font(.title2)
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding()
                        
                        // Status Card
                        VStack(spacing: 15) {
                            HStack {
                                Text("Bump Status")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Circle()
                                    .fill(appState.bumpMode ? Color.green : Color.gray)
                                    .frame(width: 12, height: 12)
                                
                                Text(appState.bumpMode ? "Aktiv" : "Inaktiv")
                                    .font(.caption)
                                    .foregroundColor(appState.bumpMode ? .green : .gray)
                            }
                            
                            if appState.bumpMode {
                                HStack(spacing: 20) {
                                    StatItem(title: "Bumps heute", value: "12")
                                    StatItem(title: "In der Nähe", value: "\(appState.nearbyUsers.count)")
                                    StatItem(title: "Matches", value: "3")
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // Recent Bumps
                        if !appState.nearbyUsers.isEmpty {
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Text("Letzte Begegnungen")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal)
                                    
                                    Spacer()
                                }
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(appState.nearbyUsers.prefix(5)) { user in
                                            BumpCard(user: user)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        // Events
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("Events in der Nähe")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                Spacer()
                            }
                            
                            VStack(spacing: 10) {
                                EventCard(
                                    title: "After Work Drinks",
                                    location: "Murphy's Pub",
                                    time: "18:00 - 22:00",
                                    participants: 12
                                )
                                
                                EventCard(
                                    title: "Morning Coffee",
                                    location: "Café Central",
                                    time: "08:00 - 10:00",
                                    participants: 8
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
    }
}

// Helper Views
struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.orange)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct BumpCard: View {
    let user: User
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: user.profileImage)
                .font(.system(size: 40))
                .foregroundColor(.orange)
                .frame(width: 60, height: 60)
                .background(Color.white.opacity(0.1))
                .clipShape(Circle())
            
            Text(user.name)
                .font(.headline)
                .foregroundColor(.white)
            
            Text("\(user.age) Jahre")
                .font(.caption)
                .foregroundColor(.gray)
            
            Text("vor 2 Min")
                .font(.caption)
                .foregroundColor(.orange)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .frame(width: 120)
    }
}

struct EventCard: View {
    let title: String
    let location: String
    let time: String
    let participants: Int
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "calendar.circle.fill")
                .font(.title)
                .foregroundColor(.orange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(location)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(time)
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            
            Spacer()
            
            VStack {
                Text("\(participants)")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                Text("Teilnehmer")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

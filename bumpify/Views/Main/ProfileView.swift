import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingSettings = false
    @State private var showingPremium = false
    @State private var showingEditProfile = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        HStack {
                            Text("Profil")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: { showingSettings = true }) {
                                Image(systemName: "gearshape.fill")
                                    .font(.title2)
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Profile Card
                        ProfileCardView(onEdit: { showingEditProfile = true })
                        
                        // Premium Banner
                        PremiumBannerView(onTap: { showingPremium = true })
                        
                        // Stats Section
                        ProfileStatsView()
                        
                        // Recent Activity
                        RecentActivityView()
                        
                        // Quick Actions
                        QuickActionsProfileView()
                    }
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingPremium) {
            PremiumView()
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
    }
}

struct ProfileCardView: View {
    let onEdit: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Profile Image and Edit Button
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                        .background(Color.black)
                        .clipShape(Circle())
                }
                .offset(x: 45, y: 45)
            }
            
            // User Info
            VStack(spacing: 8) {
                Text("Max Mustermann")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("28 Jahre • Zweibrücken")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("Hier für neue Freundschaften und interessante Gespräche 😊")
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Interests
            InterestsView(interests: ["Musik", "Reisen", "Fotografie", "Sport", "Café"])
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

struct InterestsView: View {
    let interests: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Meine Interessen")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(interests, id: \.self) { interest in
                    Text(interest)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(15)
                }
            }
        }
    }
}

struct PremiumBannerView: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(Color.yellow.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "crown.fill")
                        .font(.title2)
                        .foregroundColor(.yellow)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bumpify Premium")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Mehr Kontrolle & bessere Matches")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("3,99 € / Monat")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.yellow.opacity(0.1), Color.orange.opacity(0.1)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal)
    }
}

struct ProfileStatsView: View {
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Deine Statistiken")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal)
            
            HStack(spacing: 15) {
                StatCardView(title: "Bumps", value: "127", icon: "location.circle.fill", color: .orange)
                StatCardView(title: "Matches", value: "23", icon: "heart.fill", color: .red)
                StatCardView(title: "Chats", value: "18", icon: "message.fill", color: .blue)
            }
            .padding(.horizontal)
        }
    }
}

struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
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
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct RecentActivityView: View {
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Letzte Aktivität")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Alle anzeigen") {
                    // Show all activity
                }
                .font(.caption)
                .foregroundColor(.orange)
            }
            .padding(.horizontal)
            
            VStack(spacing: 10) {
                ActivityRowView(
                    icon: "location.circle.fill",
                    title: "Bump mit Anna",
                    subtitle: "Café Central",
                    time: "vor 2 Std",
                    color: .orange
                )
                
                ActivityRowView(
                    icon: "heart.fill",
                    title: "Neues Match mit Lisa",
                    subtitle: "Stadtpark",
                    time: "vor 5 Std",
                    color: .red
                )
                
                ActivityRowView(
                    icon: "message.fill",
                    title: "Neue Nachricht von Max",
                    subtitle: "Hey, wie geht's?",
                    time: "vor 1 Tag",
                    color: .blue
                )
            }
            .padding(.horizontal)
        }
    }
}

struct ActivityRowView: View {
    let icon: String
    let title: String
    let subtitle: String
    let time: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(time)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct QuickActionsProfileView: View {
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Schnellzugriff")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                QuickActionCardView(
                    icon: "person.crop.circle.badge.plus",
                    title: "Freunde einladen",
                    subtitle: "Lade deine Freunde zu Bumpify ein",
                    color: .green
                )
                
                QuickActionCardView(
                    icon: "shield.fill",
                    title: "Privatsphäre",
                    subtitle: "Verwalte deine Sichtbarkeit",
                    color: .blue
                )
                
                QuickActionCardView(
                    icon: "questionmark.circle.fill",
                    title: "Hilfe & Support",
                    subtitle: "FAQ und Kontakt",
                    color: .purple
                )
                
                QuickActionCardView(
                    icon: "star.fill",
                    title: "App bewerten",
                    subtitle: "Bewerte uns im App Store",
                    color: .yellow
                )
            }
            .padding(.horizontal)
        }
    }
}

struct QuickActionCardView: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(Color.white.opacity(0.05))
            .cornerRadius(15)
        }
    }
}

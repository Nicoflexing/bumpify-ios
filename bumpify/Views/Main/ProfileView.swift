import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingEditProfile = false
    @State private var showingSettings = false
    @State private var userStats = UserStats()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.12, blue: 0.18).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Header
                        profileHeaderSection
                        
                        // Stats Section
                        statsSection
                        
                        // Profile Info
                        profileInfoSection
                        
                        // Interests Section
                        interestsSection
                        
                        // Settings & Actions
                        settingsSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .onAppear {
            loadUserStats()
        }
    }
    
    // MARK: - Profile Header Section
    private var profileHeaderSection: some View {
        VStack(spacing: 20) {
            // Profile Image
            Button(action: {
                showingEditProfile = true
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.4, blue: 0.2).opacity(0.3),
                                    Color(red: 1.0, green: 0.6, blue: 0.0).opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    if let user = authManager.currentUser {
                        if let profileImage = user.profileImage {
                            // TODO: Load actual image
                            Image(systemName: "person.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.8))
                        } else {
                            Text(user.firstName.prefix(1) + user.lastName.prefix(1))
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Edit indicator
                    Circle()
                        .fill(Color(red: 1.0, green: 0.5, blue: 0.1))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "pencil")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        )
                        .offset(x: 35, y: 35)
                }
            }
            
            // User Info
            if let user = authManager.currentUser {
                VStack(spacing: 8) {
                    Text(user.fullName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    if let age = user.age {
                        Text("\(age) Jahre")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                    
                    if let bio = user.bio, !bio.isEmpty {
                        Text(bio)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                    }
                }
            }
        }
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        VStack(spacing: 16) {
            Text("📊 Meine Statistiken")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                ProfileStatCard(
                    icon: "location.circle.fill",
                    title: "Bumps",
                    value: "\(userStats.totalBumps)",
                    subtitle: "gesamt",
                    color: Color(red: 1.0, green: 0.4, blue: 0.2)
                )
                
                ProfileStatCard(
                    icon: "heart.fill",
                    title: "Matches",
                    value: "\(userStats.totalMatches)",
                    subtitle: "erfolgreich",
                    color: .pink
                )
                
                ProfileStatCard(
                    icon: "message.fill",
                    title: "Chats",
                    value: "\(userStats.activeChats)",
                    subtitle: "aktiv",
                    color: .blue
                )
            }
            
            HStack(spacing: 12) {
                ProfileStatCard(
                    icon: "mappin.circle.fill",
                    title: "Events",
                    value: "\(userStats.eventsCreated)",
                    subtitle: "erstellt",
                    color: .green
                )
                
                ProfileStatCard(
                    icon: "calendar",
                    title: "Tage",
                    value: "\(userStats.daysActive)",
                    subtitle: "aktiv",
                    color: .orange
                )
                
                ProfileStatCard(
                    icon: "star.fill",
                    title: "Level",
                    value: "\(userStats.userLevel)",
                    subtitle: "erreicht",
                    color: .yellow
                )
            }
        }
    }
    
    // MARK: - Profile Info Section
    private var profileInfoSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("ℹ️ Profil-Info")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Bearbeiten") {
                    showingEditProfile = true
                }
                .font(.caption)
                .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.1))
            }
            
            VStack(spacing: 12) {
                if let user = authManager.currentUser {
                    ProfileInfoRow(
                        icon: "person.fill",
                        title: "Name",
                        value: user.fullName
                    )
                    
                    ProfileInfoRow(
                        icon: "envelope.fill",
                        title: "E-Mail",
                        value: user.email
                    )
                    
                    if let age = user.age {
                        ProfileInfoRow(
                            icon: "calendar",
                            title: "Alter",
                            value: "\(age) Jahre"
                        )
                    }
                    
                    ProfileInfoRow(
                        icon: "clock.fill",
                        title: "Mitglied seit",
                        value: memberSinceString(from: user.joinedDate)
                    )
                    
                    ProfileInfoRow(
                        icon: "location.fill",
                        title: "Zuletzt aktiv",
                        value: lastActiveString(from: user.lastSeen)
                    )
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
        }
    }
    
    // MARK: - Interests Section
    private var interestsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("🎯 Interessen")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Bearbeiten") {
                    showingEditProfile = true
                }
                .font(.caption)
                .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.1))
            }
            
            if let user = authManager.currentUser, !user.interests.isEmpty {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(user.interests, id: \.self) { interest in
                        InterestTag(interest: interest)
                    }
                }
            } else {
                EmptyInterestsView()
            }
        }
    }
    
    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(spacing: 16) {
            Text("⚙️ Einstellungen")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                SettingsRow(
                    icon: "gearshape.fill",
                    title: "App-Einstellungen",
                    subtitle: "Benachrichtigungen, Privatsphäre",
                    action: { showingSettings = true }
                )
                
                SettingsRow(
                    icon: "person.crop.circle",
                    title: "Profil bearbeiten",
                    subtitle: "Name, Foto, Bio ändern",
                    action: { showingEditProfile = true }
                )
                
                SettingsRow(
                    icon: "questionmark.circle.fill",
                    title: "Hilfe & Support",
                    subtitle: "FAQs, Kontakt, Feedback",
                    action: { /* Navigate to help */ }
                )
                
                SettingsRow(
                    icon: "star.circle.fill",
                    title: "Premium-Features",
                    subtitle: "Erweiterte Funktionen freischalten",
                    action: { /* Navigate to premium */ }
                )
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
            
            // Logout Button
            Button(action: {
                authManager.logout()
            }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 18))
                    
                    Text("Abmelden")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.8))
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func loadUserStats() {
        // Mock data - in real app, load from API
        userStats = UserStats(
            totalBumps: 47,
            totalMatches: 12,
            activeChats: 5,
            eventsCreated: 3,
            daysActive: 23,
            userLevel: 3
        )
    }
    
    private func memberSinceString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func lastActiveString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Supporting Models
struct UserStats {
    var totalBumps: Int = 0
    var totalMatches: Int = 0
    var activeChats: Int = 0
    var eventsCreated: Int = 0
    var daysActive: Int = 0
    var userLevel: Int = 1
}

// MARK: - Supporting Views
struct ProfileStatCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
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
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct ProfileInfoRow: View {
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
                .multilineTextAlignment(.trailing)
        }
    }
}

struct InterestTag: View {
    let interest: String
    
    var body: some View {
        Text(interest)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 1.0, green: 0.4, blue: 0.2).opacity(0.3),
                        Color(red: 1.0, green: 0.6, blue: 0.0).opacity(0.3)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(red: 1.0, green: 0.5, blue: 0.1).opacity(0.5), lineWidth: 1)
            )
    }
}

struct EmptyInterestsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.circle")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.3))
            
            Text("Keine Interessen hinzugefügt")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
            
            Text("Füge Interessen hinzu, um bessere Matches zu finden!")
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

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.1))
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Placeholder Views
struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.12, blue: 0.18).ignoresSafeArea()
                
                VStack {
                    Text("🔧 Profil bearbeiten")
                        .font(.title)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("Profil-Editor kommt bald!")
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.1))
                }
            }
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.12, blue: 0.18).ignoresSafeArea()
                
                VStack {
                    Text("⚙️ Einstellungen")
                        .font(.title)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("Einstellungen kommen bald!")
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.1))
                }
            }
        }
    }
}

// ProfileView.swift - Ersetze deine ProfileView komplett (ohne doppelte SettingsView)

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingEditProfile = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Profile Header
                        VStack(spacing: 20) {
                            // Profile Image
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
                                
                                if let user = authManager.currentUser {
                                    Text(user.initials)
                                        .font(.system(size: 50, weight: .bold))
                                        .foregroundColor(.white)
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            VStack(spacing: 8) {
                                Text(authManager.currentUser?.fullName ?? "Max Mustermann")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("25 Jahre • Zweibrücken")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // Stats
                        HStack(spacing: 30) {
                            StatItem(title: "Bumps", value: "42")
                            StatItem(title: "Matches", value: "12")
                            StatItem(title: "Events", value: "8")
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        
                        // Interests
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("Interessen")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button("Bearbeiten") {
                                    showingEditProfile = true
                                }
                                .font(.caption)
                                .foregroundColor(.orange)
                            }
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                                ForEach(authManager.currentUser?.interests ?? ["Musik", "Reisen", "Sport", "Fotografie"], id: \.self) { interest in
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
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        
                        // Recent Activity
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Letzte Aktivität")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                ActivityItem(
                                    icon: "location.circle.fill",
                                    title: "Neuer Bump",
                                    subtitle: "Anna • vor 2 Stunden",
                                    color: .orange
                                )
                                
                                ActivityItem(
                                    icon: "heart.fill",
                                    title: "Neues Match",
                                    subtitle: "Lisa • gestern",
                                    color: .pink
                                )
                                
                                ActivityItem(
                                    icon: "calendar",
                                    title: "Event besucht",
                                    subtitle: "After Work Drinks • vor 3 Tagen",
                                    color: .blue
                                )
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        
                        // Settings Section
                        VStack(spacing: 15) {
                            ProfileSettingsItem(
                                icon: "gear",
                                title: "Einstellungen",
                                subtitle: "App-Einstellungen anpassen"
                            ) {
                                // Handle settings - removed navigation to SettingsView for now
                            }
                            
                            ProfileSettingsItem(
                                icon: "bell",
                                title: "Benachrichtigungen",
                                subtitle: "Push-Nachrichten verwalten"
                            ) {
                                // Handle notifications
                            }
                            
                            ProfileSettingsItem(
                                icon: "shield",
                                title: "Privatsphäre",
                                subtitle: "Datenschutz-Einstellungen"
                            ) {
                                // Handle privacy
                            }
                            
                            ProfileSettingsItem(
                                icon: "questionmark.circle",
                                title: "Hilfe & Support",
                                subtitle: "FAQ und Kontakt"
                            ) {
                                // Handle help
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        
                        // Logout Button
                        Button(action: {
                            authManager.logout()
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.title3)
                                
                                Text("Abmelden")
                                    .font(.headline)
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        Spacer().frame(height: 50)
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
    }
}

struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct ActivityItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.02))
        .cornerRadius(10)
    }
}

struct ProfileSettingsItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.orange)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white.opacity(0.02))
            .cornerRadius(10)
        }
    }
}

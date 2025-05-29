// ProfileView.swift - Korrigierte Version ohne Fehler

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingEditProfile = false
    @State private var showingSettings = false
    @State private var showingPremium = false
    @State private var animateStats = false
    @State private var isRefreshing = false
    
    var body: some View {
        ZStack {
            // Background - Matching Home/Bump Design
            backgroundGradient
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Pull-to-Refresh Indicator
                    if isRefreshing {
                        refreshIndicator
                    }
                    
                    // Profile Header
                    profileHeaderSection
                    
                    // Stats Cards - Matching Home/Bump
                    statsSection
                    
                    // Premium Banner
                    premiumBannerSection
                    
                    // Interests Section
                    interestsSection
                    
                    // Recent Activity
                    recentActivitySection
                    
                    // Settings Section
                    settingsSection
                    
                    // Logout Button
                    logoutSection
                    
                    // Bottom padding for tab bar
                    Spacer().frame(height: 100)
                }
                .padding(.top, 60)
                .padding(.horizontal, 20)
            }
            .refreshable {
                await performRefresh()
            }
            
            // Floating particles - Matching Home/Bump
            floatingParticles
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            startAnimations()
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingPremium) {
            PremiumView()
        }
    }
    
    // MARK: - Background - Matching Home/Bump
    private var backgroundGradient: some View {
        ZStack {
            Color(red: 0.12, green: 0.16, blue: 0.24)
                .ignoresSafeArea()
            
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.4, blue: 0.2).opacity(0.1),
                    Color.clear,
                    Color(red: 1.0, green: 0.6, blue: 0.0).opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }
    
    // MARK: - Floating Particles - Matching Home/Bump
    private var floatingParticles: some View {
        ForEach(0..<4, id: \.self) { i in
            Circle()
                .fill(Color.orange.opacity(Double.random(in: 0.05...0.15)))
                .frame(width: CGFloat.random(in: 10...18))
                .offset(
                    x: CGFloat.random(in: -150...150),
                    y: CGFloat.random(in: -300...300) + (animateStats ? -15 : 15)
                )
                .animation(
                    Animation.easeInOut(duration: Double.random(in: 5...7))
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.4),
                    value: animateStats
                )
        }
    }
    
    // MARK: - Pull-to-Refresh Indicator
    private var refreshIndicator: some View {
        HStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                .scaleEffect(0.8)
            
            Text("Profil aktualisieren...")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .background(glassBackground)
        .cornerRadius(25)
        .transition(.scale.combined(with: .opacity))
    }
    
    // MARK: - Profile Header Section
    private var profileHeaderSection: some View {
        VStack(spacing: 20) {
            // Settings button in top right
            HStack {
                Spacer()
                
                Button(action: {
                    showingSettings = true
                }) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                        
                        Image(systemName: "gear")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
            }
            
            // Profile Image with gradient and glow
            ZStack {
                // Glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.orange.opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 60,
                            endRadius: 100
                        )
                    )
                    .frame(width: 140, height: 140)
                    .blur(radius: 10)
                    .scaleEffect(animateStats ? 1.1 : 1.0)
                
                // Main profile circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange, Color.red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: Color.orange.opacity(0.4), radius: 15, x: 0, y: 8)
                
                Text(authManager.currentUser?.initials ?? "U")
                    .font(.system(size: 45, weight: .bold))
                    .foregroundColor(.white)
                
                // Edit button
                Button(action: {
                    showingEditProfile = true
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 36, height: 36)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        
                        Image(systemName: "pencil")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.orange)
                    }
                }
                .offset(x: 45, y: 45)
            }
            
            // Name and Info
            VStack(spacing: 8) {
                Text(authManager.currentUser?.fullName ?? "Max Mustermann")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 16) {
                    Label("\(authManager.currentUser?.age ?? 25)", systemImage: "calendar")
                    Label(authManager.currentUser?.location ?? "Zweibrücken", systemImage: "location")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            }
        }
    }
    
    // MARK: - Stats Section - Matching Home/Bump
    private var statsSection: some View {
        HStack(spacing: 16) {
            ProfileStatCard(
                icon: "location.circle.fill",
                title: "Bumps",
                value: "42",
                color: .orange,
                animate: animateStats
            )
            
            ProfileStatCard(
                icon: "heart.fill",
                title: "Matches",
                value: "12",
                color: .pink,
                animate: animateStats
            )
            
            ProfileStatCard(
                icon: "calendar",
                title: "Events",
                value: "8",
                color: .blue,
                animate: animateStats
            )
        }
    }
    
    // MARK: - Premium Banner Section
    private var premiumBannerSection: some View {
        Button(action: {
            showingPremium = true
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.yellow, Color.orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "crown.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Upgrade zu Premium")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Mehr Features für echte Verbindungen")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [Color.yellow.opacity(0.8), Color.orange.opacity(0.6)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Interests Section
    private var interestsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🎯 Deine Interessen")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Bearbeiten") {
                    showingEditProfile = true
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.orange)
            }
            
            if let interests = authManager.currentUser?.interests, !interests.isEmpty {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                    ForEach(interests, id: \.self) { interest in
                        ProfileInterestTag(text: interest) // Umbenannt um Konflikte zu vermeiden
                    }
                }
            } else {
                EmptyInterestsView()
            }
        }
        .padding(20)
        .background(glassBackground)
        .cornerRadius(16)
    }
    
    // MARK: - Recent Activity Section
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📊 Letzte Aktivität")
                .font(.system(size: 20, weight: .bold))
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
        .padding(20)
        .background(glassBackground)
        .cornerRadius(16)
    }
    
    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(spacing: 12) {
            ProfileSettingsItem(
                icon: "bell.fill",
                title: "Benachrichtigungen",
                subtitle: "Push-Nachrichten verwalten",
                color: .blue
            ) {
                // Handle notifications
            }
            
            ProfileSettingsItem(
                icon: "shield.fill",
                title: "Privatsphäre",
                subtitle: "Datenschutz-Einstellungen",
                color: .green
            ) {
                // Handle privacy
            }
            
            ProfileSettingsItem(
                icon: "questionmark.circle.fill",
                title: "Hilfe & Support",
                subtitle: "FAQ und Kontakt",
                color: .purple
            ) {
                // Handle help
            }
            
            ProfileSettingsItem(
                icon: "info.circle.fill",
                title: "Über Bumpify",
                subtitle: "Version 1.0.0",
                color: .gray
            ) {
                // Handle about
            }
        }
    }
    
    // MARK: - Logout Section
    private var logoutSection: some View {
        Button(action: {
            authManager.logout()
        }) {
            HStack(spacing: 12) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 18, weight: .semibold))
                
                Text("Abmelden")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.red.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Glass Background
    private var glassBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThinMaterial)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
    
    // MARK: - Helper Functions
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 1.2)) {
            animateStats = true
        }
    }
    
    @MainActor
    private func performRefresh() async {
        isRefreshing = true
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Refresh profile data
        // authManager.refreshProfile()
        
        isRefreshing = false
    }
}

// MARK: - Profile Stat Card - Matching Home/Bump design
struct ProfileStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let animate: Bool
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
                    .scaleEffect(isAnimating ? 1.15 : 1.0)
            }
            
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(profileStatGlassBackground)
        .cornerRadius(16)
        .onAppear {
            if animate {
                withAnimation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                        .delay(0.2)
                ) {
                    isAnimating = true
                }
            }
        }
    }
    
    private var profileStatGlassBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThinMaterial)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}

// MARK: - Interest Tag (Umbenannt um Konflikte zu vermeiden)
struct ProfileInterestTag: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.orange)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.orange.opacity(0.2))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Empty Interests View
struct EmptyInterestsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tag")
                .font(.system(size: 30))
                .foregroundColor(.white.opacity(0.3))
            
            Text("Keine Interessen hinzugefügt")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            Text("Bearbeite dein Profil, um Interessen hinzuzufügen")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 20)
    }
}

// MARK: - Activity Item
struct ActivityItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.03))
        )
    }
}

// MARK: - Profile Settings Item
struct ProfileSettingsItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(16)
            .background(profileSettingsGlassBackground)
            .cornerRadius(12)
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0) { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        } perform: {}
    }
    
    private var profileSettingsGlassBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.ultraThinMaterial)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(isPressed ? 0.08 : 0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationManager())
}

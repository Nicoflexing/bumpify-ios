import SwiftUI

// MARK: - Main App Entry Point
@main
struct BumpifyApp: App {
    @StateObject private var authManager = AuthenticationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Content View with Flow Logic
struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showSplashScreen = true
    
    var body: some View {
        ZStack {
            if showSplashScreen {
                SplashScreenView()
                    .transition(.opacity)
            } else {
                mainContent
                    .transition(.opacity)
            }
        }
        .onAppear {
            // Show splash screen for 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showSplashScreen = false
                }
            }
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        if authManager.isAuthenticated {
            // User is logged in -> Show main app
            MainTabView()
        } else if authManager.hasCompletedOnboarding {
            // User completed onboarding but not logged in -> Show login
            AuthenticationView()
        } else {
            // First time user -> Show onboarding
            OnboardingView()
        }
    }
}

// MARK: - Splash Screen
struct SplashScreenView: View {
    @State private var animateLogo = false
    @State private var animateText = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 0.05, green: 0.05, blue: 0.1), location: 0.0),
                    .init(color: Color(red: 0.1, green: 0.1, blue: 0.15), location: 0.5),
                    .init(color: Color(red: 0.05, green: 0.05, blue: 0.1), location: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Logo
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.4, blue: 0.2).opacity(0.4),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 40,
                                endRadius: 100
                            )
                        )
                        .frame(width: 140, height: 140)
                        .scaleEffect(animateLogo ? 1.2 : 1.0)
                        .opacity(animateLogo ? 0.8 : 0.4)
                    
                    // Main logo circle
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
                        .frame(width: 100, height: 100)
                        .shadow(color: Color(red: 1.0, green: 0.4, blue: 0.2).opacity(0.5), radius: 25, x: 0, y: 12)
                        .scaleEffect(animateLogo ? 1.0 : 0.8)
                    
                    // Logo icon
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 45, weight: .medium))
                        .foregroundColor(.white)
                        .scaleEffect(animateLogo ? 1.0 : 0.8)
                }
                
                // App Name
                VStack(spacing: 8) {
                    Text("bumpify")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.4, blue: 0.2),
                                    Color(red: 1.0, green: 0.6, blue: 0.0)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .opacity(animateText ? 1.0 : 0.0)
                        .offset(y: animateText ? 0 : 20)
                    
                    Text("Echte Menschen, echte Begegnungen")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .opacity(animateText ? 1.0 : 0.0)
                        .offset(y: animateText ? 0 : 20)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateLogo = true
            }
            
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                animateText = true
            }
        }
    }
}

// MARK: - Main Tab View (Placeholder)
struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            BumpView()
                .tabItem {
                    Image(systemName: "location.circle.fill")
                    Text("Bump")
                }
                .tag(1)
            
            MapView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Karte")
                }
                .tag(2)
            
            MessagesView()
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Chats")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profil")
                }
                .tag(4)
        }
        .accentColor(Color(red: 1.0, green: 0.5, blue: 0.1))
    }
}

// MARK: - Placeholder Views
struct HomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.12, blue: 0.18).ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text("🏠 Home")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Willkommen bei Bumpify!")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 20) {
                        FeatureCard(
                            icon: "person.2.fill",
                            title: "Aktive Bumps",
                            value: "3",
                            color: Color(red: 1.0, green: 0.4, blue: 0.2)
                        )
                        
                        FeatureCard(
                            icon: "message.fill",
                            title: "Neue Matches",
                            value: "2",
                            color: Color.blue
                        )
                        
                        FeatureCard(
                            icon: "building.2.fill",
                            title: "Business Angebote",
                            value: "5",
                            color: Color.green
                        )
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                }
                .padding(.top, 40)
            }
        }
    }
}

struct BumpView: View {
    @State private var isBumpActive = false
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.12, blue: 0.18).ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Text("⚡ Bump Modus")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Bump Visualization
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
                        }
                        
                        // Center button
                        Button(action: {
                            withAnimation(.spring()) {
                                isBumpActive.toggle()
                            }
                        }) {
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
                                    .frame(width: 120, height: 120)
                                    .scaleEffect(pulseScale)
                                    .shadow(
                                        color: isBumpActive ?
                                        Color(red: 1.0, green: 0.4, blue: 0.2).opacity(0.5) :
                                        .clear,
                                        radius: 20
                                    )
                                
                                Image(systemName: isBumpActive ? "pause.fill" : "play.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                            }
                        }
                        .onAppear {
                            startPulseAnimation()
                        }
                    }
                    .frame(height: 300)
                    
                    Spacer()
                    
                    Text(isBumpActive ? "Bump ist aktiv!" : "Tippe zum Starten")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 40)
            }
        }
    }
    
    private func startPulseAnimation() {
        withAnimation(
            Animation.easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
        ) {
            pulseScale = isBumpActive ? 1.1 : 1.0
        }
    }
}

struct MapView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.12, blue: 0.18).ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text("🗺️ Karte")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Hotspots und Events in deiner Nähe")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    // Placeholder for map
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 300)
                        .overlay(
                            VStack {
                                Image(systemName: "map")
                                    .font(.system(size: 60))
                                    .foregroundColor(.white.opacity(0.6))
                                
                                Text("Karte wird geladen...")
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        )
                        .padding(.horizontal, 32)
                    
                    Spacer()
                }
                .padding(.top, 40)
            }
        }
    }
}

struct MessagesView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.12, blue: 0.18).ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text("💬 Chats")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Deine Matches und Unterhaltungen")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    Image(systemName: "message.circle")
                        .font(.system(size: 80))
                        .foregroundColor(.white.opacity(0.3))
                    
                    Text("Noch keine Chats")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("Starte den Bump-Modus, um Menschen in deiner Nähe zu finden!")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Spacer()
                }
                .padding(.top, 40)
            }
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.12, blue: 0.18).ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text("👤 Profil")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    // Profile Info
                    VStack(spacing: 16) {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white.opacity(0.6))
                            )
                        
                        if let user = authManager.currentUser {
                            Text(user.fullName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(user.email)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    Spacer()
                    
                    // Logout Button
                    Button(action: {
                        authManager.logout()
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Abmelden")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                }
                .padding(.top, 40)
            }
        }
    }
}

// MARK: - Helper Components
struct FeatureCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

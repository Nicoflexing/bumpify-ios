import SwiftUI

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
            if authManager.hasCompletedProfileSetup {
                MainTabView()
            } else {
                ProfileSetupView()
            }
        } else if authManager.hasCompletedOnboarding {
            AuthenticationView()
        } else {
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
                ZStack {
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
                    
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 45, weight: .medium))
                        .foregroundColor(.white)
                        .scaleEffect(animateLogo ? 1.0 : 0.8)
                }
                
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

// MARK: - Profile Setup Placeholder
struct ProfileSetupView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.12, blue: 0.18).ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("🎉 Profil einrichten")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Vervollständige dein Profil, um die besten Matches zu finden!")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 80))
                    .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.1))
                
                Text("Profil-Setup kommt bald!")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.7))
                
                if let user = authManager.currentUser {
                    VStack(spacing: 8) {
                        Text("Eingeloggt als:")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text(user.fullName)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 40)
                }
                
                Spacer()
                
                Button(action: {
                    authManager.completeProfileSetup()
                }) {
                    HStack {
                        Text("Überspringen")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.4, blue: 0.2),
                                Color(red: 1.0, green: 0.6, blue: 0.0)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                .padding(.horizontal, 32)
            }
            .padding(.top, 60)
        }
    }
}

// MARK: - Main Tab View
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

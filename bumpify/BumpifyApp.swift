// BumpifyApp.swift - Komplett Saubere Version

import SwiftUI

@main
struct BumpifyApp: App {
    @StateObject private var authManager = AuthenticationManager()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authManager)
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Root View
struct RootView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showSplash = true
    
    var body: some View {
        Group {
            if showSplash {
                SplashView()
            } else {
                if authManager.isAuthenticated {
                    if !authManager.hasCompletedOnboarding {
                        OnboardingView()
                    } else if !authManager.hasCompletedProfileSetup {
                        ProfileSetupScreen()
                    } else {
                        MainAppView()
                    }
                } else {
                    LoginScreen()
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showSplash = false
                }
            }
        }
    }
}

// MARK: - Splash View
struct SplashView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange, Color.red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "location.circle.fill")
                            .font(.system(size: 45))
                            .foregroundColor(.white)
                    )
                
                Text("bumpify")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.orange, Color.red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("Echte Menschen, echte Begegnungen")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Login Screen
struct LoginScreen: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var email = "test@bumpify.com"
    @State private var password = "123456"
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    Spacer().frame(height: 60)
                    
                    // Logo
                    VStack(spacing: 16) {
                        Text("bumpify")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.orange, Color.red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Verbinde dich mit Menschen um dich herum")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Login Form
                    VStack(spacing: 20) {
                        TextField("E-Mail", text: $email)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                        
                        SecureField("Passwort", text: $password)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        
                        Button(action: {
                            authManager.login(email: email, password: password)
                        }) {
                            HStack {
                                if authManager.isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Anmelden")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.orange, Color.red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                        .disabled(authManager.isLoading)
                        
                        Button("Registrieren") {
                            authManager.signUp(firstName: "New", lastName: "User", email: email, password: password)
                        }
                        .foregroundColor(.orange)
                        .disabled(authManager.isLoading)
                    }
                    .padding(.horizontal, 32)
                    
                    // Debug Info
                    VStack(spacing: 8) {
                        Text("🐛 Debug Status")
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        VStack(spacing: 4) {
                            HStack {
                                Text("Authenticated:")
                                Spacer()
                                Text(authManager.isAuthenticated ? "✅" : "❌")
                            }
                            
                            HStack {
                                Text("Onboarding:")
                                Spacer()
                                Text(authManager.hasCompletedOnboarding ? "✅" : "❌")
                            }
                            
                            HStack {
                                Text("Profile Setup:")
                                Spacer()
                                Text(authManager.hasCompletedProfileSetup ? "✅" : "❌")
                            }
                            
                            HStack {
                                Text("Current User:")
                                Spacer()
                                Text(authManager.currentUser?.firstName ?? "None")
                            }
                        }
                        .font(.caption2)
                        .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                    .padding(.horizontal, 32)
                    
                    Spacer().frame(height: 50)
                }
            }
        }
    }
}

// MARK: - Profile Setup Screen
struct ProfileSetupScreen: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Text("🎉 Profil erstellen")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Vervollständige dein Profil für die besten Matches!")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 80))
                    .foregroundColor(.orange)
                
                Text("Hier kommt das Profil-Setup!")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                if let user = authManager.currentUser {
                    VStack(spacing: 8) {
                        Text("Willkommen,")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text(user.fullName)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                }
                
                Spacer()
                
                Button("Profil später vervollständigen") {
                    authManager.completeProfileSetup()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.orange, Color.red],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .padding(.horizontal, 32)
            }
        }
    }
}

// MARK: - Main App View
struct MainAppView: View {
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
        .accentColor(.orange)
    }
}

#Preview {
    RootView()
        .environmentObject(AuthenticationManager())
}

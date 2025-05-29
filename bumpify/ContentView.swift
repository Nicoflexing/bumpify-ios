// ContentView.swift - KOMPLETTE DATEI - alles in einer
import SwiftUI

struct MinimalContentView: View {
    @State private var isLoggedIn = false
    @State private var hasCompletedOnboarding = false
    @State private var bumpMode = false
    
    var body: some View {
        Group {
            if !isLoggedIn {
                // 1. Login Screen
                PerfectLoginView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isLoggedIn = true
                    }
                }
            } else if !hasCompletedOnboarding {
                // 2. Onboarding
                SimpleOnboardingView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        hasCompletedOnboarding = true
                    }
                }
            } else {
                // 3. Hauptapp
                SimpleMainApp(bumpMode: $bumpMode)
            }
        }
    }
}

// MARK: - Simple Login
struct SimpleLoginView: View {
    let onLoginSuccess: () -> Void
    @State private var showRegister = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 0.08, green: 0.08, blue: 0.12), location: 0.0),
                    .init(color: Color(red: 0.04, green: 0.04, blue: 0.08), location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo
                Text("bumpify")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.orange, Color.red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("Verbinde dich mit Menschen um dich herum")
                    .font(.system(size: 16))
                    .foregroundColor(Color.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                // Toggle Buttons - vereinfacht
                HStack(spacing: 0) {
                    Button(action: { showRegister = false }) {
                        Text("Anmelden")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(showRegister ? Color.clear : Color.orange)
                            .cornerRadius(25)
                    }
                    
                    Button(action: { showRegister = true }) {
                        Text("Registrieren")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(!showRegister ? Color.clear : Color.orange)
                            .cornerRadius(25)
                    }
                }
                .padding(.horizontal, 32)
                
                // Simple Form
                VStack(spacing: 20) {
                    SimpleTextField(placeholder: "E-Mail", text: .constant(""))
                    SimpleTextField(placeholder: "Passwort", text: .constant(""), isSecure: true)
                    if showRegister {
                        SimpleTextField(placeholder: "Passwort bestätigen", text: .constant(""), isSecure: true)
                    }
                }
                .padding(.horizontal, 32)
                
                // Continue Button - vereinfacht
                Button(action: onLoginSuccess) {
                    HStack {
                        Text("Continue")
                            .font(.system(size: 16, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.orange)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
        }
    }
}

// MARK: - Simple Onboarding
struct SimpleOnboardingView: View {
    let onComplete: () -> Void
    @State private var currentStep = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 0.08, green: 0.08, blue: 0.12), location: 0.0),
                    .init(color: Color(red: 0.04, green: 0.04, blue: 0.08), location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer().frame(height: 60)
                
                // Progress
                HStack(spacing: 8) {
                    ForEach(0..<4, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(index <= currentStep ? Color.orange : Color.white.opacity(0.3))
                            .frame(width: index <= currentStep ? 40 : 30, height: 4)
                            .animation(.easeInOut(duration: 0.3), value: currentStep)
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Content
                VStack(spacing: 40) {
                    Text("bumpify")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(LinearGradient(colors: [Color.orange, Color.red], startPoint: .leading, endPoint: .trailing))
                    
                    VStack(spacing: 16) {
                        Text(onboardingTitle(for: currentStep))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text(onboardingDescription(for: currentStep))
                            .font(.system(size: 16))
                            .foregroundColor(Color.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 32)
                    
                    // Icon
                    Image(systemName: onboardingIcon(for: currentStep))
                        .font(.system(size: 60))
                        .foregroundColor(onboardingColor(for: currentStep))
                }
                
                Spacer()
                
                // Button - vereinfacht
                Button(action: {
                    if currentStep < 3 {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentStep += 1
                        }
                    } else {
                        onComplete()
                    }
                }) {
                    Text(currentStep == 3 ? "Zum Profil-Setup" : "Weiter")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.orange)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func onboardingTitle(for step: Int) -> String {
        switch step {
        case 0: return "Willkommen bei Bumpify"
        case 1: return "Bluetooth aktivieren"
        case 2: return "Benachrichtigungen"
        case 3: return "Deine Privatsphäre"
        default: return "Willkommen"
        }
    }
    
    private func onboardingDescription(for step: Int) -> String {
        switch step {
        case 0: return "Entdecke Menschen, Orte und Dienstleistungen in deiner Nähe"
        case 1: return "Bumpify nutzt Bluetooth Low Energy, um andere Nutzer in deiner Nähe zu erkennen."
        case 2: return "Erhalte eine Nachricht, wenn du auf jemanden triffst, der ebenfalls Bumpify nutzt"
        case 3: return "Bei Bumpify hast du die volle Kontrolle über deine Daten und wer dich sehen kann."
        default: return "Willkommen bei Bumpify"
        }
    }
    
    private func onboardingIcon(for step: Int) -> String {
        switch step {
        case 0: return "heart.circle.fill"
        case 1: return "bluetooth"
        case 2: return "bell.fill"
        case 3: return "shield.fill"
        default: return "heart.circle.fill"
        }
    }
    
    private func onboardingColor(for step: Int) -> Color {
        switch step {
        case 0: return .orange
        case 1: return .blue
        case 2: return .pink
        case 3: return .green
        default: return .orange
        }
    }
}

// MARK: - Simple Main App
struct SimpleMainApp: View {
    @Binding var bumpMode: Bool
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home
            NavigationView {
                ZStack {
                    Color.black.ignoresSafeArea()
                    VStack(spacing: 20) {
                        Text("🏠 Home")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Willkommen in der App!")
                            .foregroundColor(.gray)
                        
                        Text("Status: \(bumpMode ? "Aktiv" : "Inaktiv")")
                            .foregroundColor(bumpMode ? .green : .gray)
                    }
                }
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)
            
            // Bump
            BumpView()
                .tabItem {
                    Image(systemName: "location.circle.fill")
                    Text("Bump")
                }
                .tag(1)
            
            // Karte
            NavigationView {
                ZStack {
                    Color.black.ignoresSafeArea()
                    Text("🗺️ Karte")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .tabItem {
                Image(systemName: "map.fill")
                Text("Karte")
            }
            .tag(2)
            
            // Chats
            NavigationView {
                ZStack {
                    Color.black.ignoresSafeArea()
                    Text("💬 Chats")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .tabItem {
                Image(systemName: "message.fill")
                Text("Chats")
            }
            .tag(3)
            
            // Profil
            NavigationView {
                ZStack {
                    Color.black.ignoresSafeArea()
                    Text("👤 Profil")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profil")
            }
            .tag(4)
        }
        .accentColor(.orange)
    }
}

// MARK: - Helper Views
struct SimpleTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .foregroundColor(.white)
        .padding()
        .background(Color.clear)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

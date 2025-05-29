// BumpifyApp.swift - Vollständig korrigierte Version ohne Duplikate

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
                        BumpifyProfileSetupScreen()
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

// MARK: - Profile Setup Screen (KORRIGIERT mit neuen Namen)
struct BumpifyProfileSetupScreen: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var currentPage = 0
    
    // Profile data
    @State private var fullName = ""
    @State private var birthDate = Date()
    @State private var city = "Berlin"
    @State private var gender = "Mann"
    @State private var aboutText = ""
    @State private var bumpLine = ""
    @State private var selectedInterests: Set<String> = []
    @State private var hasProfileImage = false
    
    let availableInterests = [
        "Netflix", "Musik", "Basteln", "Filme", "Bücher",
        "Lesen", "Reisen", "Sport", "Kochen"
    ]
    
    let genderOptions = ["Mann", "Frau", "Divers"]
    
    var body: some View {
        ZStack {
            // Background - Exact Figma color
            Color(red: 0.12, green: 0.16, blue: 0.24)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Progress Bar
                progressBarView
                
                // Content Area
                TabView(selection: $currentPage) {
                    // Page 1 - Personal Info
                    BumpifyPersonalInfoPage(
                        fullName: $fullName,
                        birthDate: $birthDate,
                        city: $city,
                        gender: $gender,
                        genderOptions: genderOptions
                    )
                    .tag(0)
                    
                    // Page 2 - About Me
                    BumpifyAboutMePage(
                        aboutText: $aboutText,
                        bumpLine: $bumpLine
                    )
                    .tag(1)
                    
                    // Page 3 - Interests
                    BumpifyInterestsPage(
                        selectedInterests: $selectedInterests,
                        availableInterests: availableInterests
                    )
                    .tag(2)
                    
                    // Page 4 - Profile Image
                    BumpifyProfileImagePage(
                        hasProfileImage: $hasProfileImage
                    )
                    .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Bottom buttons
                bottomButtonsView
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Text("Profil Setup")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
    }
    
    // MARK: - Progress Bar
    private var progressBarView: some View {
        HStack(spacing: 8) {
            ForEach(0..<4, id: \.self) { index in
                Rectangle()
                    .fill(index <= currentPage ? Color(red: 1.0, green: 0.4, blue: 0.2) : Color.white.opacity(0.3))
                    .frame(height: 4)
                    .cornerRadius(2)
                    .animation(.easeInOut(duration: 0.3), value: currentPage)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    // MARK: - Bottom Buttons
    private var bottomButtonsView: some View {
        VStack(spacing: 16) {
            // Navigation buttons
            if currentPage < 3 {
                HStack {
                    if currentPage > 0 {
                        Button("Zurück") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage -= 1
                            }
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Button("Überspringen") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage += 1
                        }
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                }
                .padding(.horizontal, 20)
            }
            
            // Main button
            Button(action: {
                if currentPage < 3 {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage += 1
                    }
                } else {
                    completeProfileSetup()
                }
            }) {
                HStack(spacing: 8) {
                    Text(getButtonText())
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    if currentPage < 3 {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        colors: [Color(red: 1.0, green: 0.4, blue: 0.2), Color(red: 1.0, green: 0.6, blue: 0.0)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(25)
            }
            .disabled(!isCurrentPageValid())
            .opacity(isCurrentPageValid() ? 1.0 : 0.6)
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 40)
    }
    
    // MARK: - Helper Functions
    private func getButtonText() -> String {
        switch currentPage {
        case 0: return "Weiter"
        case 1: return "Weiter"
        case 2: return "Profil erstellen"
        case 3: return "Fertig"
        default: return "Weiter"
        }
    }
    
    private func isCurrentPageValid() -> Bool {
        switch currentPage {
        case 0: return !fullName.isEmpty
        case 1: return true
        case 2: return selectedInterests.count >= 3
        case 3: return true
        default: return true
        }
    }
    
    private func completeProfileSetup() {
        // Update user profile
        if var user = authManager.currentUser {
            let nameParts = fullName.components(separatedBy: " ")
            user.firstName = nameParts.first ?? ""
            user.lastName = nameParts.count > 1 ? nameParts.dropFirst().joined(separator: " ") : ""
            user.bio = aboutText
            user.interests = Array(selectedInterests)
            user.location = city
            
            authManager.currentUser = user
        }
        
        authManager.completeProfileSetup()
    }
}

// MARK: - Profile Setup Pages (mit neuen Namen)
struct BumpifyPersonalInfoPage: View {
    @Binding var fullName: String
    @Binding var birthDate: Date
    @Binding var city: String
    @Binding var gender: String
    let genderOptions: [String]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Persönliche Informationen")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Gebe hier deine persönlichen Daten ein.")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 32) {
                    // Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        TextField("M. Ali", text: $fullName)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                    }
                    
                    // Birth Date Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Geburtsdatum")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        DatePicker("", selection: $birthDate, displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
                            .labelsHidden()
                            .colorScheme(.dark)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                    }
                    
                    // City Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Stadt")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        TextField("Berlin", text: $city)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                    }
                    
                    // Gender Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Geschlecht")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        Menu {
                            ForEach(genderOptions, id: \.self) { option in
                                Button(option) {
                                    gender = option
                                }
                            }
                        } label: {
                            HStack {
                                Text(gender)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 40)
        }
    }
}

struct BumpifyAboutMePage: View {
    @Binding var aboutText: String
    @Binding var bumpLine: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Über mich")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Erzähle anderen etwas über dich.")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 32) {
                    // About Text Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Über dich")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        TextField("Erzähle etwas über dich...", text: $aboutText, axis: .vertical)
                            .lineLimit(3...6)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                    }
                    
                    // Bump Line Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("BumpLine")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        TextField("Deine BumpLine...", text: $bumpLine)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 40)
        }
    }
}

struct BumpifyInterestsPage: View {
    @Binding var selectedInterests: Set<String>
    let availableInterests: [String]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Deine Interessen")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Wähle mindestens 3 Interessen aus.")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach(availableInterests, id: \.self) { interest in
                        Button(action: {
                            if selectedInterests.contains(interest) {
                                selectedInterests.remove(interest)
                            } else {
                                selectedInterests.insert(interest)
                            }
                        }) {
                            Text(interest)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(selectedInterests.contains(interest) ? .white : .white.opacity(0.8))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    selectedInterests.contains(interest)
                                    ? Color(red: 1.0, green: 0.4, blue: 0.2)
                                    : Color.white.opacity(0.2)
                                )
                                .cornerRadius(20)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 40)
        }
    }
}

struct BumpifyProfileImagePage: View {
    @Binding var hasProfileImage: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Profilbild")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Füge ein Foto hinzu (optional).")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 160, height: 160)
                    
                    Image(systemName: "camera.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                    
                    Button(action: {
                        hasProfileImage.toggle()
                    }) {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "plus")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                            )
                    }
                    .offset(x: 60, y: 60)
                }
                
                Text("Ein Foto erhöht deine Chancen um 70%")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(.top, 40)
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
            
            MapView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Karte")
                }
                .tag(1)
            
            BumpView()
                .tabItem {
                    Image(systemName: "location.circle.fill")
                    Text("Bump")
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

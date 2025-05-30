// ModernProfileSetupView.swift - Exakt wie HomeView Design
// Ersetze deine bestehende ProfileSetupView.swift komplett mit diesem Code

import SwiftUI

struct ModernProfileSetupView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var currentPage = 0
    @State private var animateElements = false
    
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
        "Lesen", "Reisen", "Sport", "Kochen", "Gaming",
        "Fotografie", "Kunst", "Tech", "Design", "Tanzen"
    ]
    
    let genderOptions = ["Mann", "Frau", "Divers"]
    
    var body: some View {
        ZStack {
            // Exakt gleicher Hintergrund wie HomeView
            backgroundGradient
            
            VStack(spacing: 0) {
                // Header wie HomeView
                headerView
                
                // Progress Bar wie HomeView
                progressBarView
                
                // Content Area
                TabView(selection: $currentPage) {
                    // Profile Page 1 - Personal Info
                    PersonalInfoPage()
                        .tag(0)
                    
                    // Profile Page 2 - About Me
                    AboutMePage()
                        .tag(1)
                    
                    // Profile Page 3 - Interests
                    InterestsPage()
                        .tag(2)
                    
                    // Profile Page 4 - Profile Image
                    ProfileImagePage()
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Bottom Navigation wie HomeView
                bottomNavigationView
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    // MARK: - Background (exakt wie HomeView)
    private var backgroundGradient: some View {
        ZStack {
            // Base dark background
            Color(red: 0.12, green: 0.16, blue: 0.24)
                .ignoresSafeArea()
            
            // Gradient overlay wie HomeView
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
            
            // Floating particles wie HomeView
            floatingParticles
        }
    }
    
    // MARK: - Floating Particles (exakt wie HomeView)
    private var floatingParticles: some View {
        ForEach(0..<6, id: \.self) { i in
            Circle()
                .fill(Color.orange.opacity(Double.random(in: 0.05...0.15)))
                .frame(width: CGFloat.random(in: 15...25))
                .offset(
                    x: CGFloat.random(in: -150...150),
                    y: CGFloat.random(in: -300...300) + (animateElements ? -20 : 20)
                )
                .animation(
                    Animation.easeInOut(duration: Double.random(in: 4...6))
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.3),
                    value: animateElements
                )
        }
    }
    
    // MARK: - Header (wie HomeView)
    private var headerView: some View {
        HStack {
            Text("👤 Profil Setup")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Text("Schritt \(currentPage + 1) von 4")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
    }
    
    // MARK: - Progress Bar (wie HomeView)
    private var progressBarView: some View {
        HStack(spacing: 8) {
            ForEach(0..<4, id: \.self) { index in
                Rectangle()
                    .fill(index <= currentPage ?
                          LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing) :
                          LinearGradient(colors: [.white.opacity(0.2)], startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(height: 4)
                    .cornerRadius(2)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentPage)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    // MARK: - Bottom Navigation (wie HomeView)
    private var bottomNavigationView: some View {
        VStack(spacing: 16) {
            // Back/Skip buttons
            if currentPage > 0 || currentPage < 3 {
                HStack {
                    if currentPage > 0 {
                        Button("Zurück") {
                            withAnimation(.spring()) {
                                currentPage -= 1
                            }
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    if currentPage < 3 {
                        Button("Überspringen") {
                            withAnimation(.spring()) {
                                currentPage += 1
                            }
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Main button
            Button(action: {
                if currentPage < 3 {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        currentPage += 1
                    }
                } else {
                    completeProfileSetup()
                }
            }) {
                HStack(spacing: 12) {
                    Text(getButtonText())
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Image(systemName: currentPage == 3 ? "checkmark" : "arrow.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color.orange, Color.red],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: Color.orange.opacity(0.4), radius: 12, x: 0, y: 6)
            }
            .disabled(!isCurrentPageValid())
            .opacity(isCurrentPageValid() ? 1.0 : 0.6)
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Glass Background (wie HomeView)
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
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 1.0)) {
            animateElements = true
        }
    }
    
    // MARK: - Profile Pages
    
    @ViewBuilder
    private func PersonalInfoPage() -> some View {
        ScrollView {
            VStack(spacing: 40) {
                Spacer().frame(height: 40)
                
                // Title Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Persönliche Informationen")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Gebe hier deine persönlichen Daten ein")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                
                // Form Fields (wie HomeView Cards)
                VStack(spacing: 20) {
                    // Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        TextField("Max Mustermann", text: $fullName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(glassBackground)
                    }
                    
                    // Birth Date Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Geburtsdatum")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        DatePicker("", selection: $birthDate, displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
                            .labelsHidden()
                            .colorScheme(.dark)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(glassBackground)
                    }
                    
                    // City Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Stadt")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        HStack(spacing: 12) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.6))
                            
                            TextField("Berlin", text: $city)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(glassBackground)
                    }
                    
                    // Gender Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Geschlecht")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Menu {
                            ForEach(genderOptions, id: \.self) { option in
                                Button(option) {
                                    gender = option
                                }
                            }
                        } label: {
                            HStack {
                                Text(gender)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(glassBackground)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer().frame(height: 100)
            }
        }
    }
    
    @ViewBuilder
    private func AboutMePage() -> some View {
        ScrollView {
            VStack(spacing: 40) {
                Spacer().frame(height: 40)
                
                // Title Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Über mich")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Erzähle anderen etwas über dich")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                
                // Form Fields (wie HomeView Cards)
                VStack(spacing: 20) {
                    // About Text Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Über dich")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        TextField("Erzähle etwas über dich...", text: $aboutText, axis: .vertical)
                            .lineLimit(3...6)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(glassBackground)
                        
                        HStack {
                            Spacer()
                            Text("\(aboutText.count)/150 Zeichen")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    
                    // Bump Line Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("BumpLine")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        TextField("Deine BumpLine...", text: $bumpLine)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(glassBackground)
                    }
                    
                    // Tip Card (wie HomeView)
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 40, height: 40)
                            
                            Text("!")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tipp: Sei Authentisch")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text("Kurze, persönliche Beschreibungen führen zu 40% mehr Matches")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(Color.orange.opacity(0.15))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 20)
                
                Spacer().frame(height: 100)
            }
        }
    }
    
    @ViewBuilder
    private func InterestsPage() -> some View {
        ScrollView {
            VStack(spacing: 40) {
                Spacer().frame(height: 40)
                
                // Title Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Deine Interessen")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Wähle mindestens 3 Interessen aus")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                
                // Status Info (wie HomeView Cards)
                HStack(spacing: 12) {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.orange)
                    
                    Text("Ausgewählt: \(selectedInterests.count) von max. 5")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(16)
                .background(glassBackground)
                .padding(.horizontal, 20)
                
                // Selected Interests
                if !selectedInterests.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Ausgewählte Interessen")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                            ForEach(Array(selectedInterests).sorted(), id: \.self) { interest in
                                InterestTag(
                                    text: interest,
                                    isSelected: true,
                                    action: {
                                        selectedInterests.remove(interest)
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Available Interests
                VStack(alignment: .leading, spacing: 16) {
                    Text("Vorschläge")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                        ForEach(availableInterests.filter { !selectedInterests.contains($0) }, id: \.self) { interest in
                            InterestTag(
                                text: interest,
                                isSelected: false,
                                action: {
                                    if selectedInterests.count < 5 {
                                        selectedInterests.insert(interest)
                                    }
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer().frame(height: 100)
            }
        }
    }
    
    @ViewBuilder
    private func ProfileImagePage() -> some View {
        ScrollView {
            VStack(spacing: 40) {
                Spacer().frame(height: 40)
                
                // Title Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Profilbild")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Füge ein Foto hinzu (optional)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                
                // Profile Image Area (wie HomeView)
                VStack(spacing: 30) {
                    ZStack {
                        // Main circle with gradient
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.8), Color.blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 160, height: 160)
                            .shadow(color: Color.blue.opacity(0.4), radius: 20, x: 0, y: 8)
                        
                        // Camera icon
                        Image(systemName: "camera.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                        
                        // Plus button
                        Button(action: {
                            hasProfileImage.toggle()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.orange, Color.red],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 50, height: 50)
                                    .shadow(color: Color.orange.opacity(0.4), radius: 10, x: 0, y: 4)
                                
                                Image(systemName: "plus")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .offset(x: 70, y: 70)
                    }
                    
                    // Info Card (wie HomeView)
                    HStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.green)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Erhöhe deine Match-Rate!")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text("Ein Profilbild mit deinem Gesicht erhöht deine Match-Rate um bis zu 70%")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer()
                    }
                    .padding(20)
                    .background(glassBackground)
                    .padding(.horizontal, 20)
                }
                
                Spacer().frame(height: 100)
            }
        }
    }
}

// MARK: - Interest Tag Component (wie HomeView Style)
struct InterestTag: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                    isSelected
                    ? LinearGradient(colors: [Color.orange, Color.red], startPoint: .leading, endPoint: .trailing)
                    : LinearGradient(colors: [Color.white.opacity(0.1)], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.orange : Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: isSelected ? Color.orange.opacity(0.3) : Color.clear, radius: 6, x: 0, y: 2)
        }
    }
}

#Preview {
    ModernProfileSetupView()
        .environmentObject(AuthenticationManager())
}

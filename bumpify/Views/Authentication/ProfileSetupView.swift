// ProfileSetupView.swift - NEUE DATEI ERSTELLEN
// Speichere das in: bumpify/Views/Authentication/ProfileSetupView.swift

import SwiftUI

struct ProfileSetupView: View {
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
                
                // Progress Bar - Exact Figma style
                progressBarView
                
                // Content Area
                TabView(selection: $currentPage) {
                    // Page 1 - Personal Info
                    PersonalInfoPage(
                        fullName: $fullName,
                        birthDate: $birthDate,
                        city: $city,
                        gender: $gender,
                        genderOptions: genderOptions
                    )
                    .tag(0)
                    
                    // Page 2 - About Me
                    AboutMePage(
                        aboutText: $aboutText,
                        bumpLine: $bumpLine
                    )
                    .tag(1)
                    
                    // Page 3 - Interests
                    InterestsPage(
                        selectedInterests: $selectedInterests,
                        availableInterests: availableInterests
                    )
                    .tag(2)
                    
                    // Page 4 - Profile Image
                    ProfileImagePage(
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
        .padding(.top, 60) // Status bar area
    }
    
    // MARK: - Progress Bar
    private var progressBarView: some View {
        HStack(spacing: 8) {
            ForEach(0..<4) { index in
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
            // Skip button (only on first 3 pages)
            if currentPage < 3 {
                HStack {
                    Button("Zurück") {
                        if currentPage > 0 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage -= 1
                            }
                        }
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    
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
                    // Complete profile setup
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
        case 3: return "Weiter"
        default: return "Weiter"
        }
    }
    
    private func isCurrentPageValid() -> Bool {
        switch currentPage {
        case 0: return !fullName.isEmpty
        case 1: return true // Optional fields
        case 2: return selectedInterests.count >= 3
        case 3: return true // Profile image is optional
        default: return true
        }
    }
    
    private func completeProfileSetup() {
        // Update user profile with collected data
        if var user = authManager.currentUser {
            let nameParts = fullName.components(separatedBy: " ")
            user.firstName = nameParts.first ?? ""
            user.lastName = nameParts.count > 1 ? nameParts.dropFirst().joined(separator: " ") : ""
            user.bio = aboutText
            user.interests = Array(selectedInterests)
            user.location = city
            
            authManager.currentUser = user
        }
        
        // Complete the profile setup
        authManager.completeProfileSetup()
    }
}

// MARK: - Page 1: Personal Info
struct PersonalInfoPage: View {
    @Binding var fullName: String
    @Binding var birthDate: Date
    @Binding var city: String
    @Binding var gender: String
    let genderOptions: [String]
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 40)
            
            // Title
            VStack(alignment: .leading, spacing: 16) {
                Text("Persönliche Informationen")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Gebe hier deine persönlichen Daten ein.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            
            Spacer()
                .frame(height: 60)
            
            // Form Fields
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
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
                
                // Birth Date Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Geburtsdatum")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    HStack {
                        DatePicker("", selection: $birthDate, displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
                            .labelsHidden()
                            .colorScheme(.dark)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                }
                
                // City Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Stadt")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    HStack {
                        Image(systemName: "location.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.6))
                        
                        TextField("Berlin", text: $city)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
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
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
}

// MARK: - Page 2: About Me
struct AboutMePage: View {
    @Binding var aboutText: String
    @Binding var bumpLine: String
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 40)
            
            // Title
            VStack(alignment: .leading, spacing: 16) {
                Text("Über mich")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Erzähle anderen Bumpify-Nutzern etwas über dich und was dich ausmacht.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            
            Spacer()
                .frame(height: 60)
            
            // Form Fields
            VStack(spacing: 32) {
                // About Text Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("über dich")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $aboutText)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(minHeight: 120)
                        
                        if aboutText.isEmpty {
                            Text("über dich")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.4))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    
                    HStack {
                        Spacer()
                        Text("\(aboutText.count)/150 Zeichen")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                // Bump Line Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("BumpLine")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $bumpLine)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(minHeight: 80)
                        
                        if bumpLine.isEmpty {
                            Text("füge hier ein kurze Line ein, die bei einem Bump übertragen wird.")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.4))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                }
                
                // Tip Box
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 1.0, green: 0.4, blue: 0.2))
                            .frame(width: 24, height: 24)
                        
                        Text("!")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tipp: Sei Authentisch")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Kurze, persönliche Beschreibungen führen zu 40% mehr Matches als längere Texte")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                }
                .padding(16)
                .background(Color(red: 1.0, green: 0.4, blue: 0.2).opacity(0.15))
                .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
}

// MARK: - Page 3: Interests
struct InterestsPage: View {
    @Binding var selectedInterests: Set<String>
    let availableInterests: [String]
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 40)
            
            // Title
            VStack(alignment: .leading, spacing: 16) {
                Text("Deine Interessen")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Wähle Interessen aus, damit andere Nutzer eine Idee von dir bekommen.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            
            Spacer()
                .frame(height: 40)
            
            // Minimum requirement notice
            HStack(spacing: 8) {
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.2))
                
                Text("Wähle mindestens 3 Interessen aus")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            Spacer()
                .frame(height: 32)
            
            // Selected Interests Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Ausgewählte Interessen")
                    .font(.system(size: 16, weight: .medium))
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
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            
            Spacer()
                .frame(height: 32)
            
            // Available Interests Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Vorschläge")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach(availableInterests.filter { !selectedInterests.contains($0) }, id: \.self) { interest in
                        InterestTag(
                            text: interest,
                            isSelected: false,
                            action: {
                                selectedInterests.insert(interest)
                            }
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
}

// MARK: - Page 4: Profile Image
struct ProfileImagePage: View {
    @Binding var hasProfileImage: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 40)
            
            // Title
            VStack(alignment: .leading, spacing: 16) {
                Text("Profilbild hinzufügen")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Füge hier dein bestes Foto zu deinem Profil hinzu")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            
            Spacer()
                .frame(height: 80)
            
            // Profile Image Area
            VStack(spacing: 24) {
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
                                .fill(Color(red: 1.0, green: 0.4, blue: 0.2))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .offset(x: 60, y: 60)
                }
                
                // Info text
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                    
                    Text("Ein Profilbild mit deinem Gesicht erhöht deine match-rate um bis zu 70%")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
        }
    }
}

// MARK: - Interest Tag Component
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
                .padding(.vertical, 8)
                .background(
                    isSelected
                    ? Color(red: 1.0, green: 0.4, blue: 0.2)
                    : Color.white.opacity(0.2)
                )
                .cornerRadius(20)
        }
    }
}

#Preview {
    ProfileSetupView()
        .environmentObject(AuthenticationManager())
}

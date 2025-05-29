import SwiftUI

struct OnboardingView: View {
    @State private var currentStep = 0
    @State private var animateContent = false
    @EnvironmentObject var authManager: AuthenticationManager
    
    private let totalSteps = 4
    
    var body: some View {
        ZStack {
            // Dark Background
            Color(red: 0.1, green: 0.12, blue: 0.18)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress Bar
                progressBar
                
                Spacer().frame(height: 60)
                
                // Content
                TabView(selection: $currentStep) {
                    // Step 1: Welcome
                    OnboardingStep1()
                        .tag(0)
                    
                    // Step 2: Bluetooth
                    OnboardingStep2()
                        .tag(1)
                    
                    // Step 3: Notifications
                    OnboardingStep3()
                        .tag(2)
                    
                    // Step 4: Privacy
                    OnboardingStep4()
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.6), value: currentStep)
                
                Spacer().frame(height: 40)
                
                // Bottom Buttons
                bottomButtons
                
                Spacer().frame(height: 50)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).delay(0.2)) {
                animateContent = true
            }
        }
    }
    
    // MARK: - Progress Bar
    private var progressBar: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 60)
            
            HStack(spacing: 8) {
                ForEach(0..<totalSteps, id: \.self) { step in
                    Rectangle()
                        .fill(step <= currentStep ?
                              Color(red: 1.0, green: 0.4, blue: 0.2) :
                              Color.white.opacity(0.2))
                        .frame(height: 4)
                        .frame(maxWidth: .infinity)
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
            }
            .padding(.horizontal, 32)
        }
    }
    
    // MARK: - Bottom Buttons
    private var bottomButtons: some View {
        VStack(spacing: 16) {
            // Main Action Button
            Button(action: {
                if currentStep < totalSteps - 1 {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        currentStep += 1
                    }
                } else {
                    // Complete onboarding
                    authManager.completeOnboarding()
                }
            }) {
                HStack(spacing: 12) {
                    Text(currentStep == totalSteps - 1 ? "Zum Profil-Setup" :
                         currentStep == 0 ? "Los geht's" :
                         currentStep == 1 ? "Bluetooth aktivieren" :
                         "Benachrichtigungen erlauben")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    if currentStep < totalSteps - 1 {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
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
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color(red: 1.0, green: 0.4, blue: 0.2).opacity(0.3), radius: 12, x: 0, y: 6)
            }
            .padding(.horizontal, 32)
            
            // Skip Button (nur nicht beim letzten Schritt)
            if currentStep < totalSteps - 1 {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        currentStep = totalSteps - 1
                    }
                }) {
                    Text("Später erinnern")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.6))
                }
                .padding(.horizontal, 32)
            }
        }
    }
}

// MARK: - Step 1: Welcome
struct OnboardingStep1: View {
    @State private var animateIcon = false
    
    var body: some View {
        VStack(spacing: 40) {
            // Icon
            ZStack {
                // Background glow
                Circle()
                    .fill(Color(red: 1.0, green: 0.4, blue: 0.2).opacity(0.2))
                    .frame(width: 120, height: 120)
                    .scaleEffect(animateIcon ? 1.1 : 1.0)
                    .opacity(animateIcon ? 0.8 : 0.4)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animateIcon)
                
                // Main circle
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
                    .frame(width: 80, height: 80)
                    .shadow(color: Color(red: 1.0, green: 0.4, blue: 0.2).opacity(0.4), radius: 20)
                
                // Logo text
                Text("bumpify")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            .onAppear {
                animateIcon = true
            }
            
            // Content
            VStack(spacing: 24) {
                Text("Willkommen bei Bumpify")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Entdecke Menschen, Orte und Dienstleistungen\nin deiner Nähe")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            Spacer().frame(height: 40)
            
            // Feature Cards
            VStack(spacing: 16) {
                OnboardingFeatureCard(
                    icon: "person.2.fill",
                    title: "Echtzeit-Begegnungen",
                    description: "Bumpify erkennt automatisch, wenn du jemanden triffst, der die App nutzt.",
                    color: Color(red: 1.0, green: 0.4, blue: 0.2)
                )
                
                OnboardingFeatureCard(
                    icon: "building.2.fill",
                    title: "Business Bumps",
                    description: "Erhalte Angebote und Infos lokaler Unternehmen in deiner Nähe.",
                    color: Color(red: 1.0, green: 0.6, blue: 0.0)
                )
                
                OnboardingFeatureCard(
                    icon: "info.circle.fill",
                    title: "Service Bumps",
                    description: "Erhalte nützliche Infos aus deiner Nähe, genau wenn du sie brauchst.",
                    color: Color(red: 1.0, green: 0.5, blue: 0.1)
                )
            }
            .padding(.horizontal, 32)
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Step 2: Bluetooth
struct OnboardingStep2: View {
    @State private var animateIcon = false
    
    var body: some View {
        VStack(spacing: 40) {
            // Bluetooth Icon
            ZStack {
                // Pulse rings
                ForEach(0..<3, id: \.self) { ring in
                    Circle()
                        .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                        .frame(width: 80 + CGFloat(ring * 30))
                        .scaleEffect(animateIcon ? 1.2 : 1.0)
                        .opacity(animateIcon ? 0.0 : 0.8)
                        .animation(
                            .easeOut(duration: 2.0)
                                .repeatForever()
                                .delay(Double(ring) * 0.3),
                            value: animateIcon
                        )
                }
                
                // Main bluetooth circle
                Circle()
                    .fill(Color.blue)
                    .frame(width: 80, height: 80)
                    .shadow(color: Color.blue.opacity(0.4), radius: 20)
                
                Image(systemName: "bluetooth")
                    .font(.system(size: 35, weight: .medium))
                    .foregroundColor(.white)
            }
            .onAppear {
                animateIcon = true
            }
            
            // Content
            VStack(spacing: 24) {
                Text("Bluetooth aktivieren")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Bumpify nutzt Bluetooth Low Energy, um andere Nutzer in deiner Nähe zu erkennen.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            Spacer().frame(height: 40)
            
            // Benefits
            VStack(spacing: 20) {
                OnboardingBenefit(
                    icon: "checkmark.circle.fill",
                    title: "Batterieschonend",
                    description: "Bis zu 70% weniger Akkuverbrauch im Vergleich zu GPS",
                    isActive: true
                )
                
                OnboardingBenefit(
                    icon: "checkmark.circle.fill",
                    title: "Funktioniert überall",
                    description: "Auch in Innenräumen und Gebäuden zuverlässig",
                    isActive: true
                )
                
                OnboardingBenefit(
                    icon: "checkmark.circle.fill",
                    title: "Präzise Erkennung",
                    description: "Nur Menschen in deiner unmittelbaren Nähe (ca.10m)",
                    isActive: true
                )
                
                OnboardingBenefit(
                    icon: "exclamationmark.triangle.fill",
                    title: "Achtung für iOS User",
                    description: "aktiviere hier deinen Bumpify Tag um die iOS Beschränkung zu umgehen.",
                    isActive: false
                )
            }
            .padding(.horizontal, 32)
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Step 3: Notifications
struct OnboardingStep3: View {
    @State private var animateIcon = false
    
    var body: some View {
        VStack(spacing: 40) {
            // Notification Icon
            ZStack {
                // Background glow
                Circle()
                    .fill(Color.pink.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .scaleEffect(animateIcon ? 1.1 : 1.0)
                    .opacity(animateIcon ? 0.8 : 0.4)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animateIcon)
                
                // Main circle
                Circle()
                    .fill(Color.pink)
                    .frame(width: 80, height: 80)
                    .shadow(color: Color.pink.opacity(0.4), radius: 20)
                
                Image(systemName: "bell.fill")
                    .font(.system(size: 35, weight: .medium))
                    .foregroundColor(.white)
            }
            .onAppear {
                animateIcon = true
            }
            
            // Content
            VStack(spacing: 24) {
                Text("Benachrichtigungen")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Erhalte eine Nachricht, wenn du auf jemanden triffst, der ebenfalls Bumpify nutzt")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            Spacer().frame(height: 40)
            
            // Example Notification
            VStack(spacing: 24) {
                // Example Badge
                HStack {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Beispiel - Benachrichtigung")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
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
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                // Mock Notification
                HStack(spacing: 16) {
                    // Profile Picture
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.white.opacity(0.6))
                        )
                    
                    // Content
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Neuer Bump! Laura ist in deiner Nähe")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Ihr habt 3 gemeinsame Interessen")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                }
                .padding(20)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            }
            .padding(.horizontal, 32)
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Step 4: Privacy
struct OnboardingStep4: View {
    @State private var animateIcon = false
    
    var body: some View {
        VStack(spacing: 40) {
            // Privacy Icon
            ZStack {
                // Background glow
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .scaleEffect(animateIcon ? 1.1 : 1.0)
                    .opacity(animateIcon ? 0.8 : 0.4)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animateIcon)
                
                // Main circle
                Circle()
                    .fill(Color.green)
                    .frame(width: 80, height: 80)
                    .shadow(color: Color.green.opacity(0.4), radius: 20)
                
                Image(systemName: "shield.fill")
                    .font(.system(size: 35, weight: .medium))
                    .foregroundColor(.white)
            }
            .onAppear {
                animateIcon = true
            }
            
            // Content
            VStack(spacing: 24) {
                Text("Deine Privatsphäre")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Bei Bumpify hast du die volle Kontrolle über deine Daten und wer dich sehen kann.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            Spacer().frame(height: 40)
            
            // Privacy Features
            VStack(spacing: 20) {
                OnboardingBenefit(
                    icon: "checkmark.circle.fill",
                    title: "Anonyme IDs",
                    description: "Wir verwenden rotierende IDs für Privatsphäre und Sicherheit",
                    isActive: true
                )
                
                OnboardingBenefit(
                    icon: "checkmark.circle.fill",
                    title: "Nur mit Zustimmung",
                    description: "Matches entstehen nur, wenn beide Personen zustimmen.",
                    isActive: true
                )
                
                OnboardingBenefit(
                    icon: "checkmark.circle.fill",
                    title: "Jederzeit pausierbar",
                    description: "Du kannst den Bump-Modus jederzeit deaktivieren",
                    isActive: true
                )
            }
            .padding(.horizontal, 32)
            
            Spacer().frame(height: 40)
            
            // Terms text
            VStack(spacing: 8) {
                Text("Durch die Nutzung von Bumpify stimmst du unseren")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 4) {
                    Button(action: {}) {
                        Text("Nutzungsbedingungen")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.1))
                            .underline()
                    }
                    
                    Text("und")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Button(action: {}) {
                        Text("Datenschutzrichtlinien")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.1))
                            .underline()
                    }
                    
                    Text("zu.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 32)
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Helper Components
struct OnboardingFeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(color)
                )
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct OnboardingBenefit: View {
    let icon: String
    let title: String
    let description: String
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(isActive ? .green : .red)
                .frame(width: 24, height: 24)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

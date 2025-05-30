// ModernOnboardingView.swift - Exakt wie HomeView Design
// Ersetze deine bestehende OnboardingView.swift komplett mit diesem Code

import SwiftUI

struct ModernOnboardingView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var currentPage = 0
    @State private var animateElements = false
    
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
                    // Onboarding Page 1 - Welcome
                    WelcomePage()
                        .tag(0)
                    
                    // Onboarding Page 2 - Bluetooth
                    BluetoothPage()
                        .tag(1)
                    
                    // Onboarding Page 3 - Notifications
                    NotificationsPage()
                        .tag(2)
                    
                    // Onboarding Page 4 - Privacy
                    PrivacyPage()
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Bottom Button wie HomeView
                bottomButtonView
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
            Text("🚀 Willkommen")
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
    
    // MARK: - Bottom Button (wie HomeView)
    private var bottomButtonView: some View {
        VStack {
            Spacer()
            
            Button(action: {
                if currentPage < 3 {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        currentPage += 1
                    }
                } else {
                    authManager.completeOnboarding()
                }
            }) {
                HStack(spacing: 12) {
                    Text(getButtonText())
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Image(systemName: "arrow.right")
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
        case 0: return "Los geht's!"
        case 1: return "Bluetooth aktivieren"
        case 2: return "Benachrichtigungen erlauben"
        case 3: return "Zum Profil-Setup"
        default: return "Weiter"
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 1.0)) {
            animateElements = true
        }
    }
}

// MARK: - Onboarding Page 1: Welcome
struct WelcomePage: View {
    @State private var animate = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                Spacer().frame(height: 60)
                
                // Logo Section
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange, Color.red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .shadow(color: Color.orange.opacity(0.4), radius: 20, x: 0, y: 8)
                            .scaleEffect(animate ? 1.1 : 1.0)
                            .animation(
                                Animation.easeInOut(duration: 2.0)
                                    .repeatForever(autoreverses: true),
                                value: animate
                            )
                        
                        Image(systemName: "location.circle.fill")
                            .font(.system(size: 45))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 16) {
                        Text("Willkommen bei Bumpify")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Entdecke Menschen, Orte und Dienstleistungen in deiner Nähe")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
                
                // Feature Cards (wie HomeView Style)
                VStack(spacing: 16) {
                    FeatureCard(
                        icon: "person.2.fill",
                        title: "Echtzeit-Begegnungen",
                        description: "Bumpify erkennt automatisch, wenn du jemanden triffst",
                        color: .orange
                    )
                    
                    FeatureCard(
                        icon: "building.2.fill",
                        title: "Business Bumps",
                        description: "Erhalte Angebote lokaler Unternehmen in deiner Nähe",
                        color: .green
                    )
                    
                    FeatureCard(
                        icon: "info.circle.fill",
                        title: "Service Bumps",
                        description: "Nützliche Infos zur richtigen Zeit am richtigen Ort",
                        color: .blue
                    )
                }
                .padding(.horizontal, 20)
                
                Spacer().frame(height: 100)
            }
        }
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Onboarding Page 2: Bluetooth
struct BluetoothPage: View {
    @State private var animate = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                Spacer().frame(height: 60)
                
                // Bluetooth Icon
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 120, height: 120)
                            .overlay(
                                Circle()
                                    .stroke(Color.blue.opacity(0.4), lineWidth: 2)
                                    .scaleEffect(animate ? 1.2 : 1.0)
                                    .opacity(animate ? 0.0 : 1.0)
                                    .animation(
                                        Animation.easeOut(duration: 2.0)
                                            .repeatForever(),
                                        value: animate
                                    )
                            )
                        
                        Image(systemName: "bluetooth")
                            .font(.system(size: 50, weight: .medium))
                            .foregroundColor(.blue)
                    }
                    
                    VStack(spacing: 16) {
                        Text("Bluetooth aktivieren")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Bumpify nutzt Bluetooth Low Energy für energieeffiziente Erkennung")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                }
                
                // Benefits (wie HomeView Cards)
                VStack(spacing: 16) {
                    BenefitCard(
                        icon: "battery.100",
                        title: "Batterieschonend",
                        description: "Bis zu 70% weniger Akkuverbrauch im Vergleich zu GPS",
                        color: .green
                    )
                    
                    BenefitCard(
                        icon: "building.fill",
                        title: "Funktioniert überall",
                        description: "Auch in Innenräumen und Gebäuden zuverlässig",
                        color: .purple
                    )
                    
                    BenefitCard(
                        icon: "target",
                        title: "Präzise Erkennung",
                        description: "Nur Menschen in deiner unmittelbaren Nähe (ca.10m)",
                        color: .orange
                    )
                }
                .padding(.horizontal, 20)
                
                Spacer().frame(height: 100)
            }
        }
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Onboarding Page 3: Notifications
struct NotificationsPage: View {
    @State private var animate = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                Spacer().frame(height: 60)
                
                // Notification Icon
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(Color.pink.opacity(0.2))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "bell.fill")
                            .font(.system(size: 50, weight: .medium))
                            .foregroundColor(.pink)
                            .rotationEffect(.degrees(animate ? 10 : -10))
                            .animation(
                                Animation.easeInOut(duration: 1.5)
                                    .repeatForever(autoreverses: true),
                                value: animate
                            )
                    }
                    
                    VStack(spacing: 16) {
                        Text("Benachrichtigungen")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Erhalte eine Nachricht, wenn du auf jemanden triffst, der ebenfalls Bumpify nutzt")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                }
                
                // Mock Notification (wie HomeView Cards)
                VStack(spacing: 16) {
                    // Header
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Image(systemName: "location.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                            )
                        
                        Text("Beispiel - Benachrichtigung")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange.opacity(0.4), lineWidth: 1)
                    )
                    
                    // Mock Notification
                    HStack(spacing: 16) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .teal],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                            .overlay(
                                Text("L")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            )
                        
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
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.05))
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 20)
                
                Spacer().frame(height: 100)
            }
        }
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Onboarding Page 4: Privacy
struct PrivacyPage: View {
    @State private var animate = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                Spacer().frame(height: 60)
                
                // Privacy Icon
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "shield.fill")
                            .font(.system(size: 50, weight: .medium))
                            .foregroundColor(.green)
                            .scaleEffect(animate ? 1.1 : 1.0)
                            .animation(
                                Animation.easeInOut(duration: 2.0)
                                    .repeatForever(autoreverses: true),
                                value: animate
                            )
                    }
                    
                    VStack(spacing: 16) {
                        Text("Deine Privatsphäre")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Bei Bumpify hast du die volle Kontrolle über deine Daten und wer dich sehen kann")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                }
                
                // Privacy Features (wie HomeView Cards)
                VStack(spacing: 16) {
                    PrivacyFeatureCard(
                        icon: "key.fill",
                        title: "Anonyme IDs",
                        description: "Wir verwenden rotierende IDs für Privatsphäre und Sicherheit",
                        color: .green
                    )
                    
                    PrivacyFeatureCard(
                        icon: "checkmark.shield.fill",
                        title: "Nur mit Zustimmung",
                        description: "Matches entstehen nur, wenn beide Personen zustimmen",
                        color: .blue
                    )
                    
                    PrivacyFeatureCard(
                        icon: "pause.circle.fill",
                        title: "Jederzeit pausierbar",
                        description: "Du kannst den Bump-Modus jederzeit deaktivieren",
                        color: .orange
                    )
                }
                .padding(.horizontal, 20)
                
                Spacer().frame(height: 100)
            }
        }
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Helper Card Components (wie HomeView Style)

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct BenefitCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 30, height: 30)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct PrivacyFeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    ModernOnboardingView()
        .environmentObject(AuthenticationManager())
}

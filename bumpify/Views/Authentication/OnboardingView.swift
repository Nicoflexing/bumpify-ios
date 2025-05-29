// OnboardingView.swift - Exakt wie Figma Design

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            // Background - Dunkles Blau wie in Figma
            Color(red: 0.12, green: 0.16, blue: 0.24)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Status Bar Area
                Spacer()
                    .frame(height: 44)
                
                // Progress Bar - Exakt wie Figma
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
                
                // Content Area
                TabView(selection: $currentPage) {
                    // Page 1 - Welcome
                    FigmaPage1()
                        .tag(0)
                    
                    // Page 2 - Bluetooth
                    FigmaPage2()
                        .tag(1)
                    
                    // Page 3 - Notifications
                    FigmaPage3()
                        .tag(2)
                    
                    // Page 4 - Privacy
                    FigmaPage4()
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Bottom Button Area
                VStack(spacing: 16) {
                    if currentPage < 3 {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage += 1
                            }
                        }) {
                            HStack(spacing: 8) {
                                Text(getButtonText())
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                if currentPage == 0 {
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
                        .padding(.horizontal, 20)
                        
                        if currentPage > 0 {
                            Button("Später erinnern") {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPage += 1
                                }
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                        }
                    } else {
                        // Final page button
                        Button(action: {
                            authManager.completeOnboarding()
                        }) {
                            Text("Zum Profil-Setup")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
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
                        .padding(.horizontal, 20)
                        
                        // Terms text - Exakt wie Figma
                        VStack(spacing: 4) {
                            HStack {
                                Text("Durch die Nutzung von Bumpify stimmst du unseren ")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.6)) +
                                Text("Nutzungsbedingungen")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.2))
                                    .underline() +
                                Text(" und ")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.6)) +
                                Text("Datenschutzrichtlinien")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.2))
                                    .underline() +
                                Text(" zu.")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }
    
    private func getButtonText() -> String {
        switch currentPage {
        case 0: return "Los geht's"
        case 1: return "Bluetooth aktivieren"
        case 2: return "Benachrichtigungen erlauben"
        default: return "Zum Profil-Setup"
        }
    }
}

// MARK: - Page 1: Welcome - Exakt wie Figma
struct FigmaPage1: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 80)
            
            // Bumpify Logo - Exakt wie Figma
            Image("BumpifyLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 60)
            
            Spacer()
                .frame(height: 60)
            
            // Titel - Exakt wie Figma
            Text("Willkommen bei Bumpify")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Spacer()
                .frame(height: 16)
            
            // Untertitel - Exakt wie Figma
            Text("Entdecke Menschen, Orte und Dienstleistungen in deiner Nähe")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
                .frame(height: 60)
            
            // Feature Cards - Exakt wie Figma
            VStack(spacing: 16) {
                FigmaFeatureCard(
                    icon: "person.2.fill",
                    title: "Echtzeit-Begegnungen",
                    description: "Bumpify erkennt automatisch, wenn du jemanden triffst, der die App nutzt.",
                    iconColor: Color(red: 1.0, green: 0.4, blue: 0.2)
                )
                
                FigmaFeatureCard(
                    icon: "building.2.fill",
                    title: "Business Bumps",
                    description: "Erhalte Angebote und Infos lokaler Unternehmen in deiner Nähe.",
                    iconColor: Color(red: 1.0, green: 0.4, blue: 0.2)
                )
                
                FigmaFeatureCard(
                    icon: "info.circle.fill",
                    title: "Service Bumps",
                    description: "Erhalte nützliche Infos aus deiner Nähe, genau wenn du sie brauchst.",
                    iconColor: Color(red: 1.0, green: 0.4, blue: 0.2)
                )
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Page 2: Bluetooth - Exakt wie Figma
struct FigmaPage2: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 80)
            
            // Bluetooth Icon - Exakt wie Figma
            ZStack {
                Circle()
                    .fill(Color(red: 0.3, green: 0.6, blue: 1.0))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "bluetooth")
                    .font(.system(size: 50, weight: .regular))
                    .foregroundColor(.white)
            }
            
            Spacer()
                .frame(height: 60)
            
            // Titel - Exakt wie Figma
            Text("Bluetooth aktivieren")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Spacer()
                .frame(height: 16)
            
            // Beschreibung - Exakt wie Figma
            Text("Bumpify nutzt Bluetooth Low Energy, um andere Nutzer in deiner Nähe zu erkennen.")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
                .frame(height: 60)
            
            // Benefit Cards - Exakt wie Figma
            VStack(spacing: 16) {
                FigmaBenefitCard(
                    title: "Batterieschonend",
                    description: "Bis zu 70% weniger Akkuverbrauch im Vergleich zu GPS"
                )
                
                FigmaBenefitCard(
                    title: "Funktioniert überall",
                    description: "Auch in Innenräumen und Gebäuden zuverlässig"
                )
                
                FigmaBenefitCard(
                    title: "Präzise Erkennung",
                    description: "Nur Menschen in deiner unmittelbaren Nähe (ca.10m)"
                )
            }
            
            Spacer()
                .frame(height: 40)
            
            // iOS Warning - Exakt wie Figma
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.red)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Achtung für iOS User")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("aktiviere hier deinen Bumpify Tag um die iOS Beschränkung zu umgehen")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
            }
            .padding(16)
            .background(Color.red.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
}

// MARK: - Page 3: Notifications - Exakt wie Figma
struct FigmaPage3: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 80)
            
            // Notification Icon - Exakt wie Figma
            ZStack {
                Circle()
                    .fill(Color(red: 0.9, green: 0.3, blue: 0.5))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "bell.fill")
                    .font(.system(size: 50, weight: .regular))
                    .foregroundColor(.white)
            }
            
            Spacer()
                .frame(height: 60)
            
            // Titel - Exakt wie Figma
            Text("Benachrichtigungen")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Spacer()
                .frame(height: 16)
            
            // Beschreibung - Exakt wie Figma
            Text("Erhalte eine Nachricht, wenn du auf jemanden triffst, der ebenfalls Bumpify nutzt")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
                .frame(height: 60)
            
            // Beispiel Header - Exakt wie Figma
            HStack(spacing: 8) {
                Image("BumpifyLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                
                Text("Beispiel - Benachrichtigung")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(16)
            .background(Color(red: 1.0, green: 0.4, blue: 0.2))
            .cornerRadius(12)
            .padding(.horizontal, 20)
            
            Spacer()
                .frame(height: 16)
            
            // Mock Notification - Exakt wie Figma
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text("L")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Neuer Bump! Laura ist in deiner Nähe")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Ihr habt 3 gemeinsame Interessen")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
            }
            .padding(16)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
}

// MARK: - Page 4: Privacy - Exakt wie Figma
struct FigmaPage4: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 80)
            
            // Privacy Icon - Exakt wie Figma
            ZStack {
                Circle()
                    .fill(Color(red: 0.2, green: 0.8, blue: 0.5))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "shield.fill")
                    .font(.system(size: 50, weight: .regular))
                    .foregroundColor(.white)
            }
            
            Spacer()
                .frame(height: 60)
            
            // Titel - Exakt wie Figma
            Text("Deine Privatsphäre")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Spacer()
                .frame(height: 16)
            
            // Beschreibung - Exakt wie Figma
            Text("Bei Bumpify hast du die volle Kontrolle über deine Daten und wer dich sehen kann.")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
                .frame(height: 60)
            
            // Privacy Features - Exakt wie Figma
            VStack(spacing: 16) {
                FigmaBenefitCard(
                    title: "Anonyme IDs",
                    description: "Wir verwenden rotierende IDs für Privatsphäre und Sicherheit"
                )
                
                FigmaBenefitCard(
                    title: "Nur mit Zustimmung",
                    description: "Matches entstehen nur, wenn beide Personen zustimmen."
                )
                
                FigmaBenefitCard(
                    title: "Jederzeit pausierbar",
                    description: "Du kannst den Bump-Modus jederzeit deaktivieren"
                )
            }
            
            Spacer()
        }
    }
}

// MARK: - Figma Components

struct FigmaFeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon Container - Exakt wie Figma
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
}

struct FigmaBenefitCard: View {
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Checkmark - Exakt wie Figma
            ZStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 24, height: 24)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AuthenticationManager())
}

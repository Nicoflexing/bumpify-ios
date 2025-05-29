// OnboardingView.swift - Mit Logo-Integration
// ERSETZE deine bestehende OnboardingView

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 0.05, green: 0.05, blue: 0.1), location: 0.0),
                    .init(color: Color(red: 0.1, green: 0.1, blue: 0.15), location: 0.5),
                    .init(color: Color(red: 0.05, green: 0.05, blue: 0.1), location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress Bar
                HStack(spacing: 8) {
                    ForEach(0..<4) { index in
                        Rectangle()
                            .fill(index <= currentPage ? Color.orange : Color.gray.opacity(0.3))
                            .frame(height: 4)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                Spacer()
                
                // Content Pages
                TabView(selection: $currentPage) {
                    // Page 1 - Welcome (MIT LOGO!)
                    OnboardingPage1()
                        .tag(0)
                    
                    // Page 2 - Bluetooth
                    OnboardingPage2()
                        .tag(1)
                    
                    // Page 3 - Notifications
                    OnboardingPage3()
                        .tag(2)
                    
                    // Page 4 - Privacy
                    OnboardingPage4()
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                Spacer()
                
                // Bottom Button
                VStack(spacing: 16) {
                    if currentPage < 3 {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage += 1
                            }
                        }) {
                            HStack {
                                Text(getButtonText())
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                if currentPage == 0 {
                                    Image(systemName: "arrow.right")
                                        .font(.headline)
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.orange, Color.red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        
                        if currentPage > 0 {
                            Button("Später erinnern") {
                                // Skip for now
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPage += 1
                                }
                            }
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                        }
                    } else {
                        // Final page button
                        Button(action: {
                            authManager.completeOnboarding()
                        }) {
                            Text("Zum Profil-Setup")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [Color.orange, Color.red],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        
                        // Terms text
                        VStack(spacing: 4) {
                            Text("Durch die Nutzung von Bumpify stimmst du unseren ")
                                .font(.caption)
                                .foregroundColor(.gray) +
                            Text("Nutzungsbedingungen")
                                .font(.caption)
                                .foregroundColor(.orange) +
                            Text(" und ")
                                .font(.caption)
                                .foregroundColor(.gray) +
                            Text("Datenschutzrichtlinien")
                                .font(.caption)
                                .foregroundColor(.orange) +
                            Text(" zu.")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .multilineTextAlignment(.center)
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
        default: return "Weiter"
        }
    }
}

// MARK: - Page 1: Welcome (MIT LOGO-INTEGRATION!)
struct OnboardingPage1: View {
    var body: some View {
        VStack(spacing: 40) {
            // Logo Section - HIER IST DIE LOGO-INTEGRATION!
            VStack(spacing: 20) {
                // ALT: Manueller Text
                // Text("bumpify")
                //     .font(.system(size: 48, weight: .bold))
                //     .foregroundStyle(LinearGradient(...))
                
                // NEU: Logo-Komponente verwenden
                BumpifyLogo(size: .hero, style: .text)
                
                Text("Willkommen bei Bumpify")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Entdecke Menschen, Orte und Dienstleistungen\nin deiner Nähe")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            // Features - bleiben gleich
            VStack(spacing: 24) {
                FeatureRow(
                    icon: "person.2.fill",
                    iconColor: .orange,
                    title: "Echtzeit-Begegnungen",
                    description: "Bumpify erkennt automatisch, wenn du jemanden triffst, der die App nutzt."
                )
                
                FeatureRow(
                    icon: "building.2.fill",
                    iconColor: .orange,
                    title: "Business Bumps",
                    description: "Erhalte Angebote und Infos lokaler Unternehmen in deiner Nähe."
                )
                
                FeatureRow(
                    icon: "info.circle.fill",
                    iconColor: .orange,
                    title: "Service Bumps",
                    description: "Erhalte nützliche Infos aus deiner Nähe, genau wenn du sie brauchst."
                )
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Page 2: Bluetooth (MIT LOGO!)
struct OnboardingPage2: View {
    var body: some View {
        VStack(spacing: 40) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "bluetooth")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 20) {
                Text("Bluetooth aktivieren")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Bumpify nutzt Bluetooth Low Energy, um andere Nutzer in deiner Nähe zu erkennen.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // Benefits
            VStack(spacing: 20) {
                BenefitRow(
                    icon: "checkmark.circle.fill",
                    iconColor: .green,
                    title: "Batterieschonend",
                    description: "Bis zu 70% weniger Akkuverbrauch im Vergleich zu GPS"
                )
                
                BenefitRow(
                    icon: "checkmark.circle.fill",
                    iconColor: .green,
                    title: "Funktioniert überall",
                    description: "Auch in Innenräumen und Gebäuden zuverlässig"
                )
                
                BenefitRow(
                    icon: "checkmark.circle.fill",
                    iconColor: .green,
                    title: "Präzise Erkennung",
                    description: "Nur Menschen in deiner unmittelbaren Nähe (ca.10m)"
                )
                
                // iOS Warning - MIT LOGO!
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title3)
                        .foregroundColor(.red)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Achtung für iOS User")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        HStack {
                            Text("aktiviere hier deinen ")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            // Mini-Logo in der Warnung
                            BumpifyLogo(size: .small, style: .text)
                            
                            Text(" Tag")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Page 3: Notifications (MIT LOGO!)
struct OnboardingPage3: View {
    var body: some View {
        VStack(spacing: 40) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.pink)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "bell.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 20) {
                Text("Benachrichtigungen")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Erhalte eine Nachricht, wenn du auf jemanden triffst, der ebenfalls Bumpify nutzt")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // Example Notification
            VStack(spacing: 20) {
                HStack(spacing: 12) {
                    // Mini-Logo statt "bolt"
                    BumpifyLogo(size: .small, style: .iconOnly)
                    
                    Text("Beispiel - Benachrichtigung")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                    
                    Spacer()
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
                
                // Mock notification
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text("L")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Neuer Bump! Laura ist in deiner Nähe")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Text("Ihr habt 3 gemeinsame Interessen")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
            }
        }        .padding(.horizontal, 20)
    }
}

// MARK: - Page 4: Privacy (MIT LOGO!)
struct OnboardingPage4: View {
    var body: some View {
        VStack(spacing: 40) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "shield.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 20) {
                Text("Deine Privatsphäre")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                VStack(spacing: 8) {
                    Text("Bei ")
                        .font(.body)
                        .foregroundColor(.gray) +
                    Text("Bumpify")
                        .font(.body)
                        .foregroundColor(.orange)
                        .fontWeight(.semibold) +
                    Text(" hast du die volle Kontrolle über deine Daten.")
                        .font(.body)
                        .foregroundColor(.gray)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            }
            
            // Privacy Features
            VStack(spacing: 20) {
                BenefitRow(
                    icon: "checkmark.circle.fill",
                    iconColor: .green,
                    title: "Anonyme IDs",
                    description: "Wir verwenden rotierende IDs für Privatsphäre und Sicherheit"
                )
                
                BenefitRow(
                    icon: "checkmark.circle.fill",
                    iconColor: .green,
                    title: "Nur mit Zustimmung",
                    description: "Matches entstehen nur, wenn beide Personen zustimmen."
                )
                
                BenefitRow(
                    icon: "checkmark.circle.fill",
                    iconColor: .green,
                    title: "Jederzeit pausierbar",
                    description: "Du kannst den Bump-Modus jederzeit deaktivieren"
                )
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Helper Views (bleiben gleich)
struct FeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
}

struct BenefitRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AuthenticationManager())
}

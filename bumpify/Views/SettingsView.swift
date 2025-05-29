import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = true
    @State private var locationEnabled = true
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button("Schließen") {
                            dismiss()
                        }
                        .foregroundColor(.orange)
                        
                        Spacer()
                        
                        Text("Einstellungen")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Spacer for symmetry
                        Text("Schließen")
                            .opacity(0)
                    }
                    .padding()
                    
                    ScrollView {
                        VStack(spacing: 30) {
                            // Account Section
                            SettingsSection(title: "Account") {
                                SettingsRowView(
                                    icon: "person.circle.fill",
                                    title: "Profil bearbeiten",
                                    subtitle: "Name, Bilder, Interessen"
                                ) {}
                                
                                SettingsRowView(
                                    icon: "creditcard.fill",
                                    title: "Zahlungsmethoden",
                                    subtitle: "Premium-Abonnement verwalten"
                                ) {}
                            }
                            
                            // Privacy Section
                            SettingsSection(title: "Privatsphäre & Sicherheit") {
                                SettingsToggleRow(
                                    icon: "bell.fill",
                                    title: "Benachrichtigungen",
                                    subtitle: "Push-Nachrichten erhalten",
                                    isOn: $notificationsEnabled
                                )
                                
                                SettingsToggleRow(
                                    icon: "location.fill",
                                    title: "Standort",
                                    subtitle: "Für Bump-Erkennung erforderlich",
                                    isOn: $locationEnabled
                                )
                                
                                SettingsRowView(
                                    icon: "eye.slash.fill",
                                    title: "Blockierte Nutzer",
                                    subtitle: "Verwaltung blockierter Profile"
                                ) {}
                            }
                            
                            // App Section
                            SettingsSection(title: "App") {
                                SettingsToggleRow(
                                    icon: "moon.fill",
                                    title: "Dark Mode",
                                    subtitle: "Dunkles Design verwenden",
                                    isOn: $darkModeEnabled
                                )
                                
                                SettingsRowView(
                                    icon: "questionmark.circle.fill",
                                    title: "Hilfe & Support",
                                    subtitle: "FAQ und Kontakt"
                                ) {}
                                
                                SettingsRowView(
                                    icon: "doc.text.fill",
                                    title: "Datenschutz",
                                    subtitle: "Unsere Datenschutzrichtlinien"
                                ) {}
                            }
                            
                            // Version Info
                            VStack(spacing: 5) {
                                Text("Bumpify")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("Version 1.0.0")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Text("© 2025 Bumpify")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 20)
                        }
                        .padding()
                    }
                }
            }
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            VStack(spacing: 1) {
                content
            }
            .background(Color.white.opacity(0.05))
            .cornerRadius(15)
            .padding(.horizontal)
        }
    }
}

struct SettingsRowView: View {
    let icon: String
    let title: String
    let subtitle: String?
    let textColor: Color
    let action: () -> Void
    
    init(icon: String, title: String, subtitle: String? = nil, textColor: Color = .white, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.textColor = textColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.orange)
                    .frame(width: 25)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(textColor)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
        }
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String?
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.orange)
                .frame(width: 25)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.white)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(.orange)
        }
        .padding()
    }
}

// SettingsView.swift - Ersetze deine SettingsView komplett

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var notificationsEnabled = true
    @State private var locationEnabled = true
    @State private var bluetoothEnabled = true
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 10) {
                            Image(systemName: "gear")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                            
                            Text("Einstellungen")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding(.top, 20)
                        
                        // App Settings Section
                        VStack(spacing: 15) {
                            SectionHeader(title: "App-Einstellungen")
                            
                            SettingsToggleItem(
                                icon: "bell.fill",
                                title: "Push-Benachrichtigungen",
                                subtitle: "Erhalte Benachrichtigungen für neue Bumps",
                                isOn: $notificationsEnabled,
                                color: .blue
                            )
                            
                            SettingsToggleItem(
                                icon: "location.fill",
                                title: "Standort-Services",
                                subtitle: "Ermöglicht das Finden von Nutzern in der Nähe",
                                isOn: $locationEnabled,
                                color: .green
                            )
                            
                            SettingsToggleItem(
                                icon: "dot.radiowaves.left.and.right",
                                title: "Bluetooth",
                                subtitle: "Für Bump-Erkennung erforderlich",
                                isOn: $bluetoothEnabled,
                                color: .orange
                            )
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        
                        // Privacy Settings Section
                        VStack(spacing: 15) {
                            SectionHeader(title: "Privatsphäre")
                            
                            SettingsNavigationItem(
                                icon: "eye.slash.fill",
                                title: "Sichtbarkeit",
                                subtitle: "Wer kann dich finden",
                                color: .purple
                            ) {
                                // Handle privacy settings
                            }
                            
                            SettingsNavigationItem(
                                icon: "lock.shield.fill",
                                title: "Datenschutz",
                                subtitle: "Deine Daten verwalten",
                                color: .red
                            ) {
                                // Handle data privacy
                            }
                            
                            SettingsNavigationItem(
                                icon: "person.crop.circle.badge.xmark",
                                title: "Blockierte Nutzer",
                                subtitle: "Blockierte Kontakte verwalten",
                                color: .gray
                            ) {
                                // Handle blocked users
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        
                        // Account Section
                        VStack(spacing: 15) {
                            SectionHeader(title: "Account")
                            
                            if let user = authManager.currentUser {
                                HStack(spacing: 15) {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.orange, .red],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Text(String(user.fullName.prefix(1)))
                                                .font(.headline)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(user.fullName)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        Text(user.email)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Button("Bearbeiten") {
                                        // Handle edit profile
                                    }
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                }
                                .padding()
                                .background(Color.white.opacity(0.02))
                                .cornerRadius(10)
                            }
                            
                            SettingsNavigationItem(
                                icon: "key.fill",
                                title: "Passwort ändern",
                                subtitle: "Dein Passwort aktualisieren",
                                color: .blue
                            ) {
                                // Handle password change
                            }
                            
                            SettingsNavigationItem(
                                icon: "envelope.fill",
                                title: "E-Mail ändern",
                                subtitle: "Deine E-Mail-Adresse aktualisieren",
                                color: .green
                            ) {
                                // Handle email change
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        
                        // Support Section
                        VStack(spacing: 15) {
                            SectionHeader(title: "Support")
                            
                            SettingsNavigationItem(
                                icon: "questionmark.circle.fill",
                                title: "Hilfe & FAQ",
                                subtitle: "Häufig gestellte Fragen",
                                color: .cyan
                            ) {
                                // Handle help
                            }
                            
                            SettingsNavigationItem(
                                icon: "envelope.circle.fill",
                                title: "Kontakt",
                                subtitle: "Support kontaktieren",
                                color: .indigo
                            ) {
                                // Handle contact
                            }
                            
                            SettingsNavigationItem(
                                icon: "doc.text.fill",
                                title: "Nutzungsbedingungen",
                                subtitle: "AGB und Datenschutz",
                                color: .brown
                            ) {
                                // Handle terms
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        
                        // Danger Zone
                        VStack(spacing: 15) {
                            SectionHeader(title: "Gefahrenzone")
                            
                            Button(action: {
                                showingDeleteConfirmation = true
                            }) {
                                HStack(spacing: 15) {
                                    Image(systemName: "trash.fill")
                                        .font(.title3)
                                        .foregroundColor(.red)
                                        .frame(width: 25)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Account löschen")
                                            .font(.body)
                                            .fontWeight(.medium)
                                            .foregroundColor(.red)
                                        
                                        Text("Alle Daten werden permanent gelöscht")
                                            .font(.caption)
                                            .foregroundColor(.red.opacity(0.7))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.red.opacity(0.7))
                                }
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        
                        // App Version
                        VStack(spacing: 10) {
                            Text("bumpify")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text("Version 1.0.0")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.bottom, 50)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Zurück") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
        .confirmationDialog(
            "Account löschen",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Account löschen", role: .destructive) {
                // Handle account deletion
                authManager.deleteAccount()
            }
            
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Diese Aktion kann nicht rückgängig gemacht werden. Alle deine Daten werden permanent gelöscht.")
        }
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}

struct SettingsToggleItem: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 25)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(.orange)
        }
        .padding()
        .background(Color.white.opacity(0.02))
        .cornerRadius(10)
    }
}

struct SettingsNavigationItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 25)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white.opacity(0.02))
            .cornerRadius(10)
        }
    }
}

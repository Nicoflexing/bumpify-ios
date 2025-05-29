// SettingsView.swift - Alle Fehler behoben

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var notificationsEnabled = true
    @State private var locationEnabled = true
    @State private var bluetoothEnabled = true
    @State private var showingDeleteConfirmation = false
    @State private var showingNotificationSettings = false
    
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
                            SettingsSectionHeader(title: "App-Einstellungen")
                            
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
                            SettingsSectionHeader(title: "Privatsphäre")
                            
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
                            SettingsSectionHeader(title: "Account")
                            
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
                                            Text(user.initials)
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
                            SettingsSectionHeader(title: "Support")
                            
                            SettingsNavigationItem(
                                icon: "bell.fill",
                                title: "Benachrichtigungen",
                                subtitle: "Anpassen, welche Hinweise du erhältst",
                                color: .blue
                            ) {
                                showingNotificationSettings = true
                            }
                            
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
                            SettingsSectionHeader(title: "Gefahrenzone")
                            
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
        .sheet(isPresented: $showingNotificationSettings) {
            BumpifyNotificationSettingsView()
        }
    }
}

// MARK: - NotificationSettingsView
struct BumpifyNotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var allNotifications = true
    @State private var bumpNotifications = true
    @State private var matchNotifications = true
    @State private var messageNotifications = true
    @State private var eventNotifications = false
    @State private var soundEnabled = true
    @State private var vibrationEnabled = true
    @State private var quietHoursEnabled = false
    @State private var quietStartTime = Date()
    @State private var quietEndTime = Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 10) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                            
                            Text("Benachrichtigungen")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding(.top, 20)
                        
                        // Allgemeine Einstellungen
                        VStack(spacing: 15) {
                            SettingsSectionHeader(title: "Allgemein")
                            
                            SettingsToggleItem(
                                icon: "bell.fill",
                                title: "Alle Benachrichtigungen",
                                subtitle: "Aktiviert oder deaktiviert alle Push-Nachrichten",
                                isOn: $allNotifications,
                                color: .blue
                            )
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        
                        // Spezifische Benachrichtigungen
                        VStack(spacing: 15) {
                            SettingsSectionHeader(title: "Bump-Benachrichtigungen")
                            
                            SettingsToggleItem(
                                icon: "location.circle.fill",
                                title: "Neue Bumps",
                                subtitle: "Benachrichtigung bei neuen Begegnungen",
                                isOn: $bumpNotifications,
                                color: .orange
                            )
                            
                            SettingsToggleItem(
                                icon: "heart.fill",
                                title: "Neue Matches",
                                subtitle: "Benachrichtigung bei erfolgreichen Matches",
                                isOn: $matchNotifications,
                                color: .pink
                            )
                            
                            SettingsToggleItem(
                                icon: "message.fill",
                                title: "Neue Nachrichten",
                                subtitle: "Benachrichtigung bei neuen Chat-Nachrichten",
                                isOn: $messageNotifications,
                                color: .green
                            )
                            
                            SettingsToggleItem(
                                icon: "calendar.circle.fill",
                                title: "Event-Erinnerungen",
                                subtitle: "Benachrichtigung bei nahegelegenen Events",
                                isOn: $eventNotifications,
                                color: .purple
                            )
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        .opacity(allNotifications ? 1.0 : 0.5)
                        .disabled(!allNotifications)
                        
                        // Sound & Vibration
                        VStack(spacing: 15) {
                            SettingsSectionHeader(title: "Sound & Vibration")
                            
                            SettingsToggleItem(
                                icon: "speaker.wave.2.fill",
                                title: "Sound",
                                subtitle: "Benachrichtigungston abspielen",
                                isOn: $soundEnabled,
                                color: .yellow
                            )
                            
                            SettingsToggleItem(
                                icon: "iphone.radiowaves.left.and.right",
                                title: "Vibration",
                                subtitle: "Vibrieren bei Benachrichtigungen",
                                isOn: $vibrationEnabled,
                                color: .cyan
                            )
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        .opacity(allNotifications ? 1.0 : 0.5)
                        .disabled(!allNotifications)
                        
                        // Ruhestunden
                        VStack(spacing: 15) {
                            SettingsSectionHeader(title: "Ruhestunden")
                            
                            SettingsToggleItem(
                                icon: "moon.fill",
                                title: "Ruhestunden aktivieren",
                                subtitle: "Keine Benachrichtigungen während bestimmter Zeiten",
                                isOn: $quietHoursEnabled,
                                color: .indigo
                            )
                            
                            if quietHoursEnabled {
                                VStack(spacing: 12) {
                                    HStack {
                                        Text("Von:")
                                            .foregroundColor(.white)
                                            .frame(width: 40, alignment: .leading)
                                        
                                        DatePicker("", selection: $quietStartTime, displayedComponents: .hourAndMinute)
                                            .labelsHidden()
                                            .colorScheme(.dark)
                                        
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.02))
                                    .cornerRadius(10)
                                    
                                    HStack {
                                        Text("Bis:")
                                            .foregroundColor(.white)
                                            .frame(width: 40, alignment: .leading)
                                        
                                        DatePicker("", selection: $quietEndTime, displayedComponents: .hourAndMinute)
                                            .labelsHidden()
                                            .colorScheme(.dark)
                                        
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.02))
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        .opacity(allNotifications ? 1.0 : 0.5)
                        .disabled(!allNotifications)
                        
                        // Info Box
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Hinweis")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            
                            Text("Du kannst Benachrichtigungen auch über die iOS-Einstellungen für Bumpify verwalten. Gehe zu Einstellungen > Benachrichtigungen > Bumpify.")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(15)
                        
                        Spacer().frame(height: 50)
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
    }
}

// MARK: - Helper Views (eindeutig benannt)
struct SettingsSectionHeader: View {
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

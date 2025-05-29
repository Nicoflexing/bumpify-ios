// NotificationSettingsView.swift - Benachrichtigungseinstellungen
import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    // Notification States
    @State private var masterNotifications = true
    @State private var bumpNotifications = true
    @State private var matchNotifications = true
    @State private var messageNotifications = true
    @State private var eventNotifications = true
    @State private var businessNotifications = false
    
    // Sound Settings
    @State private var soundEnabled = true
    @State private var vibrationEnabled = true
    @State private var selectedSound = "Default"
    
    // Time Settings
    @State private var quietHoursEnabled = false
    @State private var quietStartTime = Date()
    @State private var quietEndTime = Date()
    
    // Frequency Settings
    @State private var bumpFrequency = "Sofort"
    @State private var summaryEnabled = true
    @State private var summaryTime = Date()
    
    let soundOptions = ["Default", "Bump", "Gentle", "Pop", "Classic"]
    let frequencyOptions = ["Sofort", "Alle 5 Min", "Alle 15 Min", "Alle 30 Min", "Stündlich"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.12, green: 0.16, blue: 0.24)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Master Toggle
                        masterToggleSection
                        
                        if masterNotifications {
                            // Notification Types
                            notificationTypesSection
                            
                            // Sound & Vibration
                            soundVibrationSection
                            
                            // Quiet Hours
                            quietHoursSection
                            
                            // Frequency Settings
                            frequencySection
                            
                            // Daily Summary
                            dailySummarySection
                        }
                        
                        // System Settings Link
                        systemSettingsSection
                        
                        Spacer().frame(height: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            loadNotificationSettings()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.white.opacity(0.1)))
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("🔔 Benachrichtigungen")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Passe deine Benachrichtigungen an")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            // Reset button
            Button("Reset") {
                resetToDefaults()
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.orange)
        }
    }
    
    // MARK: - Master Toggle
    private var masterToggleSection: some View {
        VStack(spacing: 16) {
            NotificationCard(
                icon: masterNotifications ? "bell.fill" : "bell.slash.fill",
                title: "Benachrichtigungen",
                subtitle: masterNotifications ? "Alle Benachrichtigungen aktiviert" : "Benachrichtigungen deaktiviert",
                iconColor: masterNotifications ? .green : .red,
                content: {
                    Toggle("", isOn: $masterNotifications)
                        .tint(.orange)
                        .scaleEffect(1.1)
                }
            )
            
            if !masterNotifications {
                ImportantNoteCard(
                    title: "Benachrichtigungen deaktiviert",
                    message: "Du verpasst möglicherweise wichtige Bumps und Matches.",
                    type: .warning
                )
            }
        }
    }
    
    // MARK: - Notification Types
    private var notificationTypesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Benachrichtigungsarten")
            
            VStack(spacing: 12) {
                NotificationToggleCard(
                    icon: "location.circle.fill",
                    title: "Neue Bumps",
                    subtitle: "Wenn jemand in deiner Nähe ist",
                    isOn: $bumpNotifications,
                    iconColor: .orange,
                    badge: bumpNotifications ? "Aktiv" : nil
                )
                
                NotificationToggleCard(
                    icon: "heart.fill",
                    title: "Neue Matches",
                    subtitle: "Wenn sich ein Match ergibt",
                    isOn: $matchNotifications,
                    iconColor: .pink,
                    badge: matchNotifications ? "Aktiv" : nil
                )
                
                NotificationToggleCard(
                    icon: "message.fill",
                    title: "Neue Nachrichten",
                    subtitle: "Chat-Nachrichten von Matches",
                    isOn: $messageNotifications,
                    iconColor: .blue,
                    badge: messageNotifications ? "Aktiv" : nil
                )
                
                NotificationToggleCard(
                    icon: "calendar.circle.fill",
                    title: "Event-Einladungen",
                    subtitle: "Hotspots und Events in der Nähe",
                    isOn: $eventNotifications,
                    iconColor: .purple,
                    badge: eventNotifications ? "Aktiv" : nil
                )
                
                NotificationToggleCard(
                    icon: "building.2.fill",
                    title: "Business-Angebote",
                    subtitle: "Werbung und Angebote",
                    isOn: $businessNotifications,
                    iconColor: .green,
                    badge: businessNotifications ? "Aktiv" : nil
                )
            }
        }
    }
    
    // MARK: - Sound & Vibration
    private var soundVibrationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Sound & Vibration")
            
            VStack(spacing: 12) {
                NotificationToggleCard(
                    icon: "speaker.wave.2.fill",
                    title: "Sound",
                    subtitle: "Benachrichtigungstöne abspielen",
                    isOn: $soundEnabled,
                    iconColor: .blue
                )
                
                if soundEnabled {
                    NotificationPickerCard(
                        icon: "music.note",
                        title: "Benachrichtigungston",
                        subtitle: selectedSound,
                        iconColor: .indigo,
                        options: soundOptions,
                        selection: $selectedSound
                    )
                }
                
                NotificationToggleCard(
                    icon: "iphone.radiowaves.left.and.right",
                    title: "Vibration",
                    subtitle: "Vibrieren bei Benachrichtigungen",
                    isOn: $vibrationEnabled,
                    iconColor: .purple
                )
            }
        }
    }
    
    // MARK: - Quiet Hours
    private var quietHoursSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Ruhezeiten")
            
            VStack(spacing: 12) {
                NotificationToggleCard(
                    icon: "moon.fill",
                    title: "Ruhezeiten aktivieren",
                    subtitle: "Keine Benachrichtigungen während der Ruhezeit",
                    isOn: $quietHoursEnabled,
                    iconColor: .indigo
                )
                
                if quietHoursEnabled {
                    HStack(spacing: 12) {
                        TimePickerCard(
                            title: "Von",
                            time: $quietStartTime,
                            iconColor: .indigo
                        )
                        
                        TimePickerCard(
                            title: "Bis",
                            time: $quietEndTime,
                            iconColor: .indigo
                        )
                    }
                    
                    ImportantNoteCard(
                        title: "Ruhezeiten aktiv",
                        message: "Zwischen \(formatTime(quietStartTime)) und \(formatTime(quietEndTime)) erhältst du keine Benachrichtigungen.",
                        type: .info
                    )
                }
            }
        }
    }
    
    // MARK: - Frequency Section
    private var frequencySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Häufigkeit")
            
            VStack(spacing: 12) {
                NotificationPickerCard(
                    icon: "timer",
                    title: "Bump-Benachrichtigungen",
                    subtitle: "Wie oft möchtest du über Bumps informiert werden?",
                    iconColor: .orange,
                    options: frequencyOptions,
                    selection: $bumpFrequency
                )
                
                if bumpFrequency != "Sofort" {
                    ImportantNoteCard(
                        title: finmFrequencyDesc(),
                        message: "Du könntest wichtige Begegnungen verpassen.",
                        type: .warning
                    )
                }
            }
        }
    }
    
    // MARK: - Daily Summary
    private var dailySummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Tägliche Zusammenfassung")
            
            VStack(spacing: 12) {
                NotificationToggleCard(
                    icon: "doc.text.fill",
                    title: "Tägliche Zusammenfassung",
                    subtitle: "Erhalte eine tägliche Übersicht deiner Aktivitäten",
                    isOn: $summaryEnabled,
                    iconColor: .cyan
                )
                
                if summaryEnabled {
                    TimePickerCard(
                        title: "Uhrzeit",
                        time: $summaryTime,
                        iconColor: .cyan,
                        subtitle: "Wann möchtest du die Zusammenfassung erhalten?"
                    )
                }
            }
        }
    }
    
    // MARK: - System Settings
    private var systemSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "System-Einstellungen")
            
            Button(action: openSystemSettings) {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "gear")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("iOS-Einstellungen öffnen")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Weitere Benachrichtigungsoptionen")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(16)
                .background(glassBackground)
                .cornerRadius(16)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Helper Functions
    private func loadNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                masterNotifications = settings.authorizationStatus == .authorized
            }
        }
    }
    
    private func openSystemSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
    
    private func resetToDefaults() {
        withAnimation(.spring()) {
            masterNotifications = true
            bumpNotifications = true
            matchNotifications = true
            messageNotifications = true
            eventNotifications = true
            businessNotifications = false
            soundEnabled = true
            vibrationEnabled = true
            selectedSound = "Default"
            quietHoursEnabled = false
            bumpFrequency = "Sofort"
            summaryEnabled = true
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func frequencyDesc() -> String {
        switch bumpFrequency {
        case "Alle 5 Min": return "Benachrichtigungen alle 5 Minuten"
        case "Alle 15 Min": return "Benachrichtigungen alle 15 Minuten"
        case "Alle 30 Min": return "Benachrichtigungen alle 30 Minuten"
        case "Stündlich": return "Benachrichtigungen stündlich"
        default: return "Sofortige Benachrichtigungen"
        }
    }
    
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
}

// MARK: - Custom Components

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.white)
    }
}

struct NotificationCard<Content: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let content: () -> Content
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            content()
        }
        .padding(16)
        .background(glassBackground)
        .cornerRadius(16)
    }
    
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
}

struct NotificationToggleCard: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let iconColor: Color
    let badge: String?
    
    init(icon: String, title: String, subtitle: String, isOn: Binding<Bool>, iconColor: Color, badge: String? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self._isOn = isOn
        self.iconColor = iconColor
        self.badge = badge
    }
    
    var body: some View {
        NotificationCard(
            icon: icon,
            title: title,
            subtitle: subtitle,
            iconColor: iconColor
        ) {
            HStack(spacing: 8) {
                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(iconColor)
                        .cornerRadius(8)
                }
                
                Toggle("", isOn: $isOn)
                    .tint(.orange)
            }
        }
    }
}

struct NotificationPickerCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let options: [String]
    @Binding var selection: String
    
    var body: some View {
        NotificationCard(
            icon: icon,
            title: title,
            subtitle: subtitle,
            iconColor: iconColor
        ) {
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) {
                        selection = option
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(selection)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.orange)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.2))
                .cornerRadius(8)
            }
        }
    }
}

struct TimePickerCard: View {
    let title: String
    @Binding var time: Date
    let iconColor: Color
    let subtitle: String?
    
    init(title: String, time: Binding<Date>, iconColor: Color, subtitle: String? = nil) {
        self.title = title
        self._time = time
        self.iconColor = iconColor
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                    .datePickerStyle(CompactDatePickerStyle())
                    .labelsHidden()
                    .colorScheme(.dark)
            }
        }
        .padding(16)
        .background(glassBackground)
        .cornerRadius(16)
    }
    
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
}

struct ImportantNoteCard: View {
    let title: String
    let message: String
    let type: NoteType
    
    enum NoteType {
        case info, warning, success
        
        var color: Color {
            switch self {
            case .info: return .blue
            case .warning: return .orange
            case .success: return .green
            }
        }
        
        var icon: String {
            switch self {
            case .info: return "info.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .success: return "checkmark.circle.fill"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(type.color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(message)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
        .padding(12)
        .background(type.color.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(type.color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    NotificationSettingsView()
        .environmentObject(AuthenticationManager())
}

// BumpNotificationView.swift - Korrigierte Version ohne Konflikte
import SwiftUI

// MARK: - Haupt-View für Benachrichtigungen
struct BumpNotificationView: View {
    let notification: BumpNotification
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.12, green: 0.16, blue: 0.24)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header Icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.green, Color.mint],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: getNotificationIcon())
                            .font(.system(size: 35))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 16) {
                        Text("🎉 Neue Benachrichtigung!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(notification.message)
                            .font(.title2)
                            .foregroundColor(.orange)
                            .multilineTextAlignment(.center)
                        
                        Text("Vor \(timeAgo(from: notification.timestamp))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // Details Card
                    VStack(spacing: 16) {
                        HStack {
                            Text("Details")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 12) {
                            NotificationDetailRow(title: "Typ", value: getNotificationTypeText())
                            NotificationDetailRow(title: "Zeit", value: formatDate(notification.timestamp))
                            NotificationDetailRow(title: "Status", value: "Neu")
                        }
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
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            dismiss()
                        }) {
                            Text(getActionButtonText())
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [Color.orange, Color.red],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                        }
                        
                        Button("Später anzeigen") {
                            dismiss()
                        }
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Schließen") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func getNotificationIcon() -> String {
        switch notification.type {
        case .newBump: return "location.circle.fill"
        case .match: return "heart.fill"
        case .message: return "message.fill"
        case .event: return "calendar.circle.fill"
        }
    }
    
    private func getNotificationTypeText() -> String {
        switch notification.type {
        case .newBump: return "Neue Begegnung"
        case .match: return "Neues Match"
        case .message: return "Neue Nachricht"
        case .event: return "Neues Event"
        }
    }
    
    private func getActionButtonText() -> String {
        switch notification.type {
        case .newBump: return "Profil anzeigen"
        case .match: return "Chat öffnen"
        case .message: return "Nachricht lesen"
        case .event: return "Event anzeigen"
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        
        if interval < 60 {
            return "wenigen Sekunden"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) Minute\(minutes == 1 ? "" : "n")"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours) Stunde\(hours == 1 ? "" : "n")"
        } else {
            let days = Int(interval / 86400)
            return "\(days) Tag\(days == 1 ? "" : "en")"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: date)
    }
}

// MARK: - Detail Row Component
struct NotificationDetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Preview
#Preview {
    BumpNotificationView(
        notification: BumpNotification(
            id: UUID().uuidString,
            message: "Anna Schmidt ist in deiner Nähe!",
            timestamp: Date(),
            type: .newBump
        )
    )
}

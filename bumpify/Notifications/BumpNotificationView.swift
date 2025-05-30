// BumpNotificationView.swift - Komplett saubere Version
// Ersetze deine bestehende BumpNotificationView.swift komplett mit diesem Code

import SwiftUI

struct BumpNotificationView: View {
    let notification: BumpNotification
    @Environment(\.dismiss) private var dismiss
    @State private var showDetails = false
    @State private var slideIn = false
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissWithAnimation()
                }
            
            // Main notification card
            VStack(spacing: 0) {
                // Compact notification banner
                notificationBanner
                
                // Expandable details
                if showDetails {
                    detailsSection
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        ))
                }
            }
            .offset(y: slideIn ? 0 : -100)
            .opacity(slideIn ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                slideIn = true
            }
            
            // Auto-expand details after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showDetails = true
                }
            }
        }
    }
    
    // MARK: - Notification Banner
    private var notificationBanner: some View {
        Button(action: {
            withAnimation(.spring()) {
                showDetails.toggle()
            }
        }) {
            HStack(spacing: 16) {
                // Icon with pulse effect
                ZStack {
                    Circle()
                        .fill(notification.type.color)
                        .frame(width: 50, height: 50)
                        .shadow(color: notification.type.color.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: notification.type.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                // Message content
                VStack(alignment: .leading, spacing: 4) {
                    Text(getNotificationTitle())
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(notification.message)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Expand indicator
                Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .rotationEffect(.degrees(showDetails ? 180 : 0))
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [notification.type.color, notification.type.color.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: notification.type.color.opacity(0.3), radius: 15, x: 0, y: 8)
        }
        .padding(.horizontal, 20)
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Details Section
    private var detailsSection: some View {
        VStack(spacing: 20) {
            // Time and context
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                    
                    Text(formatTime(notification.timestamp))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text("Neue Benachrichtigung")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Type-specific info
                if notification.type == .newBump {
                    HStack {
                        Image(systemName: "location.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                        
                        Text("In deiner Nähe erkannt")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 16)
            
            // Action buttons
            VStack(spacing: 12) {
                // Primary action
                Button(action: {
                    handlePrimaryAction()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: getPrimaryActionIcon())
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text(getPrimaryActionText())
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [notification.type.color, notification.type.color.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: notification.type.color.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                
                // Secondary actions
                HStack(spacing: 12) {
                    Button("Später") {
                        dismissWithAnimation()
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    
                    Button("Ignorieren") {
                        dismissWithAnimation()
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 0.12, green: 0.16, blue: 0.24))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .padding(.top, -8) // Overlap with banner
    }
    
    // MARK: - Helper Functions
    private func getNotificationTitle() -> String {
        switch notification.type {
        case .newBump: return "🎯 Neuer Bump!"
        case .match: return "💖 Neues Match!"
        case .message: return "💬 Neue Nachricht!"
        case .event: return "📅 Neues Event!"
        }
    }
    
    private func getPrimaryActionIcon() -> String {
        switch notification.type {
        case .newBump: return "eye.fill"
        case .match: return "heart.fill"
        case .message: return "message.fill"
        case .event: return "calendar"
        }
    }
    
    private func getPrimaryActionText() -> String {
        switch notification.type {
        case .newBump: return "Profil anzeigen"
        case .match: return "Chat öffnen"
        case .message: return "Nachricht lesen"
        case .event: return "Event anzeigen"
        }
    }
    
    private func handlePrimaryAction() {
        // Add haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        // Handle action based on type
        switch notification.type {
        case .newBump:
            // Navigate to profile
            print("Navigate to user profile")
        case .match:
            // Navigate to chat
            print("Navigate to chat")
        case .message:
            // Navigate to message
            print("Navigate to message")
        case .event:
            // Navigate to event
            print("Navigate to event")
        }
        
        dismissWithAnimation()
    }
    
    private func dismissWithAnimation() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            slideIn = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            dismiss()
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        if timeInterval < 60 {
            return "Gerade eben"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "vor \(minutes) Min"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "vor \(hours) Std"
        } else {
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    }
}

// MARK: - Preview
#Preview("New Bump") {
    BumpNotificationView(
        notification: BumpNotification(
            message: "Anna Schmidt ist in deiner Nähe!",
            type: .newBump
        )
    )
    .background(Color.black)
}

#Preview("New Match") {
    BumpNotificationView(
        notification: BumpNotification(
            message: "Lisa hat dich auch geliked!",
            type: .match
        )
    )
    .background(Color.black)
}

#Preview("New Message") {
    BumpNotificationView(
        notification: BumpNotification(
            message: "Max hat dir eine Nachricht geschickt",
            type: .message
        )
    )
    .background(Color.black)
}

#Preview("New Event") {
    BumpNotificationView(
        notification: BumpNotification(
            message: "Happy Hour im Murphy's Pub",
            type: .event
        )
    )
    .background(Color.black)
}

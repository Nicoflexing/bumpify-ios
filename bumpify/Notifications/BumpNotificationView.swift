// BumpNotificationView.swift - Popup wenn jemand in der Nähe ist
import SwiftUI

struct BumpNotificationView: View {
    let detectedUser: DetectedUser
    let onLike: () -> Void
    let onPass: () -> Void
    let onClose: () -> Void
    
    @State private var showDetails = false
    @State private var pulseAnimation = false
    @State private var slideAnimation = false
    
    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onClose()
                }
            
            // Notification Card
            VStack(spacing: 0) {
                // Top notification banner
                notificationBanner
                
                // Main card content
                if showDetails {
                    mainCardContent
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        ))
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color.clear)
            .offset(y: slideAnimation ? 0 : -100)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                slideAnimation = true
            }
            
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
            
            // Auto-expand after short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
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
            HStack(spacing: 12) {
                // Pulse indicator
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 12, height: 12)
                    
                    Circle()
                        .fill(Color.green.opacity(0.3))
                        .frame(width: 24, height: 24)
                        .scaleEffect(pulseAnimation ? 1.5 : 1.0)
                        .opacity(pulseAnimation ? 0.0 : 1.0)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("🎯 Neuer Bump!")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("\(detectedUser.name) ist in deiner Nähe")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                // Distance indicator
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(String(format: "%.0f", detectedUser.distance))m")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    
                    Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color.orange, Color.red],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(20)
            .shadow(color: Color.orange.opacity(0.4), radius: 15, x: 0, y: 8)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Main Card Content
    private var mainCardContent: some View {
        VStack(spacing: 20) {
            // Profile section
            profileSection
            
            // Quick info
            quickInfoSection
            
            // Action buttons
            actionButtonsSection
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(red: 0.12, green: 0.16, blue: 0.24))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .padding(.top, -10)
    }
    
    // MARK: - Profile Section
    private var profileSection: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange, Color.red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: Color.orange.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Text(detectedUser.name.prefix(1))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                // Online indicator
                Circle()
                    .fill(Color.green)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                    )
                    .offset(x: 25, y: 25)
            }
            
            // Name and basic info
            VStack(spacing: 4) {
                Text(detectedUser.name)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text("In \(String(format: "%.0f", detectedUser.distance))m Entfernung")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.orange)
            }
        }
    }
    
    // MARK: - Quick Info Section
    private var quickInfoSection: some View {
        VStack(spacing: 12) {
            // Signal strength indicator
            HStack(spacing: 8) {
                Image(systemName: "wifi")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.green)
                
                Text("Starkes Signal")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                // RSSI indicator
                HStack(spacing: 2) {
                    ForEach(0..<4) { index in
                        Rectangle()
                            .fill(signalStrength > index ? Color.green : Color.white.opacity(0.3))
                            .frame(width: 4, height: CGFloat(8 + index * 4))
                            .cornerRadius(2)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            
            // Duration indicator
            HStack {
                Image(systemName: "clock.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
                
                Text("Erkannt vor \(Int(Date().timeIntervalSince(detectedUser.firstDetected)))s")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
            }
        }
    }
    
    // MARK: - Action Buttons
    private var actionButtonsSection: some View {
        HStack(spacing: 16) {
            // Pass button
            Button(action: {
                onPass()
                onClose()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                    
                    Text("Überspringen")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white.opacity(0.8))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.1))
                .cornerRadius(14)
            }
            
            // Like button
            Button(action: {
                onLike()
                onClose()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 16, weight: .bold))
                    
                    Text("Interesse")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Color.pink, Color.red],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(14)
                .shadow(color: Color.pink.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
    }
    
    // MARK: - Computed Properties
    private var signalStrength: Int {
        if detectedUser.rssi > -50 {
            return 4
        } else if detectedUser.rssi > -60 {
            return 3
        } else if detectedUser.rssi > -70 {
            return 2
        } else {
            return 1
        }
    }
}

// MARK: - DetectedUser Model (Falls noch nicht vorhanden)
struct DetectedUser {
    let id: String
    let name: String
    let rssi: Int
    let distance: Double
    let firstDetected: Date
    let lastSeen: Date
    let services: [String]
    let manufacturerData: Data?
    var hasBumped: Bool = false
    
    // Mock initializer für Preview
    static var preview: DetectedUser {
        DetectedUser(
            id: "user1",
            name: "Anna Schmidt",
            rssi: -65,
            distance: 8.5,
            firstDetected: Date().addingTimeInterval(-5),
            lastSeen: Date(),
            services: [],
            manufacturerData: nil
        )
    }
}

// MARK: - Preview
#Preview {
    BumpNotificationView(
        detectedUser: DetectedUser.preview,
        onLike: { print("Liked!") },
        onPass: { print("Passed!") },
        onClose: { print("Closed!") }
    )
}

// BumpRequestOverlay.swift
// Neue Datei erstellen: bumpify/Views/Match/BumpRequestOverlay.swift

import SwiftUI

struct BumpRequestOverlay: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Binding var isShowing: Bool
    
    // Bump Request Data
    let request: BumpRequestData
    let onAccept: () -> Void
    let onDecline: () -> Void
    
    // Animation States
    @State private var slideIn = false
    @State private var backgroundOpacity: Double = 0.0
    @State private var overlayScale: Double = 0.8
    @State private var overlayOpacity: Double = 0.0
    @State private var pulseAnimation = false
    @State private var showDetails = false
    
    // User Interaction
    @State private var acceptPressed = false
    @State private var declinePressed = false
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(backgroundOpacity)
                .ignoresSafeArea()
                .onTapGesture {
                    // Optional: Schließen beim Tippen auf Hintergrund deaktiviert
                    // für bessere UX bei wichtigen Entscheidungen
                }
            
            // Main Bump Request Content
            VStack(spacing: 0) {
                // Close button (optional - kann entfernt werden)
                HStack {
                    Spacer()
                    
                    Button(action: {
                        declineWithAnimation()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.6))
                            .background(Circle().fill(Color.black.opacity(0.3)))
                    }
                    .padding(.top, 20)
                    .padding(.trailing, 20)
                }
                
                Spacer()
                
                // Bump Request Card
                VStack(spacing: 30) {
                    // Header mit Animation
                    VStack(spacing: 16) {
                        Text("🎯 BUMP ERKANNT!")
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(.white)
                            .shadow(color: Color.orange.opacity(0.5), radius: 8)
                            .scaleEffect(showDetails ? 1.0 : 0.7)
                            .opacity(showDetails ? 1.0 : 0.0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5), value: showDetails)
                        
                        if showDetails {
                            Text("Jemand ist in deiner Nähe!")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    
                    // User Animation Area
                    ZStack {
                        // Floating Background Effects
                        ForEach(0..<8, id: \.self) { index in
                            Circle()
                                .fill(Color.orange.opacity(0.3))
                                .frame(width: CGFloat.random(in: 4...8))
                                .offset(
                                    x: CGFloat.random(in: -80...80),
                                    y: CGFloat.random(in: -60...60)
                                )
                                .opacity(pulseAnimation ? 0.8 : 0.2)
                                .scaleEffect(pulseAnimation ? 1.5 : 1.0)
                                .animation(
                                    Animation.easeInOut(duration: Double.random(in: 2...3))
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(index) * 0.2),
                                    value: pulseAnimation
                                )
                        }
                        
                        // User Avatars with Animation
                        HStack(spacing: 0) {
                            // Aktueller Nutzer
                            ZStack {
                                // Glow effect
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [Color.orange.opacity(0.6), Color.clear],
                                            center: .center,
                                            startRadius: 30,
                                            endRadius: 60
                                        )
                                    )
                                    .frame(width: 90, height: 90)
                                    .blur(radius: 8)
                                    .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                                
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.orange, .red],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 70, height: 70)
                                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
                                    .shadow(color: Color.orange.opacity(0.4), radius: 12, x: 0, y: 6)
                                
                                Text(authManager.currentUser?.initials ?? "Me")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .offset(x: slideIn ? 40 : -60)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: slideIn)
                            
                            Spacer()
                                .frame(width: slideIn ? 60 : 120)
                                .animation(.spring(response: 0.8, dampingFraction: 0.8), value: slideIn)
                            
                            // Erkannter Nutzer
                            ZStack {
                                // Glow effect
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [Color.blue.opacity(0.6), Color.clear],
                                            center: .center,
                                            startRadius: 30,
                                            endRadius: 60
                                        )
                                    )
                                    .frame(width: 90, height: 90)
                                    .blur(radius: 8)
                                    .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                                
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue, .teal],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 70, height: 70)
                                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
                                    .shadow(color: Color.blue.opacity(0.4), radius: 12, x: 0, y: 6)
                                
                                Text(getDetectedUserInitials())
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .offset(x: slideIn ? -40 : 60)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: slideIn)
                        }
                        .padding(.horizontal, 40)
                        
                        // Connection Animation in der Mitte
                        if slideIn {
                            ForEach(0..<3, id: \.self) { index in
                                Circle()
                                    .stroke(Color.orange.opacity(0.8), lineWidth: 2)
                                    .frame(width: 20)
                                    .scaleEffect(pulseAnimation ? 2.5 : 1.0)
                                    .opacity(pulseAnimation ? 0.0 : 1.0)
                                    .animation(
                                        Animation.easeOut(duration: 1.5)
                                            .repeatForever()
                                            .delay(Double(index) * 0.3),
                                        value: pulseAnimation
                                    )
                            }
                        }
                    }
                    .frame(height: 120)
                    
                    // User Info
                    if showDetails {
                        VStack(spacing: 12) {
                            Text("Du hast \(request.detectedUser.name) entdeckt!")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            if let location = request.location {
                                HStack(spacing: 6) {
                                    Image(systemName: "location.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.blue)
                                    
                                    Text(location)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(12)
                            }
                            
                            Text("Entfernung: \(String(format: "%.1f", request.detectedUser.distance))m")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Action Buttons
                    if showDetails {
                        VStack(spacing: 16) {
                            // Accept Button
                            Button(action: {
                                acceptWithAnimation()
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20, weight: .semibold))
                                    
                                    Text("Bump akzeptieren")
                                        .font(.system(size: 18, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .frame(width: 220)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [.green, .mint],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(25)
                                .shadow(color: Color.green.opacity(0.4), radius: 12, x: 0, y: 6)
                            }
                            .scaleEffect(acceptPressed ? 0.95 : 1.0)
                            .animation(.easeInOut(duration: 0.1), value: acceptPressed)
                            
                            // Decline Button
                            Button(action: {
                                declineWithAnimation()
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 20, weight: .semibold))
                                    
                                    Text("Höflich ablehnen")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.white.opacity(0.9))
                                .frame(width: 220)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.white.opacity(0.15))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 25)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            .scaleEffect(declinePressed ? 0.95 : 1.0)
                            .animation(.easeInOut(duration: 0.1), value: declinePressed)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.horizontal, 40)
                    }
                    
                    // Info Text
                    if showDetails {
                        Text("Ein Bump entsteht nur, wenn beide Personen zustimmen")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .transition(.opacity)
                    }
                }
                .padding(.vertical, 40)
                .padding(.horizontal, 30)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.ultraThinMaterial)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.orange.opacity(0.2),
                                            Color.blue.opacity(0.15),
                                            Color.purple.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.white.opacity(0.2), lineWidth: 2)
                        )
                )
                .scaleEffect(overlayScale)
                .opacity(overlayOpacity)
                .padding(.horizontal, 30)
                
                Spacer()
            }
        }
        .onAppear {
            startBumpRequestAnimation()
        }
    }
    
    // MARK: - Helper Functions
    
    private func getDetectedUserInitials() -> String {
        let components = request.detectedUser.name.components(separatedBy: " ")
        let firstInitial = components.first?.first?.uppercased() ?? ""
        let lastInitial = components.count > 1 ? components.last?.first?.uppercased() ?? "" : ""
        return "\(firstInitial)\(lastInitial)"
    }
    
    // MARK: - Animation Functions
    
    private func startBumpRequestAnimation() {
        // Overlay erscheinen lassen
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            backgroundOpacity = 0.7
            overlayScale = 1.0
            overlayOpacity = 1.0
        }
        
        // Benutzer-Avatare animieren
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                slideIn = true
            }
        }
        
        // Pulse-Animation starten
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            pulseAnimation = true
        }
        
        // Details zeigen
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showDetails = true
            }
        }
    }
    
    private func acceptWithAnimation() {
        // Haptic Feedback
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
        
        acceptPressed = true
        
        // Visual Feedback
        withAnimation(.easeInOut(duration: 0.15)) {
            overlayScale = 1.05
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.15)) {
                overlayScale = 1.0
            }
        }
        
        // Success Feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let successFeedback = UINotificationFeedbackGenerator()
            successFeedback.notificationOccurred(.success)
            
            onAccept()
            dismissWithAnimation()
        }
    }
    
    private func declineWithAnimation() {
        // Haptic Feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        declinePressed = true
        
        onDecline()
        dismissWithAnimation()
    }
    
    private func dismissWithAnimation() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            overlayScale = 0.8
            overlayOpacity = 0.0
            backgroundOpacity = 0.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isShowing = false
        }
    }
}

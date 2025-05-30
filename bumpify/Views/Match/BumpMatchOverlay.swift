// BumpMatchOverlay.swift
// Neue Datei erstellen: bumpify/Views/Match/BumpMatchOverlay.swift

import SwiftUI

struct BumpMatchOverlay: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Binding var isShowing: Bool
    
    // Match Data
    let user1: BumpifyUser // Der aktuelle Nutzer
    let user2: BumpifyUser // Der gematchte Nutzer
    let matchLocation: String
    
    // ✅ ÖFFENTLICHER INITIALIZER
    init(isShowing: Binding<Bool>, user1: BumpifyUser, user2: BumpifyUser, matchLocation: String) {
        self._isShowing = isShowing
        self.user1 = user1
        self.user2 = user2
        self.matchLocation = matchLocation
    }
    
    // Animation States
    @State private var isAnimating = false
    @State private var showMatchText = false
    @State private var showCollisionEffects = false
    @State private var showButtons = false
    @State private var backgroundOpacity: Double = 0.0
    @State private var overlayScale: Double = 0.5
    @State private var overlayOpacity: Double = 0.0
    
    // Particle Effects
    @State private var particleAnimations: [Bool] = Array(repeating: false, count: 12)
    @State private var rippleAnimations: [Bool] = Array(repeating: false, count: 3)
    
    // User Interaction
    @State private var startChatPressed = false
    @State private var continuePressed = false
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(backgroundOpacity)
                .ignoresSafeArea()
                .onTapGesture {
                    // Optional: Schließen beim Tippen auf Hintergrund
                    dismissWithAnimation()
                }
            
            // Main overlay content
            VStack(spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    
                    Button(action: {
                        dismissWithAnimation()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.8))
                            .background(Circle().fill(Color.black.opacity(0.3)))
                    }
                    .padding(.top, 20)
                    .padding(.trailing, 20)
                }
                
                Spacer()
                
                // Match Animation Container
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 12) {
                        Text("🎯 IT'S A MATCH!")
                            .font(.system(size: 32, weight: .black))
                            .foregroundColor(.white)
                            .shadow(color: Color.orange.opacity(0.5), radius: 10)
                            .scaleEffect(showMatchText ? 1.0 : 0.5)
                            .opacity(showMatchText ? 1.0 : 0.0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(1.5), value: showMatchText)
                        
                        if showMatchText {
                            Text("Du und \(user2.firstName) habt euch gegenseitig geliked!")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    
                    // User Animation Area
                    ZStack {
                        // Floating Background Particles
                        floatingBackgroundParticles
                        
                        // User Circles with Animation
                        HStack(spacing: 0) {
                            // User 1 Circle (Aktueller Nutzer)
                            userCircle(user: user1, isLeft: true)
                                .offset(x: isAnimating ? 60 : -120)
                                .rotationEffect(.degrees(isAnimating ? -15 : 0))
                                .scaleEffect(isAnimating ? 1.3 : 1.0)
                                .animation(.easeInOut(duration: 1.5).delay(0.3), value: isAnimating)
                            
                            Spacer()
                                .frame(width: isAnimating ? 40 : 240)
                                .animation(.easeInOut(duration: 1.5), value: isAnimating)
                            
                            // User 2 Circle (Gematchter Nutzer)
                            userCircle(user: user2, isLeft: false)
                                .offset(x: isAnimating ? -60 : 120)
                                .rotationEffect(.degrees(isAnimating ? 15 : 0))
                                .scaleEffect(isAnimating ? 1.3 : 1.0)
                                .animation(.easeInOut(duration: 1.5).delay(0.3), value: isAnimating)
                        }
                        .padding(.horizontal, 40)
                        
                        // Collision Effects
                        if showCollisionEffects {
                            collisionEffectsView
                        }
                        
                        // Ripple Effects
                        if showCollisionEffects {
                            rippleEffectsView
                        }
                    }
                    .frame(height: 200)
                    
                    // Location Info
                    if showMatchText {
                        HStack(spacing: 8) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.orange)
                            
                            Text("Match bei: \(matchLocation)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.black.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.orange.opacity(0.5), lineWidth: 1)
                                )
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Action Buttons
                    if showButtons {
                        VStack(spacing: 16) {
                            // Primary Action - Start Chat
                            Button(action: {
                                triggerHapticFeedback(.impact(.heavy))
                                startChatPressed = true
                                startChat()
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "message.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                    
                                    Text("Chat starten")
                                        .font(.system(size: 18, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .frame(width: 200)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [Color.orange, Color.red],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(25)
                                .shadow(color: Color.orange.opacity(0.5), radius: 15, x: 0, y: 8)
                            }
                            .scaleEffect(startChatPressed ? 0.95 : 1.0)
                            .animation(.easeInOut(duration: 0.1), value: startChatPressed)
                            
                            // Secondary Action - Continue Bumping
                            Button(action: {
                                triggerHapticFeedback(.impact(.medium))
                                continuePressed = true
                                continueBumping()
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "location.circle.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                    
                                    Text("Weiter bumpen")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.white.opacity(0.9))
                                .frame(width: 200)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.white.opacity(0.2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 25)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            .scaleEffect(continuePressed ? 0.95 : 1.0)
                            .animation(.easeInOut(duration: 0.1), value: continuePressed)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.horizontal, 40)
                    }
                }
                .padding(.vertical, 40)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.ultraThinMaterial)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.orange.opacity(0.3),
                                            Color.red.opacity(0.2),
                                            Color.purple.opacity(0.2)
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
            startMatchAnimation()
        }
    }
    
    // MARK: - User Circle
    private func userCircle(user: BumpifyUser, isLeft: Bool) -> some View {
        ZStack {
            // Glow Effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            (isLeft ? Color.orange : Color.blue).opacity(0.6),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 30,
                        endRadius: 70
                    )
                )
                .frame(width: 100, height: 100)
                .blur(radius: 10)
                .scaleEffect(isAnimating ? 1.5 : 1.0)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
            
            // Main Circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: isLeft ?
                            [Color.orange, Color.red] :
                            [Color.blue, Color.teal],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 4)
                )
                .shadow(
                    color: (isLeft ? Color.orange : Color.blue).opacity(0.5),
                    radius: 15,
                    x: 0,
                    y: 8
                )
            
            // User Initials
            Text(user.initials)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Collision Effects
    private var collisionEffectsView: some View {
        ZStack {
            ForEach(0..<12, id: \.self) { index in
                Circle()
                    .fill(sparkColors[index % sparkColors.count])
                    .frame(width: CGFloat.random(in: 6...12), height: CGFloat.random(in: 6...12))
                    .offset(
                        x: cos(Double(index) * 30 * .pi / 180) * Double.random(in: 40...80),
                        y: sin(Double(index) * 30 * .pi / 180) * Double.random(in: 40...80)
                    )
                    .opacity(particleAnimations[index] ? 1 : 0)
                    .scaleEffect(particleAnimations[index] ? 2.5 : 0.5)
                    .animation(
                        .easeOut(duration: 1.5).delay(Double(index) * 0.05),
                        value: particleAnimations[index]
                    )
            }
        }
    }
    
    private var sparkColors: [Color] = [
        .orange, .red, .yellow, .pink, .purple, .blue, .teal, .green, .mint, .cyan
    ]
    
    // MARK: - Ripple Effects
    private var rippleEffectsView: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.orange.opacity(0.8),
                                Color.red.opacity(0.6),
                                Color.yellow.opacity(0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 4
                    )
                    .frame(
                        width: rippleAnimations[index] ? 250 : 80,
                        height: rippleAnimations[index] ? 250 : 80
                    )
                    .opacity(rippleAnimations[index] ? 0 : 1)
                    .animation(
                        .easeOut(duration: 2.0).delay(Double(index) * 0.4),
                        value: rippleAnimations[index]
                    )
            }
        }
    }
    
    // MARK: - Floating Background Particles
    private var floatingBackgroundParticles: some View {
        ZStack {
            ForEach(0..<15, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: CGFloat.random(in: 2...6), height: CGFloat.random(in: 2...6))
                    .offset(
                        x: CGFloat.random(in: -150...150),
                        y: CGFloat.random(in: -100...100)
                    )
                    .opacity(showCollisionEffects ? 0.8 : 0.2)
                    .scaleEffect(showCollisionEffects ? 2.0 : 1.0)
                    .animation(
                        .easeOut(duration: 3.0).delay(Double(index) * 0.1),
                        value: showCollisionEffects
                    )
            }
        }
    }
    
    // MARK: - Animation Functions
    private func startMatchAnimation() {
        // Overlay erscheinen lassen
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            backgroundOpacity = 0.6
            overlayScale = 1.0
            overlayOpacity = 1.0
        }
        
        // Bump animation starten
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 1.5)) {
                isAnimating = true
            }
        }
        
        // Collision effects bei peak
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            triggerCollisionEffects()
            triggerHapticFeedback(.success)
        }
        
        // Match text zeigen
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showMatchText = true
            }
        }
        
        // Buttons zeigen
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showButtons = true
            }
        }
    }
    
    private func triggerCollisionEffects() {
        withAnimation {
            showCollisionEffects = true
        }
        
        // Animate particles
        for i in 0..<particleAnimations.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.03) {
                withAnimation {
                    particleAnimations[i] = true
                }
            }
        }
        
        // Animate ripples
        for i in 0..<rippleAnimations.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.4) {
                withAnimation {
                    rippleAnimations[i] = true
                }
            }
        }
    }
    
    // MARK: - User Actions
    private func startChat() {
        print("Starting chat with \(user2.firstName)")
        
        // TODO: Hier Navigation zum Chat implementieren
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismissWithAnimation()
        }
    }
    
    private func continueBumping() {
        print("Continuing to bump")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            dismissWithAnimation()
        }
    }
    
    private func dismissWithAnimation() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            overlayScale = 0.5
            overlayOpacity = 0.0
            backgroundOpacity = 0.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isShowing = false
        }
    }
    
    private func triggerHapticFeedback(_ type: MatchHapticFeedbackType) {
        switch type {
        case .success:
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.success)
        case .impact(let style):
            let feedback = UIImpactFeedbackGenerator(style: style)
            feedback.impactOccurred()
        }
    }
}

// MARK: - Haptic Feedback Type
private enum MatchHapticFeedbackType {
    case success
    case impact(UIImpactFeedbackGenerator.FeedbackStyle)
}

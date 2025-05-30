// BumpMatchView.swift
// Erstelle diese Datei als: bumpify/Views/Match/BumpMatchView.swift

import SwiftUI

struct BumpMatchView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    // Match Data - Diese werden beim Aufruf übergeben
    let user1: BumpifyUser // Der aktuelle Nutzer
    let user2: BumpifyUser // Der gematchte Nutzer
    let matchLocation: String // Wo der Match stattgefunden hat
    
    // Animation States
    @State private var isAnimating = false
    @State private var showMatchText = false
    @State private var showCollisionEffects = false
    @State private var showButtons = false
    @State private var autoAnimationTimer: Timer?
    
    // Particle Effects
    @State private var particleAnimations: [Bool] = Array(repeating: false, count: 12)
    @State private var rippleAnimations: [Bool] = Array(repeating: false, count: 3)
    
    // User Interaction
    @State private var startChatPressed = false
    @State private var continuePressed = false
    
    // ✅ ÖFFENTLICHER INITIALIZER
    init(user1: BumpifyUser, user2: BumpifyUser, matchLocation: String) {
        self.user1 = user1
        self.user2 = user2
        self.matchLocation = matchLocation
    }
    
    var body: some View {
        ZStack {
            // Background - Bumpify Design
            backgroundGradient
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                Spacer()
                
                // Main Animation Area
                ZStack {
                    // Floating Background Particles
                    floatingBackgroundParticles
                    
                    // User Circles with Animation
                    HStack(spacing: 0) {
                        // User 1 Circle (Aktueller Nutzer)
                        userCircle(user: user1, isLeft: true)
                            .offset(x: isAnimating ? 80 : 0)
                            .rotationEffect(.degrees(isAnimating ? -12 : 0))
                            .scaleEffect(isAnimating ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 1.8).delay(0.3), value: isAnimating)
                        
                        Spacer()
                            .frame(width: isAnimating ? 40 : 160)
                            .animation(.easeInOut(duration: 1.8), value: isAnimating)
                        
                        // User 2 Circle (Gematchter Nutzer)
                        userCircle(user: user2, isLeft: false)
                            .offset(x: isAnimating ? -80 : 0)
                            .rotationEffect(.degrees(isAnimating ? 12 : 0))
                            .scaleEffect(isAnimating ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 1.8).delay(0.3), value: isAnimating)
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
                .frame(height: 300)
                
                Spacer()
                
                // Match Text
                if showMatchText {
                    matchTextView
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .opacity
                        ))
                }
                
                Spacer()
                
                // Action Buttons
                if showButtons {
                    actionButtonsView
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                Spacer().frame(height: 40)
            }
            
            // Close Button
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.black.opacity(0.3)))
                    }
                }
                .padding(.top, 60)
                .padding(.trailing, 20)
                
                Spacer()
            }
        }
        .onAppear {
            startBumpAnimation()
        }
        .onDisappear {
            stopAutoAnimation()
        }
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        ZStack {
            // Base dark background
            Color(red: 0.12, green: 0.16, blue: 0.24)
                .ignoresSafeArea()
            
            // Animated gradient overlay
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.4, blue: 0.2).opacity(showCollisionEffects ? 0.3 : 0.1),
                    Color.clear,
                    Color(red: 1.0, green: 0.6, blue: 0.0).opacity(showCollisionEffects ? 0.2 : 0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.0), value: showCollisionEffects)
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Text("🎯 Bump Match!")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            // Location Badge
            HStack(spacing: 6) {
                Image(systemName: "location.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.orange)
                
                Text(matchLocation)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    // MARK: - User Circle
    private func userCircle(user: BumpifyUser, isLeft: Bool) -> some View {
        ZStack {
            // Glow Effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.orange.opacity(isAnimating ? 0.4 : 0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 100
                    )
                )
                .frame(width: 120, height: 120)
                .blur(radius: 8)
                .scaleEffect(isAnimating ? 1.3 : 1.0)
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
                .frame(width: 90, height: 90)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                )
                .shadow(
                    color: (isLeft ? Color.orange : Color.blue).opacity(0.3),
                    radius: isAnimating ? 20 : 10,
                    x: 0,
                    y: isAnimating ? 10 : 5
                )
            
            // User Initials
            Text(user.initials)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            // Status Ring
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(
                    Animation.linear(duration: 3.0)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
        }
    }
    
    // MARK: - Collision Effects
    private var collisionEffectsView: some View {
        ZStack {
            ForEach(0..<12, id: \.self) { index in
                Circle()
                    .fill(bumpifySparkColors[index % bumpifySparkColors.count])
                    .frame(width: CGFloat.random(in: 4...8), height: CGFloat.random(in: 4...8))
                    .offset(
                        x: cos(Double(index) * 30 * .pi / 180) * Double.random(in: 30...60),
                        y: sin(Double(index) * 30 * .pi / 180) * Double.random(in: 30...60)
                    )
                    .opacity(particleAnimations[index] ? 1 : 0)
                    .scaleEffect(particleAnimations[index] ? 2.0 : 0.5)
                    .animation(
                        .easeOut(duration: 1.2).delay(Double(index) * 0.05),
                        value: particleAnimations[index]
                    )
            }
        }
    }
    
    private var bumpifySparkColors: [Color] = [
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
                        lineWidth: 3
                    )
                    .frame(
                        width: rippleAnimations[index] ? 200 : 50,
                        height: rippleAnimations[index] ? 200 : 50
                    )
                    .opacity(rippleAnimations[index] ? 0 : 1)
                    .animation(
                        .easeOut(duration: 1.5).delay(Double(index) * 0.3),
                        value: rippleAnimations[index]
                    )
            }
        }
    }
    
    // MARK: - Floating Background Particles
    private var floatingBackgroundParticles: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 3, height: 3)
                    .offset(
                        x: CGFloat.random(in: -100...100),
                        y: CGFloat.random(in: -50...50) + (showCollisionEffects ? -30 : 0)
                    )
                    .opacity(showCollisionEffects ? 0.8 : 0.3)
                    .animation(
                        .easeOut(duration: 2.0).delay(Double(index) * 0.15),
                        value: showCollisionEffects
                    )
            }
        }
    }
    
    // MARK: - Match Text
    private var matchTextView: some View {
        VStack(spacing: 16) {
            Text("🎉 Es ist ein Match! 🎉")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
            
            Text("Du und \(user2.firstName) haben sich gegenseitig geliked!")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.1))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .scaleEffect(showMatchText ? 1.0 : 0.8)
        .opacity(showMatchText ? 1.0 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showMatchText)
    }
    
    // MARK: - Action Buttons
    private var actionButtonsView: some View {
        VStack(spacing: 16) {
            // Primary Action - Start Chat
            Button(action: {
                triggerMatchHapticFeedback(.impact(.heavy))
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
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color.orange, Color.red],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: Color.orange.opacity(0.4), radius: 12, x: 0, y: 6)
            }
            .scaleEffect(startChatPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: startChatPressed)
            
            // Secondary Action - Continue Bumping
            Button(action: {
                triggerMatchHapticFeedback(.impact(.medium))
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
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            .scaleEffect(continuePressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: continuePressed)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Animation Functions
    private func startBumpAnimation() {
        // Initial delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            performBumpSequence()
        }
    }
    
    private func performBumpSequence() {
        // Start bump animation
        withAnimation(.easeInOut(duration: 1.8)) {
            isAnimating = true
        }
        
        // Trigger collision effects at peak
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            triggerCollisionEffects()
            triggerMatchHapticFeedback(.success)
        }
        
        // Show match text
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showMatchText = true
            }
        }
        
        // Show action buttons
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showButtons = true
            }
            stopAutoAnimation()
        }
        
        // Reset animation state
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 1.0)) {
                isAnimating = false
            }
        }
    }
    
    private func triggerCollisionEffects() {
        withAnimation {
            showCollisionEffects = true
        }
        
        // Animate particles
        for i in 0..<particleAnimations.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.05) {
                withAnimation {
                    particleAnimations[i] = true
                }
            }
        }
        
        // Animate ripples
        for i in 0..<rippleAnimations.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3) {
                withAnimation {
                    rippleAnimations[i] = true
                }
            }
        }
        
        // Reset effects
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                showCollisionEffects = false
            }
            resetAnimations()
        }
    }
    
    private func resetAnimations() {
        particleAnimations = Array(repeating: false, count: 12)
        rippleAnimations = Array(repeating: false, count: 3)
    }
    
    private func stopAutoAnimation() {
        autoAnimationTimer?.invalidate()
        autoAnimationTimer = nil
    }
    
    // MARK: - User Actions
    private func startChat() {
        print("Starting chat with \(user2.firstName)")
        
        // TODO: Hier Navigation zum Chat implementieren
        // Beispiel:
        // NotificationCenter.default.post(name: .startChat, object: user2)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
    
    private func continueBumping() {
        print("Continuing to bump")
        
        // TODO: Hier zurück zum Bump-Modus
        // Beispiel:
        // NotificationCenter.default.post(name: .continueBumping, object: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
    
    private func triggerMatchHapticFeedback(_ type: MatchHapticFeedbackType) {
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

// MARK: - Match Haptic Feedback Type
private enum MatchHapticFeedbackType {
    case success
    case impact(UIImpactFeedbackGenerator.FeedbackStyle)
}

// MARK: - Preview
#Preview {
    BumpMatchView(
        user1: BumpifyUser(
            firstName: "Max",
            lastName: "Mustermann",
            email: "max@example.com",
            interests: ["Musik", "Sport"],
            age: 25,
            bio: "Test User",
            location: "München"
        ),
        user2: BumpifyUser(
            firstName: "Anna",
            lastName: "Schmidt",
            email: "anna@example.com",
            interests: ["Reisen", "Fotografie"],
            age: 23,
            bio: "Test User 2",
            location: "München"
        ),
        matchLocation: "Café Central"
    )
    .environmentObject(AuthenticationManager())
}

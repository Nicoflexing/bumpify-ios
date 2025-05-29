// BumpView.swift - Korrigierte Version mit BLE Manager Integration

import SwiftUI

struct BumpView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var bleManager = BumpifyBLEManager() // BLE Manager hinzugefügt
    
    @State private var isBumping = false
    @State private var activeTime = 0
    @State private var timer: Timer?
    @State private var pulseScale: Double = 1.0
    @State private var rotationAngle: Double = 0
    @State private var showSettings = false
    
    // Animation states - alle als Double für Konsistenz
    @State private var waveScale: Double = 1.0
    @State private var glowOpacity: Double = 0.5
    @State private var ringScale1: Double = 1.0
    @State private var ringScale2: Double = 1.0
    @State private var ringScale3: Double = 1.0
    @State private var ringScale4: Double = 1.0
    
    var body: some View {
        ZStack {
            // Background
            backgroundGradient
            
            VStack(spacing: 0) {
                // Header
                headerSection
                    .padding(.top, 20)
                
                Spacer()
                
                // Main visualization
                mainVisualization
                
                Spacer()
                
                // Status cards
                statusSection
                    .padding(.horizontal, 20)
                
                // Controls
                controlSection
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
            }
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            startAllAnimations()
            setupBLEObservers()
        }
        .onDisappear {
            stopAllTimers()
            cleanupBLEObservers()
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheet()
        }
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [Color.black, Color(red: 0.05, green: 0.05, blue: 0.15), Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Glow effect when active
            if isBumping {
                RadialGradient(
                    colors: [Color.orange.opacity(0.1), Color.red.opacity(0.05), Color.clear],
                    center: .center,
                    startRadius: 100,
                    endRadius: 400
                )
                .opacity(glowOpacity)
            }
            
            // Floating particles
            particleEffects
        }
    }
    
    // MARK: - Particle Effects
    private var particleEffects: some View {
        ForEach(0..<8, id: \.self) { i in
            Circle()
                .fill(Color.orange.opacity(0.2))
                .frame(width: 3, height: 3)
                .offset(
                    x: Double.random(in: -150...150),
                    y: Double.random(in: -300...300) + (isBumping ? -10 : 10)
                )
                .animation(
                    Animation.easeInOut(duration: Double.random(in: 2...4))
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.2),
                    value: isBumping
                )
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("⚡ Bump Modus")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.orange, Color.red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text(getStatusText())
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Button(action: { showSettings = true }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Circle().fill(Color.white.opacity(0.1)))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Main Visualization
    private var mainVisualization: some View {
        ZStack {
            // Outer rings
            Circle()
                .stroke(Color.orange.opacity(0.4), lineWidth: 2)
                .frame(width: 260)
                .scaleEffect(ringScale1)
            
            Circle()
                .stroke(Color.orange.opacity(0.3), lineWidth: 2)
                .frame(width: 320)
                .scaleEffect(ringScale2)
            
            Circle()
                .stroke(Color.orange.opacity(0.2), lineWidth: 2)
                .frame(width: 380)
                .scaleEffect(ringScale3)
            
            Circle()
                .stroke(Color.orange.opacity(0.1), lineWidth: 2)
                .frame(width: 440)
                .scaleEffect(ringScale4)
            
            // Main orb
            ZStack {
                // Glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.orange.opacity(0.4), Color.clear],
                            center: .center,
                            startRadius: 50,
                            endRadius: 100
                        )
                    )
                    .frame(width: 160, height: 160)
                    .blur(radius: 15)
                    .scaleEffect(pulseScale)
                
                // Main circle
                Circle()
                    .fill(.ultraThinMaterial)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange.opacity(0.3), Color.red.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
                    .frame(width: 120, height: 120)
                
                // Content
                VStack(spacing: 6) {
                    Image(systemName: isBumping ? "wifi.circle" : "location.circle")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(rotationAngle))
                    
                    if isBumping && bleManager.nearbyUsers.count > 0 {
                        Text("\(bleManager.nearbyUsers.count)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("in der Nähe")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            
            // Detection indicators
            if isBumping {
                ForEach(bleManager.nearbyUsers.indices, id: \.self) { index in
                    if index < 6 { // Maximal 6 Indikatoren anzeigen
                        detectionIndicator(index: index)
                    }
                }
            }
        }
        .frame(height: 400)
    }
    
    // MARK: - Detection Indicator
    private func detectionIndicator(index: Int) -> some View {
        let angle = Double(index) * (360.0 / Double(max(bleManager.nearbyUsers.count, 1)))
        let radius = 140.0
        
        return Circle()
            .fill(Color.green)
            .frame(width: 10, height: 10)
            .overlay(Circle().stroke(Color.white, lineWidth: 1))
            .offset(
                x: cos(angle * .pi / 180) * radius,
                y: sin(angle * .pi / 180) * radius
            )
            .scaleEffect(waveScale)
    }
    
    // MARK: - Status Section
    private var statusSection: some View {
        HStack(spacing: 16) {
            SimpleStatusCard(
                icon: "heart.fill",
                title: "Matches",
                value: "12",
                color: .pink
            )
            
            SimpleStatusCard(
                icon: "location.fill",
                title: "Reichweite",
                value: "50m",
                color: .blue
            )
            
            SimpleStatusCard(
                icon: "bolt.fill",
                title: "Bluetooth",
                value: bleManager.bluetoothReady ? "✓" : "✗",
                color: bleManager.bluetoothReady ? .green : .red
            )
        }
    }
    
    // MARK: - Control Section
    private var controlSection: some View {
        VStack(spacing: 16) {
            // Main button
            Button(action: toggleBump) {
                HStack(spacing: 16) {
                    Image(systemName: isBumping ? "pause.circle.fill" : "play.circle.fill")
                        .font(.title2)
                    
                    Text(isBumping ? "Bump Stoppen" : "Bump Starten")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: isBumping ? [Color.red, Color.red.opacity(0.8)] : [Color.orange, Color.red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .shadow(color: Color.orange.opacity(0.3), radius: 15, x: 0, y: 8)
            }
            .disabled(!bleManager.bluetoothReady)
            .opacity(bleManager.bluetoothReady ? 1.0 : 0.6)
            
            // Bluetooth Status Info
            if !bleManager.bluetoothReady {
                Text(bleManager.bluetoothStatus)
                    .font(.caption)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
            }
            
            // Quick actions
            HStack(spacing: 12) {
                SimpleActionButton(icon: "target", title: "Boost") {}
                SimpleActionButton(icon: "person.2.fill", title: "Filter") {}
                SimpleActionButton(icon: "map.fill", title: "Karte") {}
            }
        }
    }
    
    // MARK: - Actions
    private func toggleBump() {
        guard bleManager.bluetoothReady else {
            print("❌ Bluetooth not ready")
            return
        }
        
        isBumping.toggle()
        
        if isBumping {
            startTimer()
            // BLE Manager starten
            bleManager.startBumpMode(userID: authManager.currentUser?.id ?? "anonymous")
        } else {
            stopTimer()
            activeTime = 0
            // BLE Manager stoppen
            bleManager.stopBumpMode()
        }
        
        print("🔄 Bump Mode: \(isBumping ? "Started" : "Stopped")")
    }
    
    private func startAllAnimations() {
        // Pulse animation
        withAnimation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            pulseScale = 1.1
            glowOpacity = 0.8
        }
        
        // Rotation
        withAnimation(Animation.linear(duration: 8.0).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // Ring animations
        withAnimation(Animation.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            ringScale1 = 1.05
        }
        withAnimation(Animation.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
            ringScale2 = 1.08
        }
        withAnimation(Animation.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            ringScale3 = 1.12
        }
        withAnimation(Animation.easeInOut(duration: 4.5).repeatForever(autoreverses: true)) {
            ringScale4 = 1.15
        }
        
        // Wave animation
        withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            waveScale = 1.3
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            activeTime += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func stopAllTimers() {
        timer?.invalidate()
        timer = nil
    }
    
    private func getStatusText() -> String {
        if !bleManager.bluetoothReady {
            return bleManager.bluetoothStatus
        } else if isBumping {
            return "Aktiv • \(formatTime(activeTime)) • \(bleManager.nearbyUsers.count) gefunden"
        } else {
            return "Bereit zum Starten"
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", minutes, secs)
    }
    
    // MARK: - BLE Observer Setup
    private func setupBLEObservers() {
        NotificationCenter.default.addObserver(
            forName: .bumpDetected,
            object: nil,
            queue: .main
        ) { notification in
            if let bumpEvent = notification.object as? BumpEvent {
                handleBumpDetected(bumpEvent)
            }
        }
    }
    
    private func cleanupBLEObservers() {
        NotificationCenter.default.removeObserver(self, name: .bumpDetected, object: nil)
    }
    
    private func handleBumpDetected(_ bumpEvent: BumpEvent) {
        print("🎯 UI: Bump detected with \(bumpEvent.detectedUser.name)")
        // Hier könntest du eine Bump-Benachrichtigung anzeigen
        // oder eine Animation triggern
    }
}

// MARK: - Simple Status Card
struct SimpleStatusCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Simple Action Button
struct SimpleActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.orange)
                
                Text(title)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial)
            )
        }
    }
}

// MARK: - Settings Sheet
struct SettingsSheet: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    Text("⚙️ Bump Einstellungen")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Einstellungen")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    BumpView()
        .environmentObject(AuthenticationManager())
}

import SwiftUI

struct BumpView: View {
    @EnvironmentObject var appState: AppState
    
    // NEU: BLE Manager hinzufügen
    @StateObject private var bleManager = SimpleBLEManager()
    
    // Bestehende Variablen
    @State private var pulseScale: CGFloat = 1.0
    @State private var activeTime = 0
    @State private var timer: Timer?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header mit Bluetooth Status
                    VStack(spacing: 10) {
                        HStack {
                            Text("Bump Modus")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            // NEU: Bluetooth Status Anzeige
                            BluetoothStatusView(isReady: bleManager.bluetoothReady)
                            
                            Button(action: {}) {
                                Image(systemName: "info.circle")
                                    .font(.title2)
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        // NEU: BLE Aktivitäts-Anzeige
                        if bleManager.isScanning || bleManager.isAdvertising {
                            HStack(spacing: 15) {
                                if bleManager.isScanning {
                                    Label("Suche", systemImage: "antenna.radiowaves.left.and.right")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                                
                                if bleManager.isAdvertising {
                                    Label("Sende", systemImage: "dot.radiowaves.left.and.right")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Status Cards (erweitert)
                    HStack(spacing: 15) {
                        StatusCard(
                            icon: "circle.fill",
                            title: "Status",
                            value: appState.bumpMode ? "Aktiv" : "Inaktiv",
                            color: appState.bumpMode ? .green : .gray
                        )
                        
                        // NEU: Zeigt gefundene Geräte an
                        StatusCard(
                            icon: "person.2.fill",
                            title: "Gefunden",
                            value: "\(bleManager.nearbyDevices.count)",
                            color: .orange
                        )
                        
                        StatusCard(
                            icon: "clock.fill",
                            title: "Aktive Zeit",
                            value: formatTime(activeTime),
                            color: .blue
                        )
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Hauptvisualisierung (bestehend)
                    ZStack {
                        // Ringe
                        ForEach(0..<3, id: \.self) { ring in
                            Circle()
                                .stroke(
                                    appState.bumpMode ? Color.orange.opacity(0.3) : Color.gray.opacity(0.2),
                                    lineWidth: 2
                                )
                                .frame(width: 200 + CGFloat(ring * 40))
                                .scaleEffect(appState.bumpMode ? 1.0 + CGFloat(ring) * 0.1 : 1.0)
                                .opacity(appState.bumpMode ? 1.0 - Double(ring) * 0.3 : 0.5)
                                .animation(
                                    appState.bumpMode ?
                                    Animation.easeInOut(duration: 2.0)
                                        .repeatForever()
                                        .delay(Double(ring) * 0.3) :
                                    .default,
                                    value: appState.bumpMode
                                )
                        }
                        
                        // Zentraler Kreis
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: appState.bumpMode ? [.orange, .red] : [.gray, .gray.opacity(0.5)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .scaleEffect(pulseScale)
                                .shadow(
                                    color: appState.bumpMode ? .orange.opacity(0.5) : .clear,
                                    radius: 20
                                )
                            
                            Image(systemName: "location.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(height: 300)
                    
                    // NEU: Liste der gefundenen Geräte (nur wenn welche da sind)
                    if !bleManager.nearbyDevices.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Geräte in der Nähe:")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            ScrollView {
                                VStack(spacing: 4) {
                                    ForEach(bleManager.nearbyDevices, id: \.self) { device in
                                        Text(device)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .padding(.horizontal)
                                    }
                                }
                            }
                            .frame(maxHeight: 80)
                        }
                    }
                    
                    Spacer()
                    
                    // Haupt-Button (erweitert)
                    Button(action: {
                        toggleBumpMode()
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: appState.bumpMode ? "pause.fill" : "play.fill")
                                .font(.title2)
                            
                            Text(appState.bumpMode ? "Bump Stoppen" : "Bump Starten")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: getBumpButtonColors()),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(
                            color: appState.bumpMode ? .red.opacity(0.3) : .orange.opacity(0.3),
                            radius: 10
                        )
                        .disabled(!bleManager.bluetoothReady) // NEU: Deaktiviert wenn Bluetooth aus
                        .opacity(bleManager.bluetoothReady ? 1.0 : 0.6)
                    }
                    .scaleEffect(appState.bumpMode ? 0.98 : 1.0)
                    .animation(.spring(response: 0.3), value: appState.bumpMode)
                    .padding(.horizontal)
                    
                    // Quick Actions (bestehend)
                    HStack(spacing: 20) {
                        QuickActionButton(icon: "slider.horizontal.3", title: "Filter") {}
                        QuickActionButton(icon: "target", title: "Reichweite") {}
                        QuickActionButton(icon: "bolt.fill", title: "Boost") {}
                    }
                    .padding(.horizontal)
                }
            }
        }
        .onAppear {
            startPulseAnimation()
        }
        .onDisappear {
            stopTimer()
            // NEU: BLE stoppen wenn View verschwindet
            bleManager.stopScanning()
            bleManager.stopAdvertising()
        }
    }
    
    // NEU: Erweiterte toggleBumpMode Funktion
    private func toggleBumpMode() {
        withAnimation(.spring()) {
            appState.bumpMode.toggle()
            
            if appState.bumpMode {
                // Starte BLE Aktivitäten
                bleManager.startScanning()
                bleManager.startAdvertising()
                startPulseAnimation()
                startTimer()
                print("🟢 Bump Modus AKTIVIERT")
            } else {
                // Stoppe BLE Aktivitäten
                bleManager.stopScanning()
                bleManager.stopAdvertising()
                stopPulseAnimation()
                stopTimer()
                print("🔴 Bump Modus DEAKTIVIERT")
            }
        }
    }
    
    // NEU: Button Farben basierend auf Bluetooth Status
    private func getBumpButtonColors() -> [Color] {
        if !bleManager.bluetoothReady {
            return [.gray, .gray.opacity(0.8)]
        } else if appState.bumpMode {
            return [.red, .red.opacity(0.8)]
        } else {
            return [.orange, .red]
        }
    }
    
    // Bestehende Funktionen (unverändert)
    private func startPulseAnimation() {
        withAnimation(
            Animation.easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
        ) {
            pulseScale = appState.bumpMode ? 1.1 : 1.0
        }
    }
    
    private func stopPulseAnimation() {
        withAnimation(.default) {
            pulseScale = 1.0
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if appState.bumpMode {
                activeTime += 1
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

// NEU: Bluetooth Status Anzeige
struct BluetoothStatusView: View {
    let isReady: Bool
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: isReady ? "bluetooth" : "bluetooth.slash")
                .foregroundColor(isReady ? .green : .red)
                .font(.caption)
            
            Text(isReady ? "Bereit" : "Aus")
                .font(.caption2)
                .foregroundColor(isReady ? .green : .red)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background((isReady ? Color.green : Color.red).opacity(0.1))
        .cornerRadius(8)
    }
}

// Bestehende Komponenten (unverändert)
struct StatusCard: View {
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
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct QuickActionButton: View {
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
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
}

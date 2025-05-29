import SwiftUI
import CoreBluetooth
import CoreLocation

// MARK: - BLE Manager
class BLEManager: NSObject, ObservableObject {
    // Published properties for UI updates
    @Published var isScanning = false
    @Published var isAdvertising = false
    @Published var nearbyDevices: [BLEDevice] = []
    @Published var bluetoothState: CBManagerState = .unknown
    @Published var signalStrength: Int = 0
    
    // Core Bluetooth managers
    private var centralManager: CBCentralManager!
    private var peripheralManager: CBPeripheralManager!
    
    // Bumpify specific UUIDs
    private let bumpifyServiceUUID = CBUUID(string: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")
    private let bumpifyCharacteristicUUID = CBUUID(string: "E621E1F9-C36C-495A-93FC-0C247A3E6E5F")
    
    // Configuration
    private var scanTimer: Timer?
    private let scanInterval: TimeInterval = 2.0
    private let rssiThreshold = -75 // dBm for proximity detection
    
    override init() {
        super.init()
        setupBluetooth()
    }
    
    private func setupBluetooth() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Public Methods
    func startBumpMode() {
        guard bluetoothState == .poweredOn else {
            print("Bluetooth not available")
            return
        }
        
        startScanning()
        startAdvertising()
        startScanTimer()
        
        DispatchQueue.main.async {
            self.isScanning = true
            self.isAdvertising = true
        }
    }
    
    func stopBumpMode() {
        stopScanning()
        stopAdvertising()
        stopScanTimer()
        
        DispatchQueue.main.async {
            self.isScanning = false
            self.isAdvertising = false
            self.nearbyDevices.removeAll()
        }
    }
    
    // MARK: - Private Methods
    private func startScanning() {
        guard !centralManager.isScanning else { return }
        
        let scanOptions = [
            CBCentralManagerScanOptionAllowDuplicatesKey: true
        ]
        
        centralManager.scanForPeripherals(
            withServices: [bumpifyServiceUUID],
            options: scanOptions
        )
        
        print("🔍 Started BLE scanning for Bumpify devices")
    }
    
    private func stopScanning() {
        centralManager.stopScan()
        print("⏹️ Stopped BLE scanning")
    }
    
    private func startAdvertising() {
        guard peripheralManager.state == .poweredOn else { return }
        
        // Create user-specific data (simplified for demo)
        let userID = generateRotatingID()
        let userData = userID.data(using: .utf8) ?? Data()
        
        let advertisementData: [String: Any] = [
            CBAdvertisementDataServiceUUIDsKey: [bumpifyServiceUUID],
            CBAdvertisementDataLocalNameKey: "Bumpify",
            CBAdvertisementDataServiceDataKey: [bumpifyServiceUUID: userData]
        ]
        
        peripheralManager.startAdvertising(advertisementData)
        print("📡 Started BLE advertising")
    }
    
    private func stopAdvertising() {
        peripheralManager.stopAdvertising()
        print("⏹️ Stopped BLE advertising")
    }
    
    private func startScanTimer() {
        scanTimer = Timer.scheduledTimer(withTimeInterval: scanInterval, repeats: true) { _ in
            self.cleanupOldDevices()
        }
    }
    
    private func stopScanTimer() {
        scanTimer?.invalidate()
        scanTimer = nil
    }
    
    private func cleanupOldDevices() {
        let now = Date()
        nearbyDevices.removeAll { device in
            now.timeIntervalSince(device.lastSeen) > 10.0 // Remove devices not seen for 10 seconds
        }
    }
    
    private func generateRotatingID() -> String {
        // Simplified rotating ID - in production use proper cryptographic rotation
        let timestamp = Int(Date().timeIntervalSince1970 / 900) // Rotate every 15 minutes
        return "BUMP_\(timestamp)_\(UUID().uuidString.prefix(8))"
    }
    
    private func calculateDistance(from rssi: NSNumber) -> Double {
        let rssiValue = rssi.doubleValue
        let txPower = -59.0 // Measured power at 1 meter
        
        if rssiValue == 0 { return -1.0 }
        
        let ratio = (txPower - rssiValue) / 20.0
        return pow(10, ratio)
    }
}

// MARK: - CBCentralManagerDelegate
extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        DispatchQueue.main.async {
            self.bluetoothState = central.state
        }
        
        switch central.state {
        case .poweredOn:
            print("✅ Bluetooth is powered on and ready")
        case .poweredOff:
            print("❌ Bluetooth is powered off")
        case .unauthorized:
            print("❌ Bluetooth access unauthorized")
        case .unsupported:
            print("❌ Bluetooth not supported on this device")
        default:
            print("⚠️ Bluetooth state: \(central.state.rawValue)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // Filter by signal strength for proximity
        guard RSSI.intValue > rssiThreshold else { return }
        
        let distance = calculateDistance(from: RSSI)
        let deviceName = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "Unknown"
        
        // Extract user data from service data
        var userData: String = ""
        if let serviceData = advertisementData[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data],
           let data = serviceData[bumpifyServiceUUID] {
            userData = String(data: data, encoding: .utf8) ?? ""
        }
        
        let device = BLEDevice(
            id: peripheral.identifier.uuidString,
            name: deviceName,
            rssi: RSSI.intValue,
            distance: distance,
            userData: userData,
            lastSeen: Date()
        )
        
        DispatchQueue.main.async {
            // Update existing device or add new one
            if let index = self.nearbyDevices.firstIndex(where: { $0.id == device.id }) {
                self.nearbyDevices[index] = device
            } else {
                self.nearbyDevices.append(device)
                print("🎯 New Bumpify device detected: \(deviceName) at \(String(format: "%.1fm", distance))")
            }
            
            // Update signal strength indicator (strongest signal)
            self.signalStrength = self.nearbyDevices.map { $0.rssi }.max() ?? 0
        }
    }
}

// MARK: - CBPeripheralManagerDelegate
extension BLEManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("Peripheral manager state: \(peripheral.state.rawValue)")
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("❌ Failed to start advertising: \(error.localizedDescription)")
        } else {
            print("✅ Successfully started advertising")
        }
    }
}

// MARK: - BLE Device Model
struct BLEDevice: Identifiable, Equatable {
    let id: String
    let name: String
    let rssi: Int
    let distance: Double
    let userData: String
    let lastSeen: Date
    
    var signalStrengthDescription: String {
        switch rssi {
        case -50...0: return "Sehr nah"
        case -70..<(-50): return "Nah"
        case -85..<(-70): return "Mittel"
        default: return "Weit"
        }
    }
}

// MARK: - Enhanced BumpView with BLE
struct BumpView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var bleManager = BLEManager()
    @State private var pulseScale: CGFloat = 1.0
    @State private var activeTime = 0
    @State private var timer: Timer?
    @State private var showingBluetoothAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header with BLE Status
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Bump Modus")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            // BLE Status Indicator
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(bluetoothStatusColor)
                                    .frame(width: 8, height: 8)
                                
                                Text(bluetoothStatusText)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: { showingBluetoothAlert = true }) {
                            Image(systemName: "info.circle")
                                .font(.title2)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Enhanced Status Cards
                    HStack(spacing: 15) {
                        StatusCard(
                            icon: "circle.fill",
                            title: "Status",
                            value: appState.bumpMode ? "Aktiv" : "Inaktiv",
                            color: appState.bumpMode ? .green : .gray
                        )
                        
                        StatusCard(
                            icon: "person.2.fill",
                            title: "In der Nähe",
                            value: "\(bleManager.nearbyDevices.count)",
                            color: .orange
                        )
                        
                        StatusCard(
                            icon: "antenna.radiowaves.left.and.right",
                            title: "Signal",
                            value: signalStrengthText,
                            color: signalStrengthColor
                        )
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Enhanced Bump Visualization with real data
                    ZStack {
                        // Outer rings - animated based on BLE activity
                        ForEach(0..<3, id: \.self) { ring in
                            Circle()
                                .stroke(
                                    ringColor(for: ring),
                                    lineWidth: 2
                                )
                                .frame(width: 200 + CGFloat(ring * 40))
                                .scaleEffect(appState.bumpMode ? 1.0 + CGFloat(ring) * 0.1 : 1.0)
                                .opacity(ringOpacity(for: ring))
                                .animation(
                                    appState.bumpMode ?
                                    Animation.easeInOut(duration: 2.0)
                                        .repeatForever()
                                        .delay(Double(ring) * 0.3) :
                                    .default,
                                    value: appState.bumpMode
                                )
                        }
                        
                        // Show nearby devices as dots
                        ForEach(bleManager.nearbyDevices.prefix(5)) { device in
                            DeviceDot(device: device)
                                .offset(
                                    x: CGFloat.random(in: -80...80),
                                    y: CGFloat.random(in: -80...80)
                                )
                        }
                        
                        // Center orb with enhanced visual feedback
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: centerOrbColors),
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
                            
                            Image(systemName: bleManager.isScanning ? "antenna.radiowaves.left.and.right" : "location.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                        .onAppear {
                            startPulseAnimation()
                        }
                        .onChange(of: appState.bumpMode) { oldValue, newValue in
                            handleBumpModeChange(newValue)
                        }
                    }
                    .frame(height: 300)
                    
                    Spacer()
                    
                    // Enhanced Action Button
                    Button(action: {
                        withAnimation(.spring()) {
                            if bleManager.bluetoothState != .poweredOn {
                                showingBluetoothAlert = true
                                return
                            }
                            appState.bumpMode.toggle()
                        }
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
                                gradient: Gradient(colors: appState.bumpMode ? [.red, .red.opacity(0.8)] : [.orange, .red]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(
                            color: appState.bumpMode ? .red.opacity(0.3) : .orange.opacity(0.3),
                            radius: 10
                        )
                    }
                    .scaleEffect(appState.bumpMode ? 0.98 : 1.0)
                    .animation(.spring(response: 0.3), value: appState.bumpMode)
                    .padding(.horizontal)
                    
                    // Quick Actions
                    HStack(spacing: 20) {
                        QuickActionButton(icon: "slider.horizontal.3", title: "Filter") {}
                        QuickActionButton(icon: "target", title: "Reichweite") {}
                        QuickActionButton(icon: "bolt.fill", title: "Boost") {}
                    }
                    .padding(.horizontal)
                }
            }
        }
        .onDisappear {
            stopTimer()
            if appState.bumpMode {
                bleManager.stopBumpMode()
            }
        }
        .alert("Bluetooth benötigt", isPresented: $showingBluetoothAlert) {
            Button("Einstellungen") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Abbrechen", role: .cancel) { }
        } message: {
            Text("Bitte aktiviere Bluetooth in den Einstellungen, um andere Bumpify-Nutzer zu finden.")
        }
    }
    
    // MARK: - Computed Properties
    private var bluetoothStatusColor: Color {
        switch bleManager.bluetoothState {
        case .poweredOn: return .green
        case .poweredOff: return .red
        default: return .orange
        }
    }
    
    private var bluetoothStatusText: String {
        switch bleManager.bluetoothState {
        case .poweredOn: return "Bluetooth aktiv"
        case .poweredOff: return "Bluetooth aus"
        case .unauthorized: return "Keine Berechtigung"
        default: return "Bluetooth nicht verfügbar"
        }
    }
    
    private var signalStrengthText: String {
        if bleManager.signalStrength == 0 { return "---" }
        return "\(abs(bleManager.signalStrength))dBm"
    }
    
    private var signalStrengthColor: Color {
        switch abs(bleManager.signalStrength) {
        case 0..<60: return .green
        case 60..<80: return .orange
        default: return .red
        }
    }
    
    private var centerOrbColors: [Color] {
        if appState.bumpMode && bleManager.isScanning {
            return [.orange, .red]
        } else {
            return [.gray, .gray.opacity(0.5)]
        }
    }
    
    // MARK: - Helper Methods
    private func ringColor(for ring: Int) -> Color {
        if appState.bumpMode && bleManager.nearbyDevices.count > ring {
            return Color.orange.opacity(0.5)
        }
        return appState.bumpMode ? Color.orange.opacity(0.3) : Color.gray.opacity(0.2)
    }
    
    private func ringOpacity(for ring: Int) -> Double {
        if appState.bumpMode {
            return bleManager.nearbyDevices.count > ring ? 0.8 : (1.0 - Double(ring) * 0.3)
        }
        return 0.5
    }
    
    private func handleBumpModeChange(_ isActive: Bool) {
        if isActive {
            bleManager.startBumpMode()
            startPulseAnimation()
            startTimer()
        } else {
            bleManager.stopBumpMode()
            stopPulseAnimation()
            stopTimer()
        }
    }
    
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

// MARK: - Device Dot Component
struct DeviceDot: View {
    let device: BLEDevice
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.green.opacity(0.3))
                .frame(width: 20, height: 20)
                .scaleEffect(isAnimating ? 1.3 : 1.0)
                .opacity(isAnimating ? 0.0 : 1.0)
            
            Circle()
                .fill(Color.green)
                .frame(width: 12, height: 12)
        }
        .onAppear {
            withAnimation(
                Animation.easeOut(duration: 1.5)
                    .repeatForever(autoreverses: false)
            ) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Supporting Views
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

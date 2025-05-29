
// BLEManager.swift - Korrigierte Version ohne Konflikte
import CoreBluetooth
import CoreLocation
import Foundation
import Combine
import UIKit

class BumpifyBLEManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published var isScanning = false
    @Published var isAdvertising = false
    @Published var bluetoothReady = false
    @Published var bluetoothStatus = "Initialisierung..."
    @Published var nearbyUsers: [BLEDiscoveredUser] = []
    @Published var recentBumps: [BLEBumpEvent] = []
    
    // MARK: - Core Bluetooth Properties
    private var centralManager: CBCentralManager!
    private var peripheralManager: CBPeripheralManager!
    private var locationManager: CLLocationManager!
    
    // MARK: - Bumpify Protocol Constants (basierend auf Patent)
    private let bumpifyUUID = CBUUID(string: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")
    private let bumpifyServiceUUID = "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"
    
    // MARK: - User Identity & Privacy
    private var currentUserID: String = ""
    private var rotatingIDTimer: Timer?
    private var currentMajor: UInt16 = 1 // Protocol version
    private var currentMinor: UInt16 = 0 // Rotating user identifier
    
    // MARK: - Detection Logic
    private var detectionThresholdRSSI: Int = -75 // ~10 meter detection range
    private var minimumContactTime: TimeInterval = 1.0 // Minimum 1 second contact
    private var userDetectionCache: [String: BLEDiscoveredUser] = [:]
    
    // MARK: - Background Support
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    override init() {
        super.init()
        setupManagers()
        startRotatingIDTimer()
    }
    
    deinit {
        stopAll()
    }
    
    // MARK: - Setup Methods
    private func setupManagers() {
        // Central Manager für Scanning
        centralManager = CBCentralManager(
            delegate: self,
            queue: DispatchQueue.global(qos: .userInitiated),
            options: [
                CBCentralManagerOptionShowPowerAlertKey: true,
                CBCentralManagerOptionRestoreIdentifierKey: "BumpifyCentralManager"
            ]
        )
        
        // Peripheral Manager für Advertising
        peripheralManager = CBPeripheralManager(
            delegate: self,
            queue: DispatchQueue.global(qos: .userInitiated),
            options: [
                CBPeripheralManagerOptionShowPowerAlertKey: true,
                CBPeripheralManagerOptionRestoreIdentifierKey: "BumpifyPeripheralManager"
            ]
        )
        
        // Location Manager für iBeacon
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    // MARK: - Public Control Methods
    func startBumpMode(userID: String) {
        print("🚀 Starting Bump Mode for user: \(userID)")
        
        self.currentUserID = userID
        generateNewRotatingID()
        
        // Start all detection methods
        startBLEScanning()
        startBLEAdvertising()
        startBeaconMonitoring()
        startBeaconAdvertising()
        
        // Setup background support
        setupBackgroundExecution()
    }
    
    func stopBumpMode() {
        print("⏹️ Stopping Bump Mode")
        
        stopBLEScanning()
        stopBLEAdvertising()
        stopBeaconOperations()
        stopRotatingIDTimer()
        clearDetectionCache()
        
        // End background task
        endBackgroundExecution()
    }
    
    func pauseBumpMode() {
        print("⏸️ Pausing Bump Mode")
        stopBLEAdvertising()
        // Keep scanning active for detection
    }
    
    func resumeBumpMode() {
        print("▶️ Resuming Bump Mode")
        if bluetoothReady {
            startBLEAdvertising()
        }
    }
    
    // MARK: - BLE Scanning
    private func startBLEScanning() {
        guard centralManager.state == .poweredOn else {
            print("❌ Cannot start scanning - Bluetooth not ready")
            return
        }
        
        let scanOptions: [String: Any] = [
            CBCentralManagerScanOptionAllowDuplicatesKey: true,
            CBCentralManagerScanOptionSolicitedServiceUUIDsKey: [bumpifyUUID]
        ]
        
        centralManager.scanForPeripherals(
            withServices: [bumpifyUUID],
            options: scanOptions
        )
        
        isScanning = true
        bluetoothStatus = "Scanning für Bumps..."
        print("✅ BLE Scanning gestartet")
    }
    
    private func stopBLEScanning() {
        centralManager?.stopScan()
        isScanning = false
        print("⏹️ BLE Scanning gestoppt")
    }
    
    // MARK: - BLE Advertising
    private func startBLEAdvertising() {
        guard peripheralManager.state == .poweredOn else {
            print("❌ Cannot start advertising - Peripheral not ready")
            return
        }
        
        let advertisementData: [String: Any] = [
            CBAdvertisementDataServiceUUIDsKey: [bumpifyUUID],
            CBAdvertisementDataLocalNameKey: "Bumpify-\(currentMinor)",
            CBAdvertisementDataManufacturerDataKey: createManufacturerData()
        ]
        
        peripheralManager.startAdvertising(advertisementData)
        isAdvertising = true
        print("✅ BLE Advertising gestartet mit Minor: \(currentMinor)")
    }
    
    private func stopBLEAdvertising() {
        peripheralManager?.stopAdvertising()
        isAdvertising = false
        print("⏹️ BLE Advertising gestoppt")
    }
    
    // MARK: - iBeacon Operations
    private func startBeaconMonitoring() {
        guard CLLocationManager.locationServicesEnabled() else {
            print("❌ Location services not enabled")
            return
        }
        
        guard let uuid = UUID(uuidString: bumpifyServiceUUID) else {
            print("❌ Invalid UUID for beacon region")
            return
        }
        
        let beaconRegion = CLBeaconRegion(uuid: uuid, identifier: "BumpifyRegion")
        locationManager.startMonitoring(for: beaconRegion)
        
        // iOS 13+ Beacon Ranging
        if #available(iOS 13.0, *) {
            let beaconConstraint = CLBeaconIdentityConstraint(uuid: uuid)
            locationManager.startRangingBeacons(satisfying: beaconConstraint)
        }
        
        print("✅ iBeacon Monitoring gestartet")
    }
    
    private func startBeaconAdvertising() {
        guard CLLocationManager.locationServicesEnabled() else {
            print("❌ Cannot advertise beacon - Location not authorized")
            return
        }
        
        guard let uuid = UUID(uuidString: bumpifyServiceUUID) else {
            print("❌ Invalid UUID for beacon advertising")
            return
        }
        
        let beaconRegion = CLBeaconRegion(uuid: uuid, identifier: "BumpifyRegion")
        
        if let beaconData = beaconRegion.peripheralData(withMeasuredPower: nil) as? [String: Any] {
            peripheralManager.startAdvertising(beaconData)
            print("✅ iBeacon Advertising gestartet")
        }
    }
    
    private func stopBeaconOperations() {
        guard let uuid = UUID(uuidString: bumpifyServiceUUID) else { return }
        
        let beaconRegion = CLBeaconRegion(uuid: uuid, identifier: "BumpifyRegion")
        locationManager?.stopMonitoring(for: beaconRegion)
        
        if #available(iOS 13.0, *) {
            let beaconConstraint = CLBeaconIdentityConstraint(uuid: uuid)
            locationManager?.stopRangingBeacons(satisfying: beaconConstraint)
        }
        
        print("⏹️ iBeacon Operations gestoppt")
    }
    
    // MARK: - Privacy & Security (Patent-Feature)
    private func startRotatingIDTimer() {
        rotatingIDTimer = Timer.scheduledTimer(withTimeInterval: 900, repeats: true) { _ in
            self.generateNewRotatingID()
            self.restartAdvertising()
        }
    }
    
    private func stopRotatingIDTimer() {
        rotatingIDTimer?.invalidate()
        rotatingIDTimer = nil
    }
    
    private func generateNewRotatingID() {
        // Generate new rotating minor value (privacy feature from patent)
        let currentTime = Date().timeIntervalSince1970
        let timeSlot = Int(currentTime / 900) // 15-minute intervals
        let timestamp = UInt16(timeSlot % 65535)
        
        let userHashValue = abs(currentUserID.hashValue) % 65535
        let userHash = UInt16(userHashValue)
        
        currentMinor = (timestamp ^ userHash) % 65535
        
        print("🔄 Generated new rotating ID: \(currentMinor)")
    }
    
    private func restartAdvertising() {
        if isAdvertising {
            stopBLEAdvertising()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.startBLEAdvertising()
            }
        }
    }
    
    // MARK: - Manufacturer Data Creation
    private func createManufacturerData() -> Data {
        var data = Data()
        
        // Bumpify Company ID
        data.append(contentsOf: [0xFF, 0xBF])
        
        // Protocol Version
        data.append(UInt8(1))
        
        // User Mode Flags
        data.append(UInt8(0x01))
        
        // Battery Level (mock)
        data.append(UInt8(85))
        
        // Timestamp
        let timestamp = UInt32(Date().timeIntervalSince1970)
        data.append(contentsOf: withUnsafeBytes(of: timestamp.littleEndian) { Array($0) })
        
        return data
    }
    
    // MARK: - Detection Processing
    private func processDetectedDevice(
        identifier: String,
        rssi: NSNumber,
        advertisementData: [String: Any]
    ) {
        let rssiValue = rssi.intValue
        
        // Filter by RSSI threshold
        guard rssiValue >= detectionThresholdRSSI else {
            return
        }
        
        // Calculate approximate distance
        let distance = calculateDistance(rssi: rssiValue)
        
        // Extract user info from advertisement data
        let detectedUser = extractUserInfo(
            from: advertisementData,
            identifier: identifier,
            rssi: rssiValue,
            distance: distance
        )
        
        // Process bump detection
        processBumpDetection(user: detectedUser)
    }
    
    private func calculateDistance(rssi: Int) -> Double {
        let txPower = -59.0
        
        if rssi == 0 {
            return -1.0
        }
        
        let ratio = (txPower - Double(rssi)) / 20.0
        return pow(10, ratio)
    }
    
    private func extractUserInfo(
        from advertisementData: [String: Any],
        identifier: String,
        rssi: Int,
        distance: Double
    ) -> BLEDiscoveredUser {
        
        let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "Unknown"
        let services = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] ?? []
        let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data
        
        return BLEDiscoveredUser(
            id: identifier,
            name: name,
            rssi: rssi,
            distance: distance,
            firstDetected: Date(),
            lastSeen: Date(),
            services: services,
            manufacturerData: manufacturerData
        )
    }
    
    private func processBumpDetection(user: BLEDiscoveredUser) {
        let userId = user.id
        
        if let existingUser = userDetectionCache[userId] {
            // Update existing detection
            var updatedUser = BLEDiscoveredUser(
                id: user.id,
                name: user.name,
                rssi: user.rssi,
                distance: user.distance,
                firstDetected: existingUser.firstDetected,
                lastSeen: Date(),
                services: user.services,
                manufacturerData: user.manufacturerData,
                hasBumped: existingUser.hasBumped
            )
            
            userDetectionCache[userId] = updatedUser
            
            // Check if bump criteria met
            let contactDuration = Date().timeIntervalSince(existingUser.firstDetected)
            if contactDuration >= minimumContactTime && !existingUser.hasBumped {
                updatedUser.hasBumped = true
                userDetectionCache[userId] = updatedUser
                triggerBumpEvent(user: updatedUser)
            }
            
        } else {
            // New user detection
            userDetectionCache[userId] = user
        }
        
        // Update UI
        DispatchQueue.main.async {
            self.nearbyUsers = Array(self.userDetectionCache.values)
                .sorted { $0.distance < $1.distance }
        }
    }
    
    private func triggerBumpEvent(user: BLEDiscoveredUser) {
        print("🎯 BUMP DETECTED! User: \(user.name) at \(String(format: "%.1f", user.distance))m")
        
        let bumpEvent = BLEBumpEvent(
            id: UUID().uuidString,
            detectedUser: user,
            timestamp: Date(),
            location: "Current Location",
            distance: user.distance,
            duration: Date().timeIntervalSince(user.firstDetected)
        )
        
        // Add to recent bumps
        DispatchQueue.main.async {
            self.recentBumps.append(bumpEvent)
            
            // Trigger bump notification
            self.notifyBumpDetected(bumpEvent)
        }
    }
    
    private func notifyBumpDetected(_ bump: BLEBumpEvent) {
        NotificationCenter.default.post(
            name: .bumpDetected,
            object: bump
        )
    }
    
    // MARK: - Background Execution
    private func setupBackgroundExecution() {
        guard backgroundTask == .invalid else { return }
        
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "BumpifyBLE") {
            self.endBackgroundExecution()
        }
    }
    
    private func endBackgroundExecution() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    // MARK: - Utility Methods
    private func clearDetectionCache() {
        userDetectionCache.removeAll()
        DispatchQueue.main.async {
            self.nearbyUsers.removeAll()
        }
    }
    
    func stopAll() {
        stopBumpMode()
    }
}

// MARK: - CBCentralManagerDelegate
extension BumpifyBLEManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        DispatchQueue.main.async {
            switch central.state {
            case .poweredOn:
                self.bluetoothReady = true
                self.bluetoothStatus = "Bluetooth bereit"
                print("✅ Central Manager: Powered On")
                
            case .poweredOff:
                self.bluetoothReady = false
                self.bluetoothStatus = "Bluetooth ausgeschaltet"
                print("❌ Central Manager: Powered Off")
                
            case .unauthorized:
                self.bluetoothReady = false
                self.bluetoothStatus = "Bluetooth-Berechtigung fehlt"
                print("⚠️ Central Manager: Unauthorized")
                
            case .unsupported:
                self.bluetoothReady = false
                self.bluetoothStatus = "Bluetooth nicht unterstützt"
                print("❌ Central Manager: Unsupported")
                
            case .resetting:
                self.bluetoothReady = false
                self.bluetoothStatus = "Bluetooth wird zurückgesetzt"
                print("🔄 Central Manager: Resetting")
                
            case .unknown:
                self.bluetoothReady = false
                self.bluetoothStatus = "Bluetooth-Status unbekannt"
                print("❓ Central Manager: Unknown")
                
            @unknown default:
                self.bluetoothReady = false
                self.bluetoothStatus = "Unbekannter Bluetooth-Status"
                print("❓ Central Manager: Unknown default")
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("📱 Device discovered: \(peripheral.name ?? "Unknown") - RSSI: \(RSSI)")
        
        // Process the detected device
        processDetectedDevice(
            identifier: peripheral.identifier.uuidString,
            rssi: RSSI,
            advertisementData: advertisementData
        )
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        print("🔄 Central Manager restoring state")
        
        if let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] {
            for peripheral in peripherals {
                print("🔄 Restored peripheral: \(peripheral.identifier)")
            }
        }
    }
}

// MARK: - CBPeripheralManagerDelegate
extension BumpifyBLEManager: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        DispatchQueue.main.async {
            switch peripheral.state {
            case .poweredOn:
                print("✅ Peripheral Manager: Powered On")
                if !self.bluetoothReady {
                    self.bluetoothReady = true
                    self.bluetoothStatus = "Bluetooth bereit"
                }
                
            case .poweredOff:
                print("❌ Peripheral Manager: Powered Off")
                self.isAdvertising = false
                
            case .unauthorized:
                print("⚠️ Peripheral Manager: Unauthorized")
                
            case .unsupported:
                print("❌ Peripheral Manager: Unsupported")
                
            case .resetting:
                print("🔄 Peripheral Manager: Resetting")
                
            case .unknown:
                print("❓ Peripheral Manager: Unknown")
                
            @unknown default:
                print("❓ Peripheral Manager: Unknown default")
            }
        }
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("❌ Advertising error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isAdvertising = false
            }
        } else {
            print("✅ Advertising started successfully")
            DispatchQueue.main.async {
                self.isAdvertising = true
            }
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
        print("🔄 Peripheral Manager restoring state")
    }
}

// MARK: - CLLocationManagerDelegate
extension BumpifyBLEManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            print("✅ Location: Always authorized")
        case .authorizedWhenInUse:
            print("⚠️ Location: When in use authorized")
        case .denied:
            print("❌ Location: Denied")
        case .restricted:
            print("❌ Location: Restricted")
        case .notDetermined:
            print("❓ Location: Not determined")
        @unknown default:
            print("❓ Location: Unknown")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("📍 Entered Bumpify region")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("📍 Exited Bumpify region")
    }
    
    @available(iOS 13.0, *)
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        for beacon in beacons {
            print("📡 Beacon detected - Major: \(beacon.major), Minor: \(beacon.minor), RSSI: \(beacon.rssi)")
            
            // Process beacon as detected user
            processDetectedDevice(
                identifier: "beacon-\(beacon.major)-\(beacon.minor)",
                rssi: NSNumber(value: beacon.rssi),
                advertisementData: [
                    CBAdvertisementDataLocalNameKey: "Beacon-\(beacon.minor)",
                    "Major": beacon.major,
                    "Minor": beacon.minor
                ]
            )
        }
    }
}

// MARK: - BLE Data Models (eindeutige Namen)
struct BLEDiscoveredUser: Identifiable, Equatable {
    let id: String
    let name: String
    let rssi: Int
    let distance: Double
    let firstDetected: Date
    let lastSeen: Date
    let services: [CBUUID]
    let manufacturerData: Data?
    var hasBumped: Bool
    
    init(id: String, name: String, rssi: Int, distance: Double, firstDetected: Date, lastSeen: Date, services: [CBUUID], manufacturerData: Data?, hasBumped: Bool = false) {
        self.id = id
        self.name = name
        self.rssi = rssi
        self.distance = distance
        self.firstDetected = firstDetected
        self.lastSeen = lastSeen
        self.services = services
        self.manufacturerData = manufacturerData
        self.hasBumped = hasBumped
    }
    
    static func == (lhs: BLEDiscoveredUser, rhs: BLEDiscoveredUser) -> Bool {
        return lhs.id == rhs.id
    }
}

struct BLEBumpEvent: Identifiable {
    let id: String
    let detectedUser: BLEDiscoveredUser
    let timestamp: Date
    let location: String
    let distance: Double
    let duration: TimeInterval
}

// MARK: - Notification Names
extension Notification.Name {
    static let bumpDetected = Notification.Name("bumpDetected")
    static let bluetoothStateChanged = Notification.Name("bluetoothStateChanged")
}

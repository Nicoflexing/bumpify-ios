// ERSETZE deine BLEManager.swift mit diesem verbesserten Code:

import CoreBluetooth
import Foundation
import Combine

class SimpleBLEManager: NSObject, ObservableObject {
    @Published var isScanning = false
    @Published var isAdvertising = false
    @Published var nearbyDevices: [String] = []
    @Published var bluetoothReady = false
    @Published var bluetoothStatus = "Initialisierung..."
    
    private var centralManager: CBCentralManager!
    private var peripheralManager: CBPeripheralManager!
    private let serviceUUID = CBUUID(string: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")
    
    // Warteschlange für Aktionen die auf Bluetooth warten
    private var pendingActions: [() -> Void] = []
    
    override init() {
        super.init()
        print("🔧 BLE Manager wird initialisiert...")
        
        // Warte kurz bevor Bluetooth gestartet wird
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.centralManager = CBCentralManager(delegate: self, queue: nil)
            self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        }
    }
    
    func startScanning() {
        print("🔍 Scanning angefordert...")
        
        if bluetoothReady {
            print("🔍 Starte Scanning sofort...")
            performScanning()
        } else {
            print("⏳ Bluetooth nicht bereit - warte...")
            bluetoothStatus = "Warte auf Bluetooth..."
            pendingActions.append { [weak self] in
                self?.performScanning()
            }
        }
    }
    
    private func performScanning() {
        guard centralManager.state == .poweredOn else {
            print("❌ Central Manager nicht bereit: \(centralManager.state.rawValue)")
            return
        }
        
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: [
            CBCentralManagerScanOptionAllowDuplicatesKey: true
        ])
        isScanning = true
        bluetoothStatus = "Sucht Geräte..."
        print("✅ Scanning gestartet")
    }
    
    func stopScanning() {
        print("⏹️ Stoppe Scanning")
        centralManager?.stopScan()
        isScanning = false
        bluetoothStatus = bluetoothReady ? "Bereit" : "Nicht bereit"
    }
    
    func startAdvertising() {
        print("📡 Advertising angefordert...")
        
        if bluetoothReady {
            print("📡 Starte Advertising sofort...")
            performAdvertising()
        } else {
            print("⏳ Bluetooth nicht bereit - warte...")
            pendingActions.append { [weak self] in
                self?.performAdvertising()
            }
        }
    }
    
    private func performAdvertising() {
        guard peripheralManager.state == .poweredOn else {
            print("❌ Peripheral Manager nicht bereit: \(peripheralManager.state.rawValue)")
            return
        }
        
        let advertisementData: [String: Any] = [
            CBAdvertisementDataServiceUUIDsKey: [serviceUUID],
            CBAdvertisementDataLocalNameKey: "Bumpify-User"
        ]
        
        peripheralManager.startAdvertising(advertisementData)
        isAdvertising = true
        print("✅ Advertising gestartet")
    }
    
    func stopAdvertising() {
        print("📡 Stoppe Advertising")
        peripheralManager?.stopAdvertising()
        isAdvertising = false
    }
    
    // Führt wartende Aktionen aus wenn Bluetooth bereit ist
    private func executePendingActions() {
        print("🔄 Führe wartende Aktionen aus (\(pendingActions.count))")
        let actions = pendingActions
        pendingActions.removeAll()
        
        for action in actions {
            action()
        }
    }
}

// MARK: - CBCentralManagerDelegate
extension SimpleBLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("🔄 Central Manager Status: \(central.state.rawValue)")
        
        switch central.state {
        case .poweredOn:
            print("✅ Central Manager ist AN")
            checkIfFullyReady()
        case .poweredOff:
            print("❌ Bluetooth ist AUS")
            bluetoothReady = false
            bluetoothStatus = "Bluetooth aus"
        case .unauthorized:
            print("⚠️ Bluetooth Berechtigung fehlt")
            bluetoothReady = false
            bluetoothStatus = "Berechtigung fehlt"
        case .unsupported:
            print("❌ Bluetooth nicht unterstützt")
            bluetoothReady = false
            bluetoothStatus = "Nicht unterstützt"
        case .resetting:
            print("🔄 Bluetooth wird zurückgesetzt")
            bluetoothReady = false
            bluetoothStatus = "Zurücksetzung..."
        case .unknown:
            print("❓ Bluetooth Status unbekannt")
            bluetoothReady = false
            bluetoothStatus = "Unbekannt"
        @unknown default:
            print("❓ Unbekannter Bluetooth Status")
            bluetoothReady = false
            bluetoothStatus = "Fehler"
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let deviceName = peripheral.name ?? "Unbekanntes Gerät"
        let signalStrength = RSSI.intValue
        
        print("📱 Gerät gefunden: \(deviceName) - Signal: \(signalStrength)")
        
        let deviceInfo = "\(deviceName) (\(signalStrength) dBm)"
        if !nearbyDevices.contains(deviceInfo) {
            nearbyDevices.append(deviceInfo)
        }
    }
}

// MARK: - CBPeripheralManagerDelegate
extension SimpleBLEManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("🔄 Peripheral Manager Status: \(peripheral.state.rawValue)")
        
        switch peripheral.state {
        case .poweredOn:
            print("✅ Peripheral Manager ist AN")
            checkIfFullyReady()
        case .poweredOff:
            print("❌ Peripheral Manager ist AUS")
        case .unauthorized:
            print("⚠️ Peripheral Berechtigung fehlt")
        default:
            print("🔄 Peripheral Status: \(peripheral.state.rawValue)")
        }
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("❌ Advertising Fehler: \(error.localizedDescription)")
        } else {
            print("✅ Advertising erfolgreich gestartet")
        }
    }
    
    // Prüft ob beide Manager bereit sind
    private func checkIfFullyReady() {
        let centralReady = centralManager?.state == .poweredOn
        let peripheralReady = peripheralManager?.state == .poweredOn
        
        if centralReady && peripheralReady && !bluetoothReady {
            print("🎉 Bluetooth vollständig bereit!")
            bluetoothReady = true
            bluetoothStatus = "Bereit"
            executePendingActions()
        }
    }
}

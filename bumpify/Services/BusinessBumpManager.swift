// BusinessBumpManager.swift
// Neue Datei erstellen: bumpify/Services/BusinessBumpManager.swift

import Foundation
import CoreLocation
import SwiftUI
import Combine

class BusinessBumpManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published var nearbyBusinessBumps: [BusinessBump] = []
    @Published var allBusinessBumps: [BusinessBump] = []
    @Published var isScanning = false
    @Published var lastLocationUpdate = Date()
    
    // MARK: - Private Properties
    private var locationManager: CLLocationManager
    private var currentLocation: CLLocation?
    private let maxDistance: Double = 1000 // 1km Radius
    private let notificationDistance: Double = 100 // 100m für Push-Benachrichtigungen
    private var previouslyNotifiedBumps: Set<String> = []
    
    // MARK: - Notification Timer
    private var scanTimer: Timer?
    private let scanInterval: TimeInterval = 10 // Alle 10 Sekunden scannen
    
    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        
        setupLocationManager()
        loadBusinessBumps()
        startPeriodicScanning()
    }
    
    deinit {
        stopScanning()
    }
    
    // MARK: - Setup
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50 // Update bei 50m Bewegung
        
        requestLocationPermission()
    }
    
    func requestLocationPermission() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        default:
            print("❌ Location permission denied for Business Bumps")
        }
    }
    
    private func startLocationUpdates() {
        guard CLLocationManager.locationServicesEnabled() else { return }
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Business Bump Loading
    private func loadBusinessBumps() {
        // In einer echten App würden diese von einem Server kommen
        // Für jetzt verwenden wir die Sample-Daten
        allBusinessBumps = BusinessBump.sampleData
        updateNearbyBusinessBumps()
    }
    
    // MARK: - Location-based Updates
    private func updateNearbyBusinessBumps() {
        guard let currentLocation = currentLocation else {
            print("📍 No current location for Business Bump scanning")
            return
        }
        
        DispatchQueue.main.async {
            // Entfernungen aktualisieren und filtern
            self.nearbyBusinessBumps = self.allBusinessBumps.compactMap { bump in
                let bumpLocation = CLLocation(
                    latitude: bump.location.coordinate.latitude,
                    longitude: bump.location.coordinate.longitude
                )
                
                let distance = currentLocation.distance(from: bumpLocation)
                
                // Nur Bumps innerhalb des maximalen Radius
                guard distance <= self.maxDistance && bump.isActive && !bump.isExpired else {
                    return nil
                }
                
                // Bump mit aktualisierter Entfernung erstellen
                return BusinessBump(
                    id: bump.id,
                    businessName: bump.businessName,
                    businessLogo: bump.businessLogo,
                    offerTitle: bump.offerTitle,
                    offerDescription: bump.offerDescription,
                    offerType: bump.offerType,
                    validUntil: bump.validUntil,
                    location: bump.location,
                    distance: distance,
                    discount: bump.discount,
                    terms: bump.terms,
                    isActive: bump.isActive,
                    priority: bump.priority,
                    targetAudience: bump.targetAudience,
                    createdAt: bump.createdAt,
                    viewCount: bump.viewCount,
                    claimCount: bump.claimCount
                )
            }
            
            // Nach Entfernung und Priorität sortieren
            self.nearbyBusinessBumps.sort { lhs, rhs in
                // Erst nach Priorität, dann nach Entfernung
                if lhs.priority.rawValue != rhs.priority.rawValue {
                    return lhs.priority.rawValue > rhs.priority.rawValue
                }
                return lhs.distance < rhs.distance
            }
            
            self.lastLocationUpdate = Date()
            
            // Prüfe auf neue Benachrichtigungen
            self.checkForNewNotifications()
        }
    }
    
    // MARK: - Push Notifications
    private func checkForNewNotifications() {
        let closeBusinessBumps = nearbyBusinessBumps.filter { bump in
            bump.distance <= notificationDistance &&
            !previouslyNotifiedBumps.contains(bump.id) &&
            bump.priority.rawValue >= BusinessPriority.normal.rawValue
        }
        
        for bump in closeBusinessBumps {
            sendBusinessBumpNotification(bump)
            previouslyNotifiedBumps.insert(bump.id)
        }
    }
    
    private func sendBusinessBumpNotification(_ bump: BusinessBump) {
        print("🔔 Sending Business Bump notification: \(bump.offerTitle) at \(bump.businessName)")
        
        // Haptic Feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        // Post Notification für UI
        let notification = BumpNotification(
            message: "\(bump.businessName): \(bump.offerTitle)",
            type: .event,
            userName: bump.businessName,
            location: bump.location.name
        )
        
        NotificationCenter.default.post(
            name: .businessBumpDetected,
            object: notification
        )
        
        // iOS Push Notification (wenn App im Hintergrund)
        scheduleLocalNotification(for: bump)
    }
    
    private func scheduleLocalNotification(for bump: BusinessBump) {
        let content = UNMutableNotificationContent()
        content.title = "🎯 Business Bump!"
        content.body = "\(bump.businessName): \(bump.offerTitle)"
        content.sound = .default
        content.userInfo = [
            "businessBumpId": bump.id,
            "businessName": bump.businessName,
            "offerTitle": bump.offerTitle
        ]
        
        let request = UNNotificationRequest(
            identifier: "businessBump_\(bump.id)",
            content: content,
            trigger: nil // Sofort
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification: \(error)")
            }
        }
    }
    
    // MARK: - Periodic Scanning
    func startPeriodicScanning() {
        guard scanTimer == nil else { return }
        
        isScanning = true
        scanTimer = Timer.scheduledTimer(withTimeInterval: scanInterval, repeats: true) { _ in
            self.updateNearbyBusinessBumps()
        }
        
        print("✅ Started Business Bump periodic scanning")
    }
    
    func stopScanning() {
        scanTimer?.invalidate()
        scanTimer = nil
        isScanning = false
        locationManager.stopUpdatingLocation()
        
        print("⏹️ Stopped Business Bump scanning")
    }
    
    // MARK: - Public Methods
    
    /// Manuelle Aktualisierung der Business Bumps
    func refreshBusinessBumps() {
        loadBusinessBumps()
        updateNearbyBusinessBumps()
    }
    
    /// Business Bump als angesehen markieren
    func markAsViewed(_ bump: BusinessBump) {
        logBusinessBumpResponse(bump, responseType: .viewed)
    }
    
    /// Business Bump als geklickt markieren
    func markAsClicked(_ bump: BusinessBump) {
        logBusinessBumpResponse(bump, responseType: .clicked)
        
        // Optional: Haptic Feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    /// Business Bump als eingelöst markieren
    func markAsClaimed(_ bump: BusinessBump) {
        logBusinessBumpResponse(bump, responseType: .claimed)
        
        // Success Haptic Feedback
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
        
        print("✅ Business Bump claimed: \(bump.offerTitle) at \(bump.businessName)")
    }
    
    /// Business Bump teilen
    func shareBusinessBump(_ bump: BusinessBump) {
        logBusinessBumpResponse(bump, responseType: .shared)
        
        // TODO: Share-Funktionalität implementieren
        print("📤 Sharing Business Bump: \(bump.offerTitle)")
    }
    
    /// Business Bump als ignoriert markieren
    func dismissBusinessBump(_ bump: BusinessBump) {
        logBusinessBumpResponse(bump, responseType: .dismissed)
        previouslyNotifiedBumps.insert(bump.id)
    }
    
    // MARK: - Analytics
    private func logBusinessBumpResponse(_ bump: BusinessBump, responseType: BusinessBumpResponse.ResponseType) {
        let response = BusinessBumpResponse(
            bumpId: bump.id,
            userId: "current_user", // TODO: Echte User ID
            responseType: responseType,
            timestamp: Date(),
            location: currentLocation.map { BumpCoordinate(from: $0.coordinate) }
        )
        
        // TODO: An Analytics-Service senden
        print("📊 Business Bump Response: \(responseType.rawValue) for \(bump.businessName)")
    }
    
    // MARK: - Utility Methods
    
    /// Filtert Business Bumps nach Kategorie
    func getBusinessBumps(for category: BusinessCategory) -> [BusinessBump] {
        return nearbyBusinessBumps.filter { $0.location.category == category }
    }
    
    /// Filtert Business Bumps nach Angebots-Typ
    func getBusinessBumps(for offerType: BusinessOfferType) -> [BusinessBump] {
        return nearbyBusinessBumps.filter { $0.offerType == offerType }
    }
    
    /// Gibt die nächstgelegenen Business Bumps zurück
    func getClosestBusinessBumps(limit: Int = 5) -> [BusinessBump] {
        return Array(nearbyBusinessBumps.prefix(limit))
    }
    
    /// Gibt urgente Business Bumps zurück
    func getUrgentBusinessBumps() -> [BusinessBump] {
        return nearbyBusinessBumps.filter { $0.priority == .urgent }
    }
}

// MARK: - CLLocationManagerDelegate
extension BusinessBumpManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        print("📍 Business Bump Manager: Location updated to \(location.coordinate)")
        
        currentLocation = location
        updateNearbyBusinessBumps()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Business Bump Manager: Location error - \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("📍 Business Bump Manager: Authorization changed to \(status.rawValue)")
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        case .denied, .restricted:
            print("❌ Location access denied for Business Bumps")
            stopScanning()
        case .notDetermined:
            requestLocationPermission()
        @unknown default:
            break
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let businessBumpDetected = Notification.Name("businessBumpDetected")
    static let businessBumpClaimed = Notification.Name("businessBumpClaimed")
    static let businessBumpDismissed = Notification.Name("businessBumpDismissed")
}

// MARK: - Test/Demo Extensions
extension BusinessBumpManager {
    
    /// Simuliert Business Bumps für Tests
    func simulateBusinessBumpsForTesting() {
        allBusinessBumps = BusinessBump.sampleData
        
        // Simuliere aktuelle Position (Zweibrücken Zentrum)
        currentLocation = CLLocation(latitude: 49.2041, longitude: 7.3066)
        
        updateNearbyBusinessBumps()
        
        print("🧪 Simulated Business Bumps for testing")
    }
    
    /// Simuliert eine Business Bump Benachrichtigung
    func triggerTestNotification() {
        guard let testBump = nearbyBusinessBumps.first else { return }
        sendBusinessBumpNotification(testBump)
    }
}

// BumpLocationManager.swift
// Neue Datei erstellen: bumpify/Services/BumpLocationManager.swift

import CoreLocation
import Foundation
import Combine

class BumpLocationManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published var hasLocationPermission = false
    @Published var currentLocation: CLLocation?
    @Published var locationStatus = "Initialisierung..."
    @Published var isLocating = false
    
    // MARK: - Private Properties
    private let locationManager = CLLocationManager()
    private var locationCompletionHandlers: [(String?) -> Void] = []
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupLocationManager()
        checkInitialPermissions()
    }
    
    // MARK: - Setup
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Update nur bei 10m Bewegung
    }
    
    private func checkInitialPermissions() {
        updatePermissionStatus()
    }
    
    // MARK: - Public Methods
    
    /// Fordert Standort-Berechtigung an
    func requestLocationPermission() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            // User zu Einstellungen weiterleiten
            DispatchQueue.main.async {
                self.locationStatus = "Standort in Einstellungen aktivieren"
            }
        case .authorizedWhenInUse, .authorizedAlways:
            DispatchQueue.main.async {
                self.hasLocationPermission = true
                self.locationStatus = "Standort verfügbar"
            }
        @unknown default:
            break
        }
    }
    
    /// Ruft den aktuellen Standort ab
    func getCurrentLocation(completion: @escaping (String?) -> Void) {
        guard hasLocationPermission else {
            print("❌ Keine Standort-Berechtigung")
            completion(nil)
            return
        }
        
        guard CLLocationManager.locationServicesEnabled() else {
            print("❌ Standortdienste nicht aktiviert")
            completion(nil)
            return
        }
        
        // Completion Handler speichern
        locationCompletionHandlers.append(completion)
        
        // Status aktualisieren
        DispatchQueue.main.async {
            self.isLocating = true
            self.locationStatus = "Ort wird ermittelt..."
        }
        
        // Standort anfordern
        locationManager.requestLocation()
        
        // Timeout nach 10 Sekunden
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if self.isLocating {
                self.handleLocationTimeout()
            }
        }
    }
    
    /// Konvertiert CLLocation zu lesbarem Ort
    private func convertLocationToAddress(_ location: CLLocation, completion: @escaping (String?) -> Void) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("❌ Geocoding Fehler: \(error.localizedDescription)")
                completion(self.createFallbackLocationString(from: location))
                return
            }
            
            guard let placemark = placemarks?.first else {
                completion(self.createFallbackLocationString(from: location))
                return
            }
            
            let locationString = self.createLocationString(from: placemark)
            completion(locationString)
        }
    }
    
    /// Erstellt einen lesbaren Standort-String
    private func createLocationString(from placemark: CLPlacemark) -> String {
        var components: [String] = []
        
        // Name des Ortes (z.B. "Apple Store")
        if let name = placemark.name, !name.isEmpty {
            components.append(name)
        }
        
        // Straße
        if let thoroughfare = placemark.thoroughfare {
            components.append(thoroughfare)
        }
        
        // Stadt
        if let locality = placemark.locality {
            components.append(locality)
        }
        
        // Falls keine spezifischen Infos verfügbar, Fallback verwenden
        if components.isEmpty {
            if let administrativeArea = placemark.administrativeArea {
                components.append(administrativeArea)
            }
            if let country = placemark.country {
                components.append(country)
            }
        }
        
        // Maximum 3 Komponenten für bessere Lesbarkeit
        let result = components.prefix(3).joined(separator: ", ")
        return result.isEmpty ? "Unbekannter Ort" : result
    }
    
    /// Fallback-Standort bei Geocoding-Fehlern
    private func createFallbackLocationString(from location: CLLocation) -> String {
        let latitude = String(format: "%.4f", location.coordinate.latitude)
        let longitude = String(format: "%.4f", location.coordinate.longitude)
        return "Koordinaten: \(latitude), \(longitude)"
    }
    
    /// Behandelt Timeout bei Standort-Anfragen
    private func handleLocationTimeout() {
        DispatchQueue.main.async {
            self.isLocating = false
            self.locationStatus = "Standort nicht verfügbar"
        }
        
        // Alle wartenden Handler benachrichtigen
        locationCompletionHandlers.forEach { $0(nil) }
        locationCompletionHandlers.removeAll()
        
        print("⏰ Location Request Timeout")
    }
    
    /// Aktualisiert den Berechtigungsstatus
    private func updatePermissionStatus() {
        DispatchQueue.main.async {
            switch self.locationManager.authorizationStatus {
            case .notDetermined:
                self.hasLocationPermission = false
                self.locationStatus = "Berechtigung erforderlich"
            case .restricted, .denied:
                self.hasLocationPermission = false
                self.locationStatus = "Standort nicht erlaubt"
            case .authorizedWhenInUse:
                self.hasLocationPermission = true
                self.locationStatus = "Standort verfügbar"
            case .authorizedAlways:
                self.hasLocationPermission = true
                self.locationStatus = "Standort immer verfügbar"
            @unknown default:
                self.hasLocationPermission = false
                self.locationStatus = "Unbekannter Status"
            }
        }
    }
    
    // MARK: - Utility Methods
    
    /// Prüft ob eine Location "frisch" genug ist (max. 5 Minuten alt)
    private func isLocationFresh(_ location: CLLocation) -> Bool {
        let locationAge = -location.timestamp.timeIntervalSinceNow
        return locationAge < 300 // 5 Minuten
    }
    
    /// Prüft ob eine Location genau genug ist
    private func isLocationAccurate(_ location: CLLocation) -> Bool {
        return location.horizontalAccuracy < 100 // Bessere Genauigkeit als 100m
    }
}

// MARK: - CLLocationManagerDelegate
extension BumpLocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        print("📍 Standort erhalten: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        // Prüfen ob Location frisch und genau genug ist
        guard isLocationFresh(location) && isLocationAccurate(location) else {
            print("⚠️ Standort zu ungenau oder veraltet")
            return
        }
        
        DispatchQueue.main.async {
            self.currentLocation = location
            self.isLocating = false
            self.locationStatus = "Standort aktualisiert"
        }
        
        // Adresse ermitteln
        convertLocationToAddress(location) { [weak self] addressString in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                // Alle wartenden Handler benachrichtigen
                self.locationCompletionHandlers.forEach { $0(addressString) }
                self.locationCompletionHandlers.removeAll()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Standort-Fehler: \(error.localizedDescription)")
        
        DispatchQueue.main.async {
            self.isLocating = false
            self.locationStatus = "Standort-Fehler"
        }
        
        // Alle wartenden Handler mit nil benachrichtigen
        locationCompletionHandlers.forEach { $0(nil) }
        locationCompletionHandlers.removeAll()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("📍 Standort-Berechtigung geändert: \(status.rawValue)")
        updatePermissionStatus()
        
        // Bei Berechtigung ersten Standort abrufen
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.getCurrentLocation { _ in
                    // Initialer Standort abgerufen
                }
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationManager(manager, didChangeAuthorization: manager.authorizationStatus)
    }
}

// MARK: - Helper Extensions
extension CLAuthorizationStatus {
    var description: String {
        switch self {
        case .notDetermined: return "Nicht bestimmt"
        case .restricted: return "Eingeschränkt"
        case .denied: return "Verweigert"
        case .authorizedAlways: return "Immer erlaubt"
        case .authorizedWhenInUse: return "Bei Nutzung erlaubt"
        @unknown default: return "Unbekannt"
        }
    }
}

// MARK: - Test/Demo Methods
extension BumpLocationManager {
    
    /// Simuliert Standort-Abruf für Tests
    func simulateLocationForTesting() {
        let testLocations = [
            "Café Central, Hauptstraße 1, München",
            "Stadtpark, Am Park 5, Berlin",
            "Universitätsbibliothek, Campus Nord, Hamburg",
            "Murphy's Pub, Bahnhofstraße 12, Köln",
            "Fitnessstudio PowerGym, Sportplatz 3, Frankfurt"
        ]
        
        let randomLocation = testLocations.randomElement() ?? "Test Ort"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.locationCompletionHandlers.forEach { $0(randomLocation) }
            self.locationCompletionHandlers.removeAll()
            self.locationStatus = "Test-Standort: \(randomLocation)"
        }
    }
    
    /// Debug-Info für Entwicklung
    func printDebugInfo() {
        print("""
        🐛 BumpLocationManager Debug Info:
        - hasLocationPermission: \(hasLocationPermission)
        - locationStatus: \(locationStatus)
        - isLocating: \(isLocating)
        - authorizationStatus: \(locationManager.authorizationStatus.description)
        - currentLocation: \(currentLocation?.description ?? "nil")
        - pendingHandlers: \(locationCompletionHandlers.count)
        """)
    }
}

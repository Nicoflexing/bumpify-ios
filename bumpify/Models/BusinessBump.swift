// BusinessBump.swift
// Neue Datei erstellen: bumpify/Models/BusinessBump.swift

import Foundation
import SwiftUI
import CoreLocation

// MARK: - Business Bump Model
struct BusinessBump: Identifiable, Codable {
    let id: String
    let businessName: String
    let businessLogo: String?
    let offerTitle: String
    let offerDescription: String
    let offerType: BusinessOfferType
    let validUntil: Date
    let location: BusinessLocation
    let distance: Double // Entfernung in Metern
    let discount: String? // z.B. "20%", "€5", "2for1"
    let terms: String? // Bedingungen
    let isActive: Bool
    let priority: BusinessPriority
    let targetAudience: [String]? // z.B. ["students", "locals"]
    let createdAt: Date
    let viewCount: Int
    let claimCount: Int
    
    // Computed Properties
    var isExpired: Bool {
        Date() > validUntil
    }
    
    var formattedDistance: String {
        if distance < 100 {
            return "Direkt hier"
        } else if distance < 1000 {
            return "\(Int(distance))m entfernt"
        } else {
            return "\(String(format: "%.1f", distance / 1000))km entfernt"
        }
    }
    
    var timeRemaining: String {
        let now = Date()
        let interval = validUntil.timeIntervalSince(now)
        
        if interval < 0 {
            return "Abgelaufen"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) Min verbleibend"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours) Std verbleibend"
        } else {
            let days = Int(interval / 86400)
            return "\(days) Tage verbleibend"
        }
    }
    
    // Initializer
    init(id: String = UUID().uuidString,
         businessName: String,
         businessLogo: String? = nil,
         offerTitle: String,
         offerDescription: String,
         offerType: BusinessOfferType,
         validUntil: Date,
         location: BusinessLocation,
         distance: Double = 0,
         discount: String? = nil,
         terms: String? = nil,
         isActive: Bool = true,
         priority: BusinessPriority = .normal,
         targetAudience: [String]? = nil,
         createdAt: Date = Date(),
         viewCount: Int = 0,
         claimCount: Int = 0) {
        
        self.id = id
        self.businessName = businessName
        self.businessLogo = businessLogo
        self.offerTitle = offerTitle
        self.offerDescription = offerDescription
        self.offerType = offerType
        self.validUntil = validUntil
        self.location = location
        self.distance = distance
        self.discount = discount
        self.terms = terms
        self.isActive = isActive
        self.priority = priority
        self.targetAudience = targetAudience
        self.createdAt = createdAt
        self.viewCount = viewCount
        self.claimCount = claimCount
    }
}

// MARK: - Business Offer Type
enum BusinessOfferType: String, Codable, CaseIterable {
    case discount = "discount"
    case freeItem = "freeItem"
    case buyOneGetOne = "buyOneGetOne"
    case happyHour = "happyHour"
    case earlyBird = "earlyBird"
    case loyaltyReward = "loyaltyReward"
    case newCustomer = "newCustomer"
    case event = "event"
    case flash = "flash"
    case seasonal = "seasonal"
    
    var displayName: String {
        switch self {
        case .discount: return "Rabatt"
        case .freeItem: return "Gratis Item"
        case .buyOneGetOne: return "2 für 1"
        case .happyHour: return "Happy Hour"
        case .earlyBird: return "Early Bird"
        case .loyaltyReward: return "Treue-Bonus"
        case .newCustomer: return "Neukunden"
        case .event: return "Event"
        case .flash: return "Flash Sale"
        case .seasonal: return "Saisonal"
        }
    }
    
    var icon: String {
        switch self {
        case .discount: return "percent"
        case .freeItem: return "gift.fill"
        case .buyOneGetOne: return "plus.rectangle.on.rectangle"
        case .happyHour: return "clock.fill"
        case .earlyBird: return "sunrise.fill"
        case .loyaltyReward: return "star.fill"
        case .newCustomer: return "person.badge.plus"
        case .event: return "calendar"
        case .flash: return "bolt.fill"
        case .seasonal: return "leaf.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .discount: return .red
        case .freeItem: return .green
        case .buyOneGetOne: return .blue
        case .happyHour: return .orange
        case .earlyBird: return .yellow
        case .loyaltyReward: return .purple
        case .newCustomer: return .mint
        case .event: return .teal
        case .flash: return .pink
        case .seasonal: return .brown
        }
    }
}

// MARK: - Business Priority
enum BusinessPriority: Int, Codable, CaseIterable {
    case low = 1
    case normal = 2
    case high = 3
    case urgent = 4
    
    var displayName: String {
        switch self {
        case .low: return "Niedrig"
        case .normal: return "Normal"
        case .high: return "Hoch"
        case .urgent: return "Dringend"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return .gray
        case .normal: return .blue
        case .high: return .orange
        case .urgent: return .red
        }
    }
}

// MARK: - Business Location
struct BusinessLocation: Codable {
    let name: String
    let address: String
    let coordinate: BumpCoordinate
    let category: BusinessCategory
    let openingHours: [String: String]? // z.B. ["monday": "09:00-18:00"]
    let contactInfo: BusinessContact?
    
    init(name: String,
         address: String,
         coordinate: BumpCoordinate,
         category: BusinessCategory,
         openingHours: [String: String]? = nil,
         contactInfo: BusinessContact? = nil) {
        
        self.name = name
        self.address = address
        self.coordinate = coordinate
        self.category = category
        self.openingHours = openingHours
        self.contactInfo = contactInfo
    }
}

// MARK: - Business Category
enum BusinessCategory: String, Codable, CaseIterable {
    case restaurant = "restaurant"
    case cafe = "cafe"
    case bar = "bar"
    case shop = "shop"
    case fitness = "fitness"
    case beauty = "beauty"
    case entertainment = "entertainment"
    case service = "service"
    case hotel = "hotel"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .restaurant: return "Restaurant"
        case .cafe: return "Café"
        case .bar: return "Bar"
        case .shop: return "Shop"
        case .fitness: return "Fitness"
        case .beauty: return "Beauty"
        case .entertainment: return "Entertainment"
        case .service: return "Service"
        case .hotel: return "Hotel"
        case .other: return "Sonstiges"
        }
    }
    
    var icon: String {
        switch self {
        case .restaurant: return "fork.knife"
        case .cafe: return "cup.and.saucer.fill"
        case .bar: return "wineglass.fill"
        case .shop: return "bag.fill"
        case .fitness: return "dumbbell.fill"
        case .beauty: return "scissors"
        case .entertainment: return "tv.fill"
        case .service: return "wrench.and.screwdriver.fill"
        case .hotel: return "bed.double.fill"
        case .other: return "building.2.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .restaurant: return .orange
        case .cafe: return .brown
        case .bar: return .purple
        case .shop: return .blue
        case .fitness: return .red
        case .beauty: return .pink
        case .entertainment: return .green
        case .service: return .gray
        case .hotel: return .teal
        case .other: return .secondary
        }
    }
}

// MARK: - Business Contact
struct BusinessContact: Codable {
    let phone: String?
    let email: String?
    let website: String?
    let socialMedia: [String: String]? // z.B. ["instagram": "@businessname"]
}

// MARK: - Sample Data für Tests
extension BusinessBump {
    static var sampleData: [BusinessBump] {
        let now = Date()
        let tomorrow = now.addingTimeInterval(86400)
        let nextWeek = now.addingTimeInterval(604800)
        
        return [
            BusinessBump(
                businessName: "Café Central",
                businessLogo: "cup.and.saucer.fill",
                offerTitle: "Gratis Kaffee",
                offerDescription: "Bei jedem Kauf eines Gebäcks gibt's einen Kaffee gratis dazu!",
                offerType: .freeItem,
                validUntil: tomorrow,
                location: BusinessLocation(
                    name: "Café Central",
                    address: "Hauptstraße 15, Zweibrücken",
                    coordinate: BumpCoordinate(latitude: 49.2041, longitude: 7.3066),
                    category: .cafe
                ),
                distance: 150,
                discount: "Gratis",
                terms: "Pro Person nur einmal einlösbar. Gültig bis 18:00 Uhr.",
                priority: .high,
                viewCount: 234,
                claimCount: 45
            ),
            
            BusinessBump(
                businessName: "Murphy's Pub",
                businessLogo: "wineglass.fill",
                offerTitle: "Happy Hour",
                offerDescription: "Alle Getränke 20% günstiger von 17-19 Uhr!",
                offerType: .happyHour,
                validUntil: Date().addingTimeInterval(7200), // 2 Stunden
                location: BusinessLocation(
                    name: "Murphy's Pub",
                    address: "Bahnhofstraße 8, Zweibrücken",
                    coordinate: BumpCoordinate(latitude: 49.2035, longitude: 7.3070),
                    category: .bar
                ),
                distance: 320,
                discount: "20%",
                terms: "Gültig auf alle alkoholischen und alkoholfreien Getränke.",
                priority: .normal,
                viewCount: 156,
                claimCount: 28
            ),
            
            BusinessBump(
                businessName: "StyleCut Friseur",
                businessLogo: "scissors",
                offerTitle: "Neukunden-Rabatt",
                offerDescription: "25% Rabatt auf deinen ersten Haarschnitt bei uns!",
                offerType: .newCustomer,
                validUntil: nextWeek,
                location: BusinessLocation(
                    name: "StyleCut Friseur",
                    address: "Karlstraße 23, Zweibrücken",
                    coordinate: BumpCoordinate(latitude: 49.2050, longitude: 7.3080),
                    category: .beauty
                ),
                distance: 480,
                discount: "25%",
                terms: "Nur für Neukunden. Terminvereinbarung erforderlich.",
                priority: .normal,
                viewCount: 89,
                claimCount: 12
            ),
            
            BusinessBump(
                businessName: "Fitness First",
                businessLogo: "dumbbell.fill",
                offerTitle: "Probetraining",
                offerDescription: "Kostenloses Probetraining + Beratung für alle Bumpify Nutzer!",
                offerType: .freeItem,
                validUntil: nextWeek,
                location: BusinessLocation(
                    name: "Fitness First",
                    address: "Sportplatz 5, Zweibrücken",
                    coordinate: BumpCoordinate(latitude: 49.2055, longitude: 7.3055),
                    category: .fitness
                ),
                distance: 650,
                discount: "Gratis",
                terms: "Einmalig pro Person. Voranmeldung erwünscht.",
                priority: .low,
                viewCount: 67,
                claimCount: 8
            ),
            
            BusinessBump(
                businessName: "Pizza Mario",
                businessLogo: "fork.knife",
                offerTitle: "2 für 1 Pizza",
                offerDescription: "Bestelle eine Pizza und bekomme die zweite gratis dazu!",
                offerType: .buyOneGetOne,
                validUntil: Date().addingTimeInterval(3600), // 1 Stunde
                location: BusinessLocation(
                    name: "Pizza Mario",
                    address: "Italienische Straße 12, Zweibrücken",
                    coordinate: BumpCoordinate(latitude: 49.2045, longitude: 7.3065),
                    category: .restaurant
                ),
                distance: 220,
                discount: "2 für 1",
                terms: "Günstigere Pizza ist gratis. Nur vor Ort, nicht bei Lieferung.",
                priority: .urgent,
                viewCount: 345,
                claimCount: 78
            )
        ]
    }
    
    // Test-Data für verschiedene Situationen
    static var nearbyBusinessBumps: [BusinessBump] {
        return sampleData.filter { $0.distance < 500 }
    }
    
    static var activeBusinessBumps: [BusinessBump] {
        return sampleData.filter { $0.isActive && !$0.isExpired }
    }
    
    static var urgentBusinessBumps: [BusinessBump] {
        return sampleData.filter { $0.priority == .urgent }
    }
}

// MARK: - Business Bump Response (für Analytics)
struct BusinessBumpResponse: Codable {
    let bumpId: String
    let userId: String
    let responseType: ResponseType
    let timestamp: Date
    let location: BumpCoordinate?
    
    enum ResponseType: String, Codable {
        case viewed = "viewed"
        case clicked = "clicked"
        case claimed = "claimed"
        case shared = "shared"
        case dismissed = "dismissed"
    }
}

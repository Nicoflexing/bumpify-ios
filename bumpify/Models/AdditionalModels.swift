// AdditionalModels.swift - Füge das zu deinem Models Ordner hinzu
// (zusätzlich zu deiner existierenden BumpifyUser.swift)

import Foundation
import SwiftUI
import CoreLocation

// MARK: - BumpifyMessage
struct BumpifyMessage: Identifiable, Codable {
    let id: String
    let text: String
    let senderId: String
    let receiverId: String
    let timestamp: Date
    var isRead: Bool
    
    init(id: String = UUID().uuidString, text: String, senderId: String, receiverId: String, timestamp: Date = Date(), isRead: Bool = false) {
        self.id = id
        self.text = text
        self.senderId = senderId
        self.receiverId = receiverId
        self.timestamp = timestamp
        self.isRead = isRead
    }
}

// MARK: - BumpifyConversation
struct BumpifyConversation: Identifiable, Codable {
    let id: String
    let participants: [String] // User IDs
    var messages: [BumpifyMessage]
    let createdAt: Date
    var lastMessageAt: Date
    
    init(id: String = UUID().uuidString, participants: [String], messages: [BumpifyMessage] = [], createdAt: Date = Date()) {
        self.id = id
        self.participants = participants
        self.messages = messages
        self.createdAt = createdAt
        self.lastMessageAt = createdAt
    }
    
    var lastMessage: BumpifyMessage? {
        return messages.sorted { $0.timestamp > $1.timestamp }.first
    }
}

// MARK: - Bump (Begegnung)
struct Bump: Identifiable, Codable {
    let id: String
    let userId1: String
    let userId2: String
    let location: String
    let coordinate: BumpCoordinate?
    let timestamp: Date
    var isMatched: Bool
    var user1Liked: Bool
    var user2Liked: Bool
    
    init(id: String = UUID().uuidString,
         userId1: String,
         userId2: String,
         location: String,
         coordinate: BumpCoordinate? = nil,
         timestamp: Date = Date(),
         isMatched: Bool = false,
         user1Liked: Bool = false,
         user2Liked: Bool = false) {
        
        self.id = id
        self.userId1 = userId1
        self.userId2 = userId2
        self.location = location
        self.coordinate = coordinate
        self.timestamp = timestamp
        self.isMatched = isMatched
        self.user1Liked = user1Liked
        self.user2Liked = user2Liked
    }
}

// MARK: - BumpCoordinate (für Codable CLLocationCoordinate2D)
struct BumpCoordinate: Codable {
    let latitude: Double
    let longitude: Double
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(from coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    var clLocationCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Hotspot
struct Hotspot: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let location: String
    let coordinate: BumpCoordinate
    let type: HotspotType
    let createdBy: String // User ID
    let startTime: Date
    let endTime: Date
    var participantIds: [String]
    let maxParticipants: Int?
    let isActive: Bool
    
    init(id: String = UUID().uuidString,
         name: String,
         description: String,
         location: String,
         coordinate: BumpCoordinate,
         type: HotspotType,
         createdBy: String,
         startTime: Date,
         endTime: Date,
         participantIds: [String] = [],
         maxParticipants: Int? = nil,
         isActive: Bool = true) {
        
        self.id = id
        self.name = name
        self.description = description
        self.location = location
        self.coordinate = coordinate
        self.type = type
        self.createdBy = createdBy
        self.startTime = startTime
        self.endTime = endTime
        self.participantIds = participantIds
        self.maxParticipants = maxParticipants
        self.isActive = isActive
    }
    
    var participantCount: Int {
        return participantIds.count
    }
    
    var isFull: Bool {
        guard let max = maxParticipants else { return false }
        return participantIds.count >= max
    }
}

// MARK: - HotspotType
enum HotspotType: String, Codable, CaseIterable {
    case user = "user"
    case business = "business"
    
    var displayName: String {
        switch self {
        case .user: return "User Event"
        case .business: return "Business"
        }
    }
    
    var icon: String {
        switch self {
        case .user: return "person.2.fill"
        case .business: return "building.2.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .user: return .orange
        case .business: return .green
        }
    }
}

// MARK: - Sample Data Extensions
extension BumpifyConversation {
    static var preview: BumpifyConversation {
        return BumpifyConversation(
            participants: ["user1", "user2"],
            messages: [
                BumpifyMessage(text: "Hey! Schön dich kennenzulernen!", senderId: "user1", receiverId: "user2"),
                BumpifyMessage(text: "Hi! Freut mich auch! 😊", senderId: "user2", receiverId: "user1")
            ]
        )
    }
}

extension Hotspot {
    static var preview: Hotspot {
        return Hotspot(
            name: "After Work Drinks",
            description: "Entspanntes Beisammensein nach der Arbeit",
            location: "Murphy's Pub, Zweibrücken",
            coordinate: BumpCoordinate(latitude: 49.2041, longitude: 7.3066),
            type: .user,
            createdBy: "user1",
            startTime: Date().addingTimeInterval(3600),
            endTime: Date().addingTimeInterval(7200),
            maxParticipants: 8
        )
    }
}

// BumpNotification.swift
// Erstelle diese Datei: bumpify/Models/BumpNotification.swift

import Foundation
import SwiftUI

// MARK: - BumpNotification Model
struct BumpNotification: Identifiable {
    let id: String
    let message: String
    let timestamp: Date
    let type: NotificationType
    let userName: String?
    let userAvatar: String?
    let location: String?
    
    enum NotificationType {
        case newBump, match, message, event
        
        var icon: String {
            switch self {
            case .newBump: return "location.circle.fill"
            case .match: return "heart.fill"
            case .message: return "message.fill"
            case .event: return "calendar.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .newBump: return .orange
            case .match: return .pink
            case .message: return .blue
            case .event: return .purple
            }
        }
        
        var title: String {
            switch self {
            case .newBump: return "Neuer Bump"
            case .match: return "Neues Match"
            case .message: return "Neue Nachricht"
            case .event: return "Neues Event"
            }
        }
    }
    
    // Initializer
    init(id: String = UUID().uuidString,
         message: String,
         timestamp: Date = Date(),
         type: NotificationType,
         userName: String? = nil,
         userAvatar: String? = nil,
         location: String? = nil) {
        self.id = id
        self.message = message
        self.timestamp = timestamp
        self.type = type
        self.userName = userName
        self.userAvatar = userAvatar
        self.location = location
    }
}

// MARK: - Sample Data
extension BumpNotification {
    static var sampleData: [BumpNotification] {
        return [
            BumpNotification(
                message: "Lisa ist in deiner Nähe!",
                type: .newBump,
                userName: "Lisa Weber",
                location: "Café Central"
            ),
            BumpNotification(
                message: "Max möchte dich kennenlernen",
                type: .newBump,
                userName: "Max Fischer",
                location: "Stadtpark"
            ),
            BumpNotification(
                message: "Anna hat dich geliked!",
                type: .match,
                userName: "Anna Schmidt",
                location: "Bibliothek"
            ),
            BumpNotification(
                message: "Neues Event: Happy Hour",
                type: .event,
                location: "Murphy's Pub"
            ),
            BumpNotification(
                message: "Tom hat dir geschrieben",
                type: .message,
                userName: "Tom Klein"
            )
        ]
    }
}

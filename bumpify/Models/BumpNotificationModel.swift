// BumpNotificationModel.swift - Erstelle diese neue Datei in deinem Models Ordner
import Foundation

// MARK: - BumpNotification Model (einmal definiert für das ganze Projekt)
struct BumpNotification: Identifiable {
    let id: String
    let message: String
    let timestamp: Date
    let type: BumpNotificationType
    
    // Eindeutiger Name für den Enum
    enum BumpNotificationType {
        case newBump
        case match
        case message
        case event
    }
    
    // Initializer mit Standard-Werten
    init(id: String = UUID().uuidString, message: String, timestamp: Date = Date(), type: BumpNotificationType) {
        self.id = id
        self.message = message
        self.timestamp = timestamp
        self.type = type
    }
    
    // Preview-Daten für SwiftUI Previews
    static var preview: BumpNotification {
        BumpNotification(
            message: "Anna Schmidt ist in deiner Nähe!",
            type: .newBump
        )
    }
    
    // Weitere Beispiel-Daten
    static var sampleData: [BumpNotification] {
        [
            BumpNotification(
                message: "Lisa ist in deiner Nähe! 📍",
                type: .newBump
            ),
            BumpNotification(
                message: "Max möchte dich kennenlernen 👋",
                type: .match
            ),
            BumpNotification(
                message: "Anna hat dir eine Nachricht geschickt 💬",
                type: .message
            ),
            BumpNotification(
                message: "Neues Event in der Nähe: Happy Hour 🍹",
                type: .event
            )
        ]
    }
}

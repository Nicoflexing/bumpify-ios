import SwiftUI
import CoreLocation

// MARK: - User Models
struct User: Identifiable, Codable {
    let id: String
    let name: String
    let age: Int
    let interests: [String]
    let profileImage: String
    var distance: Double = 0.0
    var lastSeen: Date = Date()
}

// MARK: - Chat & Message Models
struct Conversation: Identifiable, Codable {
    let id: String
    let user: User
    let messages: [Message]
    let lastMessage: Date
}

struct Message: Identifiable, Codable {
    let id: String
    let text: String
    let isFromCurrentUser: Bool
    let timestamp: Date
}

// MARK: - Match Model
struct Match: Identifiable, Codable {
    let id: String
    let user: User
    let matchedAt: Date
    let location: String
}

// MARK: - Hotspot Model
struct Hotspot: Identifiable {
    let id: String
    let name: String
    let description: String
    let location: String
    let coordinate: CLLocationCoordinate2D
    let type: HotspotType
    let startTime: Date
    let endTime: Date
    let participantCount: Int
    let maxParticipants: Int?
    
    enum HotspotType {
        case user
        case business
        
        var color: Color {
            switch self {
            case .user: return .orange
            case .business: return .green
            }
        }
        
        var icon: String {
            switch self {
            case .user: return "person.2.fill"
            case .business: return "building.2.fill"
            }
        }
    }
}

// MARK: - App State (Globaler Zustand)
class AppState: ObservableObject {
    @Published var isLoggedIn = false
    @Published var currentUser: User?
    @Published var bumpMode = false
    @Published var nearbyUsers: [User] = []
    @Published var matches: [Match] = []
    @Published var conversations: [Conversation] = []
    @Published var hotspots: [Hotspot] = []
    
    init() {
        loadMockData()
    }
    
    private func loadMockData() {
        nearbyUsers = [
            User(id: "1", name: "Anna", age: 26, interests: ["Musik", "Reisen"], profileImage: "person.circle.fill"),
            User(id: "2", name: "Max", age: 28, interests: ["Sport", "Fotografie"], profileImage: "person.circle.fill"),
            User(id: "3", name: "Lisa", age: 24, interests: ["Kunst", "Café"], profileImage: "person.circle.fill")
        ]
        
        // Mock Conversations
        conversations = [
            Conversation(
                id: "1",
                user: nearbyUsers[0],
                messages: [
                    Message(id: "1", text: "Hey! Nette Begegnung heute!", isFromCurrentUser: false, timestamp: Date().addingTimeInterval(-3600)),
                    Message(id: "2", text: "Ja, total! Warst du auch im Café?", isFromCurrentUser: true, timestamp: Date().addingTimeInterval(-3500))
                ],
                lastMessage: Date().addingTimeInterval(-3500)
            )
        ]
        
        // Mock Matches
        matches = [
            Match(id: "1", user: nearbyUsers[0], matchedAt: Date().addingTimeInterval(-7200), location: "Zweibrücken Zentrum")
        ]
        
        // Mock Hotspots
        hotspots = [
            Hotspot(
                id: "1",
                name: "After Work Drinks",
                description: "Entspanntes Beisammensein nach der Arbeit",
                location: "Murphy's Pub",
                coordinate: CLLocationCoordinate2D(latitude: 49.2041, longitude: 7.3066),
                type: .user,
                startTime: Date().addingTimeInterval(3600),
                endTime: Date().addingTimeInterval(7200),
                participantCount: 5,
                maxParticipants: 10
            ),
            Hotspot(
                id: "2",
                name: "Happy Hour",
                description: "Spezielle Getränkepreise von 17-19 Uhr",
                location: "Stadtcafé Zweibrücken",
                coordinate: CLLocationCoordinate2D(latitude: 49.2051, longitude: 7.3076),
                type: .business,
                startTime: Date().addingTimeInterval(1800),
                endTime: Date().addingTimeInterval(5400),
                participantCount: 12,
                maxParticipants: nil
            )
        ]
    }
}

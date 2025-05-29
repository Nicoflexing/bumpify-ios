import SwiftUI
import Foundation

// MARK: - User Model
struct BumpifyUser: Identifiable, Codable, Hashable {
    let id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var profileImage: String?
    var bio: String?
    var age: Int?
    var interests: [String]
    var location: BumpifyLocation?
    var isActive: Bool
    var lastSeen: Date
    var joinedDate: Date
    
    init(
        id: UUID = UUID(),
        firstName: String,
        lastName: String,
        email: String,
        profileImage: String? = nil,
        bio: String? = nil,
        age: Int? = nil,
        interests: [String] = [],
        location: BumpifyLocation? = nil,
        isActive: Bool = false,
        lastSeen: Date = Date(),
        joinedDate: Date = Date()
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.profileImage = profileImage
        self.bio = bio
        self.age = age
        self.interests = interests
        self.location = location
        self.isActive = isActive
        self.lastSeen = lastSeen
        self.joinedDate = joinedDate
    }
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    var displayName: String {
        return firstName
    }
}

// MARK: - Location Model
struct BumpifyLocation: Codable, Hashable {
    let latitude: Double
    let longitude: Double
    let address: String?
    let city: String?
    let country: String?
    
    init(latitude: Double, longitude: Double, address: String? = nil, city: String? = nil, country: String? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.city = city
        self.country = country
    }
}

// MARK: - Match Model
struct BumpifyMatch: Identifiable, Codable, Hashable {
    let id: UUID
    let user: BumpifyUser
    let matchedAt: Date
    let location: BumpifyLocation?
    let sharedInterests: [String]
    var isRead: Bool
    var conversationId: UUID?
    
    init(
        id: UUID = UUID(),
        user: BumpifyUser,
        matchedAt: Date = Date(),
        location: BumpifyLocation? = nil,
        sharedInterests: [String] = [],
        isRead: Bool = false,
        conversationId: UUID? = nil
    ) {
        self.id = id
        self.user = user
        self.matchedAt = matchedAt
        self.location = location
        self.sharedInterests = sharedInterests
        self.isRead = isRead
        self.conversationId = conversationId
    }
}

// MARK: - Conversation Model
struct BumpifyConversation: Identifiable, Codable, Hashable {
    let id: UUID
    let participants: [BumpifyUser]
    var messages: [BumpifyMessage]
    let createdAt: Date
    var lastMessageAt: Date
    var isActive: Bool
    
    init(
        id: UUID = UUID(),
        participants: [BumpifyUser],
        messages: [BumpifyMessage] = [],
        createdAt: Date = Date(),
        lastMessageAt: Date = Date(),
        isActive: Bool = true
    ) {
        self.id = id
        self.participants = participants
        self.messages = messages
        self.createdAt = createdAt
        self.lastMessageAt = lastMessageAt
        self.isActive = isActive
    }
    
    var lastMessage: BumpifyMessage? {
        return messages.last
    }
    
    func otherParticipant(currentUserId: UUID) -> BumpifyUser? {
        return participants.first { $0.id != currentUserId }
    }
}

// MARK: - Message Model
struct BumpifyMessage: Identifiable, Codable, Hashable {
    let id: UUID
    let text: String
    let senderId: UUID
    let timestamp: Date
    var isRead: Bool
    let messageType: MessageType
    
    init(
        id: UUID = UUID(),
        text: String,
        senderId: UUID,
        timestamp: Date = Date(),
        isRead: Bool = false,
        messageType: MessageType = .text
    ) {
        self.id = id
        self.text = text
        self.senderId = senderId
        self.timestamp = timestamp
        self.isRead = isRead
        self.messageType = messageType
    }
    
    enum MessageType: String, Codable, CaseIterable {
        case text = "text"
        case image = "image"
        case system = "system"
    }
}

// MARK: - Hotspot Model
struct BumpifyHotspot: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var description: String
    let location: BumpifyLocation
    let creatorId: UUID
    let hotspotType: HotspotType
    let startTime: Date
    let endTime: Date
    var participants: [UUID]
    let maxParticipants: Int?
    var isActive: Bool
    let category: HotspotCategory
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        location: BumpifyLocation,
        creatorId: UUID,
        hotspotType: HotspotType,
        startTime: Date,
        endTime: Date,
        participants: [UUID] = [],
        maxParticipants: Int? = nil,
        isActive: Bool = true,
        category: HotspotCategory,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.location = location
        self.creatorId = creatorId
        self.hotspotType = hotspotType
        self.startTime = startTime
        self.endTime = endTime
        self.participants = participants
        self.maxParticipants = maxParticipants
        self.isActive = isActive
        self.category = category
        self.createdAt = createdAt
    }
    
    enum HotspotType: String, Codable, CaseIterable {
        case user = "user"
        case business = "business"
        
        var color: Color {
            switch self {
            case .user: return Color(red: 1.0, green: 0.4, blue: 0.2)
            case .business: return Color.green
            }
        }
        
        var icon: String {
            switch self {
            case .user: return "person.2.fill"
            case .business: return "building.2.fill"
            }
        }
    }
    
    enum HotspotCategory: String, Codable, CaseIterable {
        case social = "social"
        case dating = "dating"
        case business = "business"
        case sports = "sports"
        case culture = "culture"
        case food = "food"
        case other = "other"
        
        var displayName: String {
            switch self {
            case .social: return "Sozial"
            case .dating: return "Dating"
            case .business: return "Business"
            case .sports: return "Sport"
            case .culture: return "Kultur"
            case .food: return "Essen"
            case .other: return "Sonstiges"
            }
        }
        
        var icon: String {
            switch self {
            case .social: return "person.3.fill"
            case .dating: return "heart.fill"
            case .business: return "briefcase.fill"
            case .sports: return "figure.run"
            case .culture: return "theatermasks.fill"
            case .food: return "fork.knife"
            case .other: return "star.fill"
            }
        }
    }
    
    var participantCount: Int {
        return participants.count
    }
    
    var isFull: Bool {
        guard let max = maxParticipants else { return false }
        return participants.count >= max
    }
    
    var isHappening: Bool {
        let now = Date()
        return now >= startTime && now <= endTime && isActive
    }
}

// MARK: - Bump Event Model
struct BumpEvent: Identifiable, Codable, Hashable {
    let id: UUID
    let userId: UUID
    let detectedUserId: UUID
    let timestamp: Date
    let location: BumpifyLocation?
    let signalStrength: Double
    let duration: TimeInterval
    var isProcessed: Bool
    var resultingMatchId: UUID?
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        detectedUserId: UUID,
        timestamp: Date = Date(),
        location: BumpifyLocation? = nil,
        signalStrength: Double,
        duration: TimeInterval = 0,
        isProcessed: Bool = false,
        resultingMatchId: UUID? = nil
    ) {
        self.id = id
        self.userId = userId
        self.detectedUserId = detectedUserId
        self.timestamp = timestamp
        self.location = location
        self.signalStrength = signalStrength
        self.duration = duration
        self.isProcessed = isProcessed
        self.resultingMatchId = resultingMatchId
    }
}

// MARK: - App State Model
struct AppState: Codable {
    var hasCompletedOnboarding: Bool
    var isAuthenticated: Bool
    var isBumpModeActive: Bool
    var currentUserId: UUID?
    var lastActiveDate: Date?
    var appVersion: String
    
    init(
        hasCompletedOnboarding: Bool = false,
        isAuthenticated: Bool = false,
        isBumpModeActive: Bool = false,
        currentUserId: UUID? = nil,
        lastActiveDate: Date? = nil,
        appVersion: String = "1.0.0"
    ) {
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.isAuthenticated = isAuthenticated
        self.isBumpModeActive = isBumpModeActive
        self.currentUserId = currentUserId
        self.lastActiveDate = lastActiveDate
        self.appVersion = appVersion
    }
}

// MARK: - Notification Model
struct BumpNotification: Identifiable, Codable, Hashable {
    let id: UUID
    let userId: UUID
    let title: String
    let body: String
    let notificationType: NotificationType
    let timestamp: Date
    var isRead: Bool
    let relatedId: UUID?
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        title: String,
        body: String,
        notificationType: NotificationType,
        timestamp: Date = Date(),
        isRead: Bool = false,
        relatedId: UUID? = nil
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.body = body
        self.notificationType = notificationType
        self.timestamp = timestamp
        self.isRead = isRead
        self.relatedId = relatedId
    }
    
    enum NotificationType: String, Codable, CaseIterable {
        case bump = "bump"
        case match = "match"
        case message = "message"
        case hotspot = "hotspot"
        case system = "system"
        
        var icon: String {
            switch self {
            case .bump: return "location.circle.fill"
            case .match: return "heart.fill"
            case .message: return "message.fill"
            case .hotspot: return "mappin.circle.fill"
            case .system: return "info.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .bump: return Color(red: 1.0, green: 0.4, blue: 0.2)
            case .match: return Color.pink
            case .message: return Color.blue
            case .hotspot: return Color.green
            case .system: return Color.gray
            }
        }
    }
}

// MARK: - User Preferences Model
struct UserPreferences: Codable, Hashable {
    var ageRange: ClosedRange<Int>
    var maxDistance: Double // in kilometers
    var interests: [String]
    var lookingFor: [LookingForType]
    var notificationSettings: NotificationSettings
    var privacySettings: PrivacySettings
    
    init(
        ageRange: ClosedRange<Int> = 18...65,
        maxDistance: Double = 10.0,
        interests: [String] = [],
        lookingFor: [LookingForType] = [.friends],
        notificationSettings: NotificationSettings = NotificationSettings(),
        privacySettings: PrivacySettings = PrivacySettings()
    ) {
        self.ageRange = ageRange
        self.maxDistance = maxDistance
        self.interests = interests
        self.lookingFor = lookingFor
        self.notificationSettings = notificationSettings
        self.privacySettings = privacySettings
    }
    
    enum LookingForType: String, Codable, CaseIterable {
        case friends = "friends"
        case dating = "dating"
        case networking = "networking"
        case casual = "casual"
        
        var displayName: String {
            switch self {
            case .friends: return "Freunde"
            case .dating: return "Dating"
            case .networking: return "Networking"
            case .casual: return "Casual"
            }
        }
        
        var icon: String {
            switch self {
            case .friends: return "person.2.fill"
            case .dating: return "heart.fill"
            case .networking: return "briefcase.fill"
            case .casual: return "star.fill"
            }
        }
    }
}

// MARK: - Notification Settings Model
struct NotificationSettings: Codable, Hashable {
    var bumpsEnabled: Bool
    var matchesEnabled: Bool
    var messagesEnabled: Bool
    var hotspotsEnabled: Bool
    var systemEnabled: Bool
    var soundEnabled: Bool
    var vibrationEnabled: Bool
    
    init(
        bumpsEnabled: Bool = true,
        matchesEnabled: Bool = true,
        messagesEnabled: Bool = true,
        hotspotsEnabled: Bool = true,
        systemEnabled: Bool = true,
        soundEnabled: Bool = true,
        vibrationEnabled: Bool = true
    ) {
        self.bumpsEnabled = bumpsEnabled
        self.matchesEnabled = matchesEnabled
        self.messagesEnabled = messagesEnabled
        self.hotspotsEnabled = hotspotsEnabled
        self.systemEnabled = systemEnabled
        self.soundEnabled = soundEnabled
        self.vibrationEnabled = vibrationEnabled
    }
}

// MARK: - Privacy Settings Model
struct PrivacySettings: Codable, Hashable {
    var isProfileVisible: Bool
    var showAge: Bool
    var showLocation: Bool
    var allowBusinessBumps: Bool
    var shareAnalytics: Bool
    var invisibleMode: Bool
    
    init(
        isProfileVisible: Bool = true,
        showAge: Bool = true,
        showLocation: Bool = true,
        allowBusinessBumps: Bool = true,
        shareAnalytics: Bool = false,
        invisibleMode: Bool = false
    ) {
        self.isProfileVisible = isProfileVisible
        self.showAge = showAge
        self.showLocation = showLocation
        self.allowBusinessBumps = allowBusinessBumps
        self.shareAnalytics = shareAnalytics
        self.invisibleMode = invisibleMode
    }
}

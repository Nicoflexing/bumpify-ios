// BumpifyUser.swift - Einzige Version für den Models Ordner

import Foundation

struct BumpifyUser: Codable, Identifiable {
    let id: String
    var firstName: String
    var lastName: String
    let email: String
    var profileImageURL: String?
    var interests: [String]
    var age: Int
    var bio: String
    var location: String
    let createdAt: Date
    var lastActive: Date
    
    // Computed Properties
    var fullName: String {
        return "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }
    
    var initials: String {
        let firstInitial = firstName.first?.uppercased() ?? ""
        let lastInitial = lastName.first?.uppercased() ?? ""
        return "\(firstInitial)\(lastInitial)"
    }
    
    // Main Initializer
    init(id: String = UUID().uuidString,
         firstName: String,
         lastName: String,
         email: String,
         profileImageURL: String? = nil,
         interests: [String] = [],
         age: Int = 18,
         bio: String = "",
         location: String = "") {
        
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.profileImageURL = profileImageURL
        self.interests = interests
        self.age = age
        self.bio = bio
        self.location = location
        self.createdAt = Date()
        self.lastActive = Date()
    }
    
    // Profile completion check
    var isProfileComplete: Bool {
        return !firstName.isEmpty &&
               !lastName.isEmpty &&
               !bio.isEmpty &&
               !interests.isEmpty &&
               age >= 18 &&
               !location.isEmpty
    }
}

// MARK: - Sample Data
extension BumpifyUser {
    static var preview: BumpifyUser {
        return BumpifyUser(
            firstName: "Max",
            lastName: "Mustermann",
            email: "max@example.com",
            interests: ["Musik", "Reisen"],
            age: 25,
            bio: "Demo User",
            location: "Deutschland"
        )
    }
}

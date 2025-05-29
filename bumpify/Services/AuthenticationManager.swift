import SwiftUI
import Combine
import Foundation

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var hasCompletedOnboarding = false
    @Published var hasCompletedProfileSetup = false
    @Published var currentUser: BumpifyUser?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadPersistedState()
    }
    
    // MARK: - Persistence
    private func loadPersistedState() {
        hasCompletedOnboarding = userDefaults.bool(forKey: "hasCompletedOnboarding")
        isAuthenticated = userDefaults.bool(forKey: "isAuthenticated")
        hasCompletedProfileSetup = userDefaults.bool(forKey: "hasCompletedProfileSetup")
        
        if isAuthenticated {
            loadUserData()
        }
    }
    
    private func saveUserData() {
        if let user = currentUser,
           let userData = try? JSONEncoder().encode(user) {
            userDefaults.set(userData, forKey: "userData")
        }
    }
    
    private func loadUserData() {
        if let userData = userDefaults.data(forKey: "userData"),
           let user = try? JSONDecoder().decode(BumpifyUser.self, from: userData) {
            currentUser = user
        }
    }
    
    // MARK: - Onboarding
    func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.6)) {
            hasCompletedOnboarding = true
        }
        userDefaults.set(true, forKey: "hasCompletedOnboarding")
    }
    
    func completeProfileSetup() {
        withAnimation(.easeInOut(duration: 0.6)) {
            hasCompletedProfileSetup = true
        }
        userDefaults.set(true, forKey: "hasCompletedProfileSetup")
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
        hasCompletedProfileSetup = false
        userDefaults.set(false, forKey: "hasCompletedOnboarding")
        userDefaults.set(false, forKey: "hasCompletedProfileSetup")
    }
    
    // MARK: - Authentication
    func login(email: String, password: String) {
        guard isValidEmail(email), password.count >= 6 else {
            errorMessage = "Ungültige E-Mail oder Passwort"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let user = BumpifyUser(
                firstName: "Demo",
                lastName: "User",
                email: email
            )
            
            withAnimation(.easeInOut(duration: 0.6)) {
                self.isAuthenticated = true
                self.currentUser = user
            }
            
            self.userDefaults.set(true, forKey: "isAuthenticated")
            self.saveUserData()
            self.isLoading = false
        }
    }
    
    func register(firstName: String, lastName: String, email: String, password: String) {
        guard !firstName.isEmpty, !lastName.isEmpty,
              isValidEmail(email), password.count >= 6 else {
            errorMessage = "Bitte alle Felder korrekt ausfüllen"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let newUser = BumpifyUser(
                firstName: firstName,
                lastName: lastName,
                email: email
            )
            
            withAnimation(.easeInOut(duration: 0.6)) {
                self.isAuthenticated = true
                self.currentUser = newUser
            }
            
            self.userDefaults.set(true, forKey: "isAuthenticated")
            self.saveUserData()
            self.isLoading = false
        }
    }
    
    func logout() {
        withAnimation(.easeInOut(duration: 0.6)) {
            isAuthenticated = false
            hasCompletedProfileSetup = false
            currentUser = nil
        }
        
        userDefaults.set(false, forKey: "isAuthenticated")
        userDefaults.set(false, forKey: "hasCompletedProfileSetup")
        userDefaults.removeObject(forKey: "userData")
        clearAllUserData()
    }
    
    // MARK: - Social Authentication
    func loginWithApple() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let user = BumpifyUser(
                firstName: "Apple",
                lastName: "User",
                email: "apple.user@icloud.com"
            )
            
            withAnimation(.easeInOut(duration: 0.6)) {
                self.isAuthenticated = true
                self.currentUser = user
            }
            
            self.userDefaults.set(true, forKey: "isAuthenticated")
            self.saveUserData()
            self.isLoading = false
        }
    }
    
    func loginWithGoogle() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let user = BumpifyUser(
                firstName: "Google",
                lastName: "User",
                email: "google.user@gmail.com"
            )
            
            withAnimation(.easeInOut(duration: 0.6)) {
                self.isAuthenticated = true
                self.currentUser = user
            }
            
            self.userDefaults.set(true, forKey: "isAuthenticated")
            self.saveUserData()
            self.isLoading = false
        }
    }
    
    // MARK: - Password Reset
    func resetPassword(email: String) {
        guard isValidEmail(email) else {
            errorMessage = "Ungültige E-Mail-Adresse"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.errorMessage = "Passwort-Reset E-Mail wurde gesendet"
            self.isLoading = false
        }
    }
    
    // MARK: - Profile Management
    func updateProfile(firstName: String? = nil, lastName: String? = nil, bio: String? = nil, age: Int? = nil, interests: [String]? = nil) {
        guard var user = currentUser else { return }
        
        if let firstName = firstName { user.firstName = firstName }
        if let lastName = lastName { user.lastName = lastName }
        if let bio = bio { user.bio = bio }
        if let age = age { user.age = age }
        if let interests = interests { user.interests = interests }
        
        currentUser = user
        saveUserData()
    }
    
    func updateProfileImage(_ imageName: String) {
        guard var user = currentUser else { return }
        user.profileImage = imageName
        currentUser = user
        saveUserData()
    }
    
    // MARK: - Helper Methods
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    private func clearAllUserData() {
        let keys = [
            "userData",
            "userPreferences",
            "appState",
            "cachedMatches",
            "cachedConversations"
        ]
        
        keys.forEach { userDefaults.removeObject(forKey: $0) }
    }
    
    // MARK: - Mock Data for Development
    func createMockUser() -> BumpifyUser {
        return BumpifyUser(
            firstName: "Max",
            lastName: "Mustermann",
            email: "max@example.com",
            bio: "Ich liebe es, neue Menschen kennenzulernen!",
            age: 28,
            interests: ["Reisen", "Musik", "Sport", "Kaffee"]
        )
    }
    
    func getCurrentUserId() -> UUID? {
        return currentUser?.id
    }
    
    func isCurrentUser(_ userId: UUID) -> Bool {
        return currentUser?.id == userId
    }
    
    // MARK: - Error Handling
    func clearError() {
        errorMessage = nil
    }
    
    func showError(_ message: String) {
        errorMessage = message
    }
}

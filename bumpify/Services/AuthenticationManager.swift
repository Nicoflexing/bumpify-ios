// AuthenticationManager.swift - Komplett mit korrigierter Syntax

import SwiftUI
import Combine

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var hasCompletedOnboarding = false
    @Published var hasCompletedProfileSetup = false
    @Published var currentUser: BumpifyUser?
    @Published var isLoading = false
    
    init() {
        // Für Demo: Immer mit sauberem Slate starten
        // Kommentiere diese Zeilen aus, wenn du den gespeicherten Status behalten willst:
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(false, forKey: "hasCompletedProfileSetup")
        UserDefaults.standard.removeObject(forKey: "currentUser")
        
        // Load actual values
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        hasCompletedProfileSetup = UserDefaults.standard.bool(forKey: "hasCompletedProfileSetup")
        
        // Load saved user if exists
        loadCurrentUser()
    }
    
    // MARK: - Authentication Methods
    func login(email: String, password: String) {
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            
            // Mock successful login
            let user = BumpifyUser(
                id: UUID().uuidString,
                firstName: "Max",
                lastName: "Mustermann",
                email: email,
                profileImageURL: nil,
                interests: ["Musik", "Reisen", "Sport"],
                age: 25,
                bio: "Immer auf der Suche nach neuen Abenteuern!",
                location: "Zweibrücken, Deutschland"
            )
            
            self.currentUser = user
            self.isAuthenticated = true
            // NACH LOGIN: Onboarding noch nicht abgeschlossen
            self.hasCompletedOnboarding = false
            self.hasCompletedProfileSetup = false
            
            // Save to UserDefaults
            self.saveCurrentUser(user)
            UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
            UserDefaults.standard.set(false, forKey: "hasCompletedProfileSetup")
        }
    }
    
    func signUp(firstName: String, lastName: String, email: String, password: String) {
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isLoading = false
            
            // Mock successful sign up
            let user = BumpifyUser(
                id: UUID().uuidString,
                firstName: firstName,
                lastName: lastName,
                email: email,
                profileImageURL: nil,
                interests: [],
                age: 25,
                bio: "",
                location: ""
            )
            
            self.currentUser = user
            self.isAuthenticated = true
            // NACH REGISTER: Onboarding noch nicht abgeschlossen
            self.hasCompletedOnboarding = false
            self.hasCompletedProfileSetup = false
            
            // Save to UserDefaults
            self.saveCurrentUser(user)
            UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
            UserDefaults.standard.set(false, forKey: "hasCompletedProfileSetup")
        }
    }
    
    func loginWithApple() {
        isLoading = true
        
        // Simulate Apple Sign In
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            
            let user = BumpifyUser(
                id: UUID().uuidString,
                firstName: "Apple",
                lastName: "User",
                email: "apple.user@example.com",
                profileImageURL: nil,
                interests: ["Tech", "Design"],
                age: 28,
                bio: "Apple Sign In User",
                location: "Deutschland"
            )
            
            self.currentUser = user
            self.isAuthenticated = true
            // NACH APPLE LOGIN: Onboarding noch nicht abgeschlossen
            self.hasCompletedOnboarding = false
            self.hasCompletedProfileSetup = false
            
            self.saveCurrentUser(user)
            UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
            UserDefaults.standard.set(false, forKey: "hasCompletedProfileSetup")
        }
    }
    
    func loginWithGoogle() {
        isLoading = true
        
        // Simulate Google Sign In
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            
            let user = BumpifyUser(
                id: UUID().uuidString,
                firstName: "Google",
                lastName: "User",
                email: "google.user@gmail.com",
                profileImageURL: nil,
                interests: ["Tech", "Innovation"],
                age: 26,
                bio: "Google Sign In User",
                location: "Deutschland"
            )
            
            self.currentUser = user
            self.isAuthenticated = true
            // NACH GOOGLE LOGIN: Onboarding noch nicht abgeschlossen
            self.hasCompletedOnboarding = false
            self.hasCompletedProfileSetup = false
            
            self.saveCurrentUser(user)
            UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
            UserDefaults.standard.set(false, forKey: "hasCompletedProfileSetup")
        }
    }
    
    func signUpWithApple() {
        loginWithApple() // Same implementation for demo
    }
    
    func signUpWithGoogle() {
        loginWithGoogle() // Same implementation for demo
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
        hasCompletedOnboarding = false
        hasCompletedProfileSetup = false
        
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(false, forKey: "hasCompletedProfileSetup")
    }
    
    func deleteAccount() {
        // Simulate account deletion
        currentUser = nil
        isAuthenticated = false
        hasCompletedOnboarding = false
        hasCompletedProfileSetup = false
        
        // Clear all UserDefaults
        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(false, forKey: "hasCompletedProfileSetup")
    }
    
    // MARK: - Onboarding Methods
    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        print("✅ Onboarding completed - moving to Profile Setup")
    }
    
    func completeProfileSetup() {
        hasCompletedProfileSetup = true
        UserDefaults.standard.set(true, forKey: "hasCompletedProfileSetup")
        print("✅ Profile Setup completed - moving to Main App")
    }
    
    // MARK: - User Data Management
    private func saveCurrentUser(_ user: BumpifyUser) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
    }
    
    private func loadCurrentUser() {
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(BumpifyUser.self, from: userData) {
            currentUser = user
            isAuthenticated = true
        }
    }
    
    // MARK: - Profile Update Methods
    func updateProfile(firstName: String, lastName: String, bio: String, interests: [String]) {
        guard var user = currentUser else { return }
        
        user.firstName = firstName
        user.lastName = lastName
        user.bio = bio
        user.interests = interests
        
        currentUser = user
        saveCurrentUser(user)
    }
    
    func updateLocation(_ location: String) {
        guard var user = currentUser else { return }
        user.location = location
        currentUser = user
        saveCurrentUser(user)
    }
    
    func updateAge(_ age: Int) {
        guard var user = currentUser else { return }
        user.age = age
        currentUser = user
        saveCurrentUser(user)
    }
    
    // MARK: - Debug Methods
    func resetApp() {
        print("🔄 Resetting app to initial state")
        currentUser = nil
        isAuthenticated = false
        hasCompletedOnboarding = false
        hasCompletedProfileSetup = false
        
        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(false, forKey: "hasCompletedProfileSetup")
    }
    
    func getCurrentState() -> String {
        return """
        🔍 Current Auth State:
        - isAuthenticated: \(isAuthenticated)
        - hasCompletedOnboarding: \(hasCompletedOnboarding)
        - hasCompletedProfileSetup: \(hasCompletedProfileSetup)
        - currentUser: \(currentUser?.fullName ?? "None")
        """
    }
}

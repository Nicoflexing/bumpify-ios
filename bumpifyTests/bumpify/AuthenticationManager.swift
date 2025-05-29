import SwiftUI
import Combine

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var hasCompletedOnboarding = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        // Check if user has completed onboarding
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
        
        // Load user data if authenticated
        if isAuthenticated {
            loadUserData()
        }
    }
    
    // MARK: - Onboarding
    func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.6)) {
            hasCompletedOnboarding = true
        }
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
    }
    
    // MARK: - Authentication
    func login(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Mock authentication logic
            if self.isValidEmail(email) && password.count >= 6 {
                withAnimation(.easeInOut(duration: 0.6)) {
                    self.isAuthenticated = true
                    self.currentUser = User(
                        id: UUID(),
                        firstName: "Demo",
                        lastName: "User",
                        email: email,
                        profileImage: nil
                    )
                }
                UserDefaults.standard.set(true, forKey: "isAuthenticated")
                self.saveUserData()
            } else {
                self.errorMessage = "Ungültige E-Mail oder Passwort"
            }
            self.isLoading = false
        }
    }
    
    func register(firstName: String, lastName: String, email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Mock registration logic
            if self.isValidEmail(email) && password.count >= 6 && !firstName.isEmpty && !lastName.isEmpty {
                let newUser = User(
                    id: UUID(),
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    profileImage: nil
                )
                
                withAnimation(.easeInOut(duration: 0.6)) {
                    self.isAuthenticated = true
                    self.currentUser = newUser
                }
                UserDefaults.standard.set(true, forKey: "isAuthenticated")
                self.saveUserData()
            } else {
                self.errorMessage = "Bitte alle Felder korrekt ausfüllen"
            }
            self.isLoading = false
        }
    }
    
    func logout() {
        withAnimation(.easeInOut(duration: 0.6)) {
            isAuthenticated = false
            currentUser = nil
        }
        UserDefaults.standard.set(false, forKey: "isAuthenticated")
        UserDefaults.standard.removeObject(forKey: "userData")
    }
    
    // MARK: - Social Authentication
    func loginWithApple() {
        isLoading = true
        
        // Simulate Apple Sign In
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.6)) {
                self.isAuthenticated = true
                self.currentUser = User(
                    id: UUID(),
                    firstName: "Apple",
                    lastName: "User",
                    email: "apple.user@example.com",
                    profileImage: nil
                )
            }
            UserDefaults.standard.set(true, forKey: "isAuthenticated")
            self.saveUserData()
            self.isLoading = false
        }
    }
    
    func loginWithGoogle() {
        isLoading = true
        
        // Simulate Google Sign In
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.6)) {
                self.isAuthenticated = true
                self.currentUser = User(
                    id: UUID(),
                    firstName: "Google",
                    lastName: "User",
                    email: "google.user@example.com",
                    profileImage: nil
                )
            }
            UserDefaults.standard.set(true, forKey: "isAuthenticated")
            self.saveUserData()
            self.isLoading = false
        }
    }
    
    // MARK: - Password Reset
    func resetPassword(email: String) {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.isValidEmail(email) {
                // Show success message
                self.errorMessage = "Passwort-Reset E-Mail wurde gesendet"
            } else {
                self.errorMessage = "Ungültige E-Mail-Adresse"
            }
            self.isLoading = false
        }
    }
    
    // MARK: - Helper Methods
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    private func saveUserData() {
        if let user = currentUser,
           let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: "userData")
        }
    }
    
    private func loadUserData() {
        if let userData = UserDefaults.standard.data(forKey: "userData"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
        }
    }
}

// MARK: - User Model
struct User: Codable, Identifiable {
    let id: UUID
    let firstName: String
    let lastName: String
    let email: String
    let profileImage: String?
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
}

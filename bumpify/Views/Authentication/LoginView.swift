// Debug-Version der LoginView - Teste das mal

import SwiftUI

struct DebugLoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var email = "test@test.de"
    @State private var password = "123456"
    @State private var isLogin = true
    
    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.09, blue: 0.13).ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("🐛 DEBUG LOGIN")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                // Debug Info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Auth State:")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("isAuthenticated: \(authManager.isAuthenticated ? "✅" : "❌")")
                        .foregroundColor(.gray)
                    
                    Text("hasCompletedOnboarding: \(authManager.hasCompletedOnboarding ? "✅" : "❌")")
                        .foregroundColor(.gray)
                    
                    Text("hasCompletedProfileSetup: \(authManager.hasCompletedProfileSetup ? "✅" : "❌")")
                        .foregroundColor(.gray)
                    
                    Text("currentUser: \(authManager.currentUser?.fullName ?? "None")")
                        .foregroundColor(.gray)
                    
                    Text("isLoading: \(authManager.isLoading ? "⏳" : "🔴")")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                
                // Simple Login Form
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("🚀 DIRECT LOGIN (Debug)") {
                        print("🐛 Direct login button pressed")
                        
                        // Direkte State-Änderung für Debug
                        authManager.isAuthenticated = true
                        authManager.hasCompletedOnboarding = false
                        authManager.hasCompletedProfileSetup = false
                        
                        // Erstelle einen Test-User
                        let testUser = BumpifyUser(
                            firstName: "Test",
                            lastName: "User",
                            email: email,
                            interests: ["Debug", "Testing"],
                            age: 25,
                            bio: "Debug Test User",
                            location: "Test Stadt"
                        )
                        authManager.currentUser = testUser
                        
                        print("🐛 Auth state changed - should navigate now")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
                    
                    Button("📞 Call AuthManager.login()") {
                        print("🐛 Calling authManager.login()")
                        authManager.login(email: email, password: password)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(12)
                    
                    Button("🔄 Reset All States") {
                        print("🐛 Resetting all states")
                        authManager.resetApp()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(12)
                }
                .padding()
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            print("🐛 LoginView appeared")
            print("🐛 Current auth state: \(authManager.getCurrentState())")
        }
    }
}

#Preview {
    DebugLoginView()
        .environmentObject(AuthenticationManager())
}

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false
    @State private var showingSignUp = false
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 0.05, green: 0.05, blue: 0.1), location: 0.0),
                    .init(color: Color(red: 0.1, green: 0.1, blue: 0.15), location: 0.5),
                    .init(color: Color(red: 0.05, green: 0.05, blue: 0.1), location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: 80)
                    
                    // Logo Section
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 1.0, green: 0.4, blue: 0.2),
                                            Color(red: 1.0, green: 0.6, blue: 0.0)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .shadow(color: Color(red: 1.0, green: 0.4, blue: 0.2).opacity(0.4), radius: 25, x: 0, y: 12)
                            
                            Image(systemName: "location.circle.fill")
                                .font(.system(size: 42, weight: .medium))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 12) {
                            Text("bumpify")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Willkommen zurück!")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.7))
                            
                            Text("Melde dich an, um echte Begegnungen zu entdecken")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(Color.white.opacity(0.5))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 10)
                        }
                    }
                    
                    Spacer().frame(height: 60)
                    
                    // Login Form
                    VStack(spacing: 24) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("E-Mail")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color.white.opacity(0.9))
                            
                            HStack(spacing: 12) {
                                Image(systemName: "envelope")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color.white.opacity(0.6))
                                    .frame(width: 20)
                                
                                TextField("deine@email.com", text: $email)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                    .disableAutocorrection(true)
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                email.isEmpty ? Color.white.opacity(0.15) : Color.orange.opacity(0.5),
                                                lineWidth: 1.5
                                            )
                                    )
                            )
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Passwort")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color.white.opacity(0.9))
                            
                            HStack(spacing: 12) {
                                Image(systemName: "lock")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color.white.opacity(0.6))
                                    .frame(width: 20)
                                
                                SecureField("Dein Passwort", text: $password)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                password.isEmpty ? Color.white.opacity(0.15) : Color.orange.opacity(0.5),
                                                lineWidth: 1.5
                                            )
                                    )
                            )
                        }
                        
                        // Remember Me & Forgot Password
                        HStack {
                            Button(action: { rememberMe.toggle() }) {
                                HStack(spacing: 10) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(rememberMe ? Color.orange : Color.white.opacity(0.4), lineWidth: 2)
                                            .frame(width: 20, height: 20)
                                        
                                        if rememberMe {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.orange)
                                                .frame(width: 12, height: 12)
                                            
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    
                                    Text("Angemeldet bleiben")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(Color.white.opacity(0.8))
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Text("Passwort vergessen?")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color.orange)
                            }
                        }
                        
                        Spacer().frame(height: 16)
                        
                        // Login Button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.6)) {
                                appState.isLoggedIn = true
                            }
                        }) {
                            HStack(spacing: 12) {
                                Text("Anmelden")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.4, blue: 0.2),
                                        Color(red: 1.0, green: 0.6, blue: 0.0)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color(red: 1.0, green: 0.4, blue: 0.2).opacity(0.4), radius: 15, x: 0, y: 8)
                            .scaleEffect(email.isEmpty || password.isEmpty ? 0.98 : 1.0)
                            .opacity(email.isEmpty || password.isEmpty ? 0.7 : 1.0)
                        }
                        .disabled(email.isEmpty || password.isEmpty)
                        
                        // Divider with "oder"
                        HStack {
                            Rectangle()
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 1)
                            
                            Text("oder")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.6))
                                .padding(.horizontal, 20)
                            
                            Rectangle()
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 1)
                        }
                        .padding(.vertical, 8)
                        
                        // Social Login Buttons
                        VStack(spacing: 14) {
                            // Apple Login
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.6)) {
                                    appState.isLoggedIn = true
                                }
                            }) {
                                HStack(spacing: 14) {
                                    Image(systemName: "apple.logo")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    Text("Mit Apple anmelden")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.08))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                        )
                                )
                            }
                            
                            // Google Login
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.6)) {
                                    appState.isLoggedIn = true
                                }
                            }) {
                                HStack(spacing: 14) {
                                    Image(systemName: "globe")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    Text("Mit Google anmelden")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.08))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                        )
                                )
                            }
                        }
                        
                        Spacer().frame(height: 32)
                        
                        // Sign Up Link
                        HStack(spacing: 6) {
                            Text("Noch kein Konto?")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.7))
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.5)) {
                                    showingSignUp = true
                                }
                            }) {
                                Text("Registrieren")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color.orange)
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer().frame(height: 50)
                }
            }
        }
        .fullScreenCover(isPresented: $showingSignUp) {
            SignUpView()
        }
    }
}

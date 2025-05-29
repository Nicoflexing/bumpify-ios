// SignUpView.swift - Ersetze deine SignUpView komplett

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var agreedToTerms = false
    @State private var isLoading = false
    
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
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.08))
                                )
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 20)
                    
                    Spacer().frame(height: 40)
                    
                    // Logo Section
                    VStack(spacing: 16) {
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
                                .frame(width: 60, height: 60)
                                .shadow(color: Color(red: 1.0, green: 0.4, blue: 0.2).opacity(0.3), radius: 15, x: 0, y: 8)
                            
                            Image(systemName: "location.circle.fill")
                                .font(.system(size: 28, weight: .medium))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Konto erstellen")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Tritt der bumpify Community bei")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.6))
                        }
                    }
                    
                    Spacer().frame(height: 40)
                    
                    // Sign Up Form
                    VStack(spacing: 20) {
                        // Name Fields
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Vorname")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color.white.opacity(0.8))
                                
                                TextField("Max", text: $firstName)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.08))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                            )
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Nachname")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color.white.opacity(0.8))
                                
                                TextField("Mustermann", text: $lastName)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.08))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                            )
                                    )
                            }
                        }
                        
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("E-Mail")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.8))
                            
                            HStack(spacing: 12) {
                                Image(systemName: "envelope")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color.white.opacity(0.5))
                                    .frame(width: 20)
                                
                                TextField("deine@email.com", text: $email)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                    )
                            )
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Passwort")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.8))
                            
                            HStack(spacing: 12) {
                                Image(systemName: "lock")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color.white.opacity(0.5))
                                    .frame(width: 20)
                                
                                SecureField("Mindestens 8 Zeichen", text: $password)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                    )
                            )
                        }
                        
                        // Confirm Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Passwort bestätigen")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.8))
                            
                            HStack(spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color.white.opacity(0.5))
                                    .frame(width: 20)
                                
                                SecureField("Passwort wiederholen", text: $confirmPassword)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(password != confirmPassword && !confirmPassword.isEmpty ? Color.red.opacity(0.5) : Color.white.opacity(0.12), lineWidth: 1)
                                    )
                            )
                        }
                        
                        // Terms Agreement
                        Button(action: { agreedToTerms.toggle() }) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(agreedToTerms ? Color(red: 1.0, green: 0.5, blue: 0.1) : Color.white.opacity(0.5))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Ich akzeptiere die ")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color.white.opacity(0.7)) +
                                    Text("Nutzungsbedingungen")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.1)) +
                                    Text(" und die ")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color.white.opacity(0.7)) +
                                    Text("Datenschutzerklärung")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.1))
                                }
                                
                                Spacer()
                            }
                        }
                        .padding(.top, 8)
                        
                        Spacer().frame(height: 8)
                        
                        // Sign Up Button
                        Button(action: {
                            isLoading = true
                            authManager.signUp(
                                firstName: firstName,
                                lastName: lastName,
                                email: email,
                                password: password
                            )
                            isLoading = false
                        }) {
                            HStack(spacing: 8) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Konto erstellen")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
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
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: Color(red: 1.0, green: 0.4, blue: 0.2).opacity(0.3), radius: 12, x: 0, y: 6)
                        }
                        .disabled(!isFormValid || isLoading)
                        .opacity((!isFormValid || isLoading) ? 0.6 : 1.0)
                        
                        // Divider with "oder"
                        HStack {
                            Rectangle()
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 1)
                            
                            Text("oder")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.5))
                                .padding(.horizontal, 16)
                            
                            Rectangle()
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 1)
                        }
                        
                        // Social Sign Up Buttons
                        VStack(spacing: 12) {
                            // Apple Sign Up
                            Button(action: {
                                authManager.signUpWithApple()
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "apple.logo")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    Text("Mit Apple registrieren")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.08))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                        )
                                )
                            }
                            
                            // Google Sign Up
                            Button(action: {
                                authManager.signUpWithGoogle()
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "globe")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    Text("Mit Google registrieren")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.08))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                        )
                                )
                            }
                        }
                        
                        Spacer().frame(height: 24)
                        
                        // Login Link
                        HStack(spacing: 4) {
                            Text("Bereits ein Konto?")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.7))
                            
                            Button(action: { dismiss() }) {
                                Text("Anmelden")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.1))
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer().frame(height: 40)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 8 &&
        agreedToTerms
    }
}

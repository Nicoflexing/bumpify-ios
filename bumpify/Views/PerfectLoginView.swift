// PerfectLoginView.swift - NEUE DATEI ERSTELLEN
import SwiftUI

struct PerfectLoginView: View {
    let onLoginSuccess: () -> Void
    @State private var showRegister = false
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    
    var body: some View {
        ZStack {
            // Exakter Hintergrund wie Figma
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 0.08, green: 0.08, blue: 0.12), location: 0.0),
                    .init(color: Color(red: 0.04, green: 0.04, blue: 0.08), location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Status Bar Bereich
                Spacer().frame(height: 60)
                
                // Bumpify Logo - exakt wie Figma
                Text("bumpify")
                    .font(.custom("SF Pro Display", size: 36))
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.4, blue: 0.2),
                                Color(red: 1.0, green: 0.6, blue: 0.0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Spacer().frame(height: 16)
                
                // Untertitel
                Text("Verbinde dich mit Menschen um dich herum")
                    .font(.system(size: 16))
                    .foregroundColor(Color.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer().frame(height: 40)
                
                // Toggle Buttons - exakt wie Figma mit echten Gradients
                HStack(spacing: 0) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showRegister = false
                        }
                    }) {
                        Text("Anmelden")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(showRegister ? Color.white.opacity(0.6) : Color.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                Group {
                                    if !showRegister {
                                        LinearGradient(
                                            colors: [Color.orange, Color.red],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    } else {
                                        Color.clear
                                    }
                                }
                            )
                            .cornerRadius(25)
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showRegister = true
                        }
                    }) {
                        Text("Registrieren")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(!showRegister ? Color.white.opacity(0.6) : Color.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                Group {
                                    if showRegister {
                                        LinearGradient(
                                            colors: [Color.orange, Color.red],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    } else {
                                        Color.clear
                                    }
                                }
                            )
                            .cornerRadius(25)
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer().frame(height: 40)
                
                // Form Fields - exakt wie Figma
                VStack(spacing: 20) {
                    // E-Mail Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("E-mail")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 12) {
                            Image(systemName: "envelope")
                                .font(.system(size: 16))
                                .foregroundColor(Color.white.opacity(0.5))
                                .frame(width: 20)
                            
                            TextField("ex. yourname@gmail.com", text: $email)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    }
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 12) {
                            Image(systemName: "key")
                                .font(.system(size: 16))
                                .foregroundColor(Color.white.opacity(0.5))
                                .frame(width: 20)
                            
                            if showPassword {
                                TextField(showRegister ? "Type your password here" : "dein Passwort hier", text: $password)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                            } else {
                                SecureField(showRegister ? "Type your password here" : "dein Passwort hier", text: $password)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                            }
                            
                            Button(action: {
                                showPassword.toggle()
                            }) {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.white.opacity(0.5))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    }
                    
                    // Password bestätigen (nur bei Register)
                    if showRegister {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password bestätigen")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "key")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.white.opacity(0.5))
                                    .frame(width: 20)
                                
                                if showConfirmPassword {
                                    TextField("Type your password here", text: $confirmPassword)
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                } else {
                                    SecureField("Type your password here", text: $confirmPassword)
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                }
                                
                                Button(action: {
                                    showConfirmPassword.toggle()
                                }) {
                                    Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color.white.opacity(0.5))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, 32)
                
                // Forgot Password (nur bei Login)
                if !showRegister {
                    HStack {
                        Spacer()
                        Button("Forget Password?") {
                            // Forgot Password Action
                        }
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.6))
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 16)
                }
                
                Spacer().frame(height: 40)
                
                // Continue Button - mit echtem Gradient
                Button(action: {
                    onLoginSuccess()
                }) {
                    HStack(spacing: 8) {
                        Text("Continue")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
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
                    .cornerRadius(12)
                    .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 32)
                
                Spacer().frame(height: 32)
                
                // Divider mit "oder"
                HStack {
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 1)
                    
                    Text("oder")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.5))
                        .padding(.horizontal, 16)
                    
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 1)
                }
                .padding(.horizontal, 32)
                
                Spacer().frame(height: 32)
                
                // Social Login Buttons - exakt wie Figma
                VStack(spacing: 16) {
                    // Google Button
                    Button(action: { onLoginSuccess() }) {
                        HStack(spacing: 12) {
                            Image(systemName: "globe")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                            
                            Text("Sign up with Google")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    }
                    
                    // Apple Button
                    Button(action: { onLoginSuccess() }) {
                        HStack(spacing: 12) {
                            Image(systemName: "apple.logo")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                            
                            Text("Sign up with Apple")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Business Icon & Terms - exakt wie Figma
                VStack(spacing: 12) {
                    Image(systemName: "building.2")
                        .font(.system(size: 16))
                        .foregroundColor(Color.white.opacity(0.4))
                    
                    HStack {
                        Text("Indem du fortfährst, stimmst du unseren ")
                            .font(.system(size: 12))
                            .foregroundColor(Color.white.opacity(0.6)) +
                        Text("Nutzungsbedingungen")
                            .font(.system(size: 12))
                            .foregroundColor(.orange) +
                        Text(" und ")
                            .font(.system(size: 12))
                            .foregroundColor(Color.white.opacity(0.6)) +
                        Text("Datenschutzrichtlinien")
                            .font(.system(size: 12))
                            .foregroundColor(.orange) +
                        Text(" zu.")
                            .font(.system(size: 12))
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

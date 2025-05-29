import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignUp = false
    
    var body: some View {
        ZStack {
            // Dark Background
            Color(red: 0.1, green: 0.11, blue: 0.15)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer().frame(height: 60)
                
                // Logo Section
                VStack(spacing: 16) {
                    Text("bumpify")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.2))
                    
                    Text("Verbinde dich mit Menschen um dich herum")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer().frame(height: 40)
                
                // Tab Buttons
                HStack(spacing: 0) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingSignUp = false
                        }
                    }) {
                        Text("Anmelden")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(showingSignUp ? Color.white.opacity(0.6) : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(showingSignUp ? Color.clear : Color(red: 1.0, green: 0.4, blue: 0.2))
                            )
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingSignUp = true
                        }
                    }) {
                        Text("Registrieren")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(!showingSignUp ? Color.white.opacity(0.6) : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(!showingSignUp ? Color.clear : Color(red: 1.0, green: 0.4, blue: 0.2))
                            )
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer().frame(height: 40)
                
                if showingSignUp {
                    // Register Form
                    RegisterFormView()
                } else {
                    // Login Form
                    VStack(spacing: 24) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("E-mail")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "envelope")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.white.opacity(0.6))
                                    .frame(width: 20)
                                
                                TextField("ex. yourname@gmail.com", text: $email)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                    .disableAutocorrection(true)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    .background(Color.clear)
                            )
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "lock")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.white.opacity(0.6))
                                    .frame(width: 20)
                                
                                SecureField("dein Passwort hier", text: $password)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                
                                Button(action: {}) {
                                    Image(systemName: "eye")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color.white.opacity(0.6))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    .background(Color.clear)
                            )
                        }
                        
                        // Forgot Password
                        HStack {
                            Spacer()
                            Button(action: {}) {
                                Text("Forget Password?")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color.white.opacity(0.6))
                            }
                        }
                        .padding(.horizontal, 32)
                        
                        Spacer().frame(height: 20)
                        
                        // Continue Button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                appState.isLoggedIn = true
                            }
                        }) {
                            HStack(spacing: 8) {
                                Text("Continue")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color(red: 1.0, green: 0.4, blue: 0.2))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 32)
                        
                        // Divider
                        HStack {
                            Rectangle()
                                .fill(Color.white.opacity(0.3))
                                .frame(height: 1)
                            
                            Text("oder")
                                .font(.system(size: 14))
                                .foregroundColor(Color.white.opacity(0.6))
                                .padding(.horizontal, 16)
                            
                            Rectangle()
                                .fill(Color.white.opacity(0.3))
                                .frame(height: 1)
                        }
                        .padding(.horizontal, 32)
                        .padding(.vertical, 20)
                        
                        // Social Login Buttons
                        VStack(spacing: 12) {
                            // Google Button
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    appState.isLoggedIn = true
                                }
                            }) {
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
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        .background(Color.clear)
                                )
                            }
                            .padding(.horizontal, 32)
                            
                            // Apple Button
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    appState.isLoggedIn = true
                                }
                            }) {
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
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        .background(Color.clear)
                                )
                            }
                            .padding(.horizontal, 32)
                        }
                        
                        Spacer().frame(height: 20)
                        
                        // Business Link
                        HStack {
                            Image(systemName: "building.2")
                                .font(.system(size: 12))
                                .foregroundColor(Color.white.opacity(0.6))
                            
                            Text("Für Unternehmen")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.6))
                        }
                        
                        Spacer().frame(height: 10)
                        
                        // Terms Text
                        VStack(spacing: 4) {
                            Text("Indem du fortfährst, stimmst du unseren")
                                .font(.system(size: 12))
                                .foregroundColor(Color.white.opacity(0.6))
                            
                            HStack(spacing: 4) {
                                Text("Nutzungsbedingungen")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.2))
                                
                                Text("und")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.white.opacity(0.6))
                                
                                Text("Datenschutzrichtlinien")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.2))
                                
                                Text("zu.")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.white.opacity(0.6))
                            }
                        }
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    }
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Register Form View
struct RegisterFormView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        VStack(spacing: 24) {
            // Email Field
            VStack(alignment: .leading, spacing: 8) {
                Text("E-mail")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    Image(systemName: "envelope")
                        .font(.system(size: 16))
                        .foregroundColor(Color.white.opacity(0.6))
                        .frame(width: 20)
                    
                    TextField("ex. yourname@gmail.com", text: $email)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .disableAutocorrection(true)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        .background(Color.clear)
                )
            }
            
            // Password Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    Image(systemName: "lock")
                        .font(.system(size: 16))
                        .foregroundColor(Color.white.opacity(0.6))
                        .frame(width: 20)
                    
                    SecureField("Type your password here", text: $password)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                    
                    Button(action: {}) {
                        Image(systemName: "eye")
                            .font(.system(size: 16))
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        .background(Color.clear)
                )
            }
            
            // Confirm Password Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Password bestätigen")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    Image(systemName: "lock")
                        .font(.system(size: 16))
                        .foregroundColor(Color.white.opacity(0.6))
                        .frame(width: 20)
                    
                    SecureField("Type your password here", text: $confirmPassword)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                    
                    Button(action: {}) {
                        Image(systemName: "eye")
                            .font(.system(size: 16))
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        .background(Color.clear)
                )
            }
            
            Spacer().frame(height: 20)
            
            // Continue Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    appState.isLoggedIn = true
                }
            }) {
                HStack(spacing: 8) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color(red: 1.0, green: 0.4, blue: 0.2))
                .cornerRadius(12)
            }
            .padding(.horizontal, 32)
            
            // Divider
            HStack {
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 1)
                
                Text("oder")
                    .font(.system(size: 14))
                    .foregroundColor(Color.white.opacity(0.6))
                    .padding(.horizontal, 16)
                
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 1)
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 20)
            
            // Social Login Buttons
            VStack(spacing: 12) {
                // Google Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        appState.isLoggedIn = true
                    }
                }) {
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
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            .background(Color.clear)
                    )
                }
                .padding(.horizontal, 32)
                
                // Apple Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        appState.isLoggedIn = true
                    }
                }) {
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
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            .background(Color.clear)
                    )
                }
                .padding(.horizontal, 32)
            }
            
            Spacer().frame(height: 20)
            
            // Terms Text
            VStack(spacing: 4) {
                Text("Indem du fortfährst, stimmst du unseren")
                    .font(.system(size: 12))
                    .foregroundColor(Color.white.opacity(0.6))
                
                HStack(spacing: 4) {
                    Text("Nutzungsbedingungen")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.2))
                    
                    Text("und")
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.6))
                    
                    Text("Datenschutzrichtlinien")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.2))
                    
                    Text("zu.")
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.6))
                }
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
        }
    }
}

// LoginView.swift - Modern Design with Bumpify Theme
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLogin = true // true = Login, false = Register
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var isLoading = false
    @State private var showingForgotPassword = false
    @State private var showingBusinessLogin = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            // Background matching HomeView
            Color(red: 0.12, green: 0.16, blue: 0.24)
                .ignoresSafeArea()
            
            // Subtle background gradient
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.4, blue: 0.2).opacity(0.05),
                    Color.clear,
                    Color(red: 1.0, green: 0.6, blue: 0.0).opacity(0.03)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Floating particles (subtle)
            ForEach(0..<4, id: \.self) { i in
                Circle()
                    .fill(Color.orange.opacity(0.05))
                    .frame(width: CGFloat.random(in: 20...40))
                    .offset(
                        x: CGFloat.random(in: -150...150),
                        y: CGFloat.random(in: -200...200)
                    )
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 8...12))
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.5),
                        value: isLogin
                    )
            }
            
            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: 80)
                    
                    // Logo Section
                    VStack(spacing: 16) {
                        // Bumpify Logo
                        VStack(spacing: 8) {
                            Image("BumpifyLogo") // Aus Assets.xcassets
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 60)
                            
                            Text("Verbinde dich mit Menschen um dich herum")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.bottom, 20)
                        
                        // Login/Register Toggle
                        modernToggleButtons
                    }
                    
                    Spacer().frame(height: 40)
                    
                    // Form Section
                    VStack(spacing: 20) {
                        // Email Field
                        modernTextField(
                            title: "E-Mail",
                            text: $email,
                            placeholder: "",
                            icon: "envelope",
                            keyboardType: .emailAddress
                        )
                        
                        // Password Field
                        modernPasswordField(
                            title: "Passwort",
                            text: $password,
                            placeholder: "",
                            showPassword: $showPassword
                        )
                        
                        // Confirm Password Field (only for register)
                        if !isLogin {
                            modernPasswordField(
                                title: "Passwort bestätigen",
                                text: $confirmPassword,
                                placeholder: "",
                                showPassword: $showConfirmPassword
                            )
                        }
                        
                        // Forgot Password (only for login)
                        if isLogin {
                            HStack {
                                Spacer()
                                Button("Forget Password?") {
                                    showingForgotPassword = true
                                }
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        
                        Spacer().frame(height: 20)
                        
                        // Continue Button
                        modernContinueButton
                        
                        // Divider
                        modernDivider
                        
                        // Social Login Buttons
                        modernSocialButtons
                        
                        // Terms and Privacy (only for register)
                        if !isLogin {
                            modernTermsText
                        }
                        
                        // Enhanced Business Section
                        if isLogin {
                            VStack(spacing: 16) {
                                // Divider
                                HStack {
                                    Rectangle()
                                        .fill(Color.white.opacity(0.2))
                                        .frame(height: 1)
                                    
                                    Text("oder")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.6))
                                        .padding(.horizontal, 16)
                                    
                                    Rectangle()
                                        .fill(Color.white.opacity(0.2))
                                        .frame(height: 1)
                                }
                                
                                // Business Login Button
                                Button(action: {
                                    showingBusinessLogin = true
                                }) {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.blue.opacity(0.2))
                                                .frame(width: 32, height: 32)
                                            
                                            Image(systemName: "building.2")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.blue)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Bist du ein Unternehmen?")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.white)
                                            
                                            Text("Erstelle Bumps, Events und Bonus-Karten")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.blue)
                                    }
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(.ultraThinMaterial)
                                            .background(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(Color.white.opacity(0.05))
                                            )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                    )
                                }
                            }
                            .padding(.top, 20)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer().frame(height: 50)
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .sheet(isPresented: $showingForgotPassword) {
            ForgotPasswordView()
        }
        .sheet(isPresented: $showingBusinessLogin) {
            BusinessLoginView()
        }
    }
    
    // MARK: - Modern UI Components
    
    private var modernToggleButtons: some View {
        HStack(spacing: 0) {
            // Login Button
            loginToggleButton
            
            // Register Button
            registerToggleButton
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal, 24)
    }
    
    private var loginToggleButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                isLogin = true
            }
        }) {
            Text("Anmelden")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isLogin ? .white : .white.opacity(0.6))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(isLogin ? 
                            AnyShapeStyle(LinearGradient(colors: [Color.orange, Color.red], startPoint: .leading, endPoint: .trailing)) : 
                            AnyShapeStyle(Color.clear)
                        )
                )
        }
    }
    
    private var registerToggleButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                isLogin = false
            }
        }) {
            Text("Registrieren")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(!isLogin ? .white : .white.opacity(0.6))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(!isLogin ? 
                            AnyShapeStyle(LinearGradient(colors: [Color.orange, Color.red], startPoint: .leading, endPoint: .trailing)) : 
                            AnyShapeStyle(Color.clear)
                        )
                )
        }
    }
    
    private func modernTextField(
        title: String,
        text: Binding<String>,
        placeholder: String,
        icon: String,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(width: 20)
                
                TextField("", text: text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .autocapitalization(.none)
                    .keyboardType(keyboardType)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
    
    private func modernPasswordField(
        title: String,
        text: Binding<String>,
        placeholder: String,
        showPassword: Binding<Bool>
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            HStack(spacing: 12) {
                Image(systemName: "lock")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(width: 20)
                
                Group {
                    if showPassword.wrappedValue {
                        TextField("", text: text)
                    } else {
                        SecureField("", text: text)
                    }
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                
                Button(action: {
                    showPassword.wrappedValue.toggle()
                }) {
                    Image(systemName: showPassword.wrappedValue ? "eye.slash" : "eye")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
    
    private var modernContinueButton: some View {
        Button(action: {
            performAuthentication()
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text("Continue")
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
                    colors: [Color.orange, Color.red],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .disabled(isLoading || !isFormValid)
            .opacity(isFormValid ? 1.0 : 0.6)
        }
    }
    
    private var modernDivider: some View {
        HStack(spacing: 16) {
            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(height: 1)
            
            Text("oder")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
            
            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(height: 1)
        }
        .padding(.vertical, 20)
    }
    
    private var modernSocialButtons: some View {
        VStack(spacing: 12) {
            // Google Sign In
            Button(action: {
                // TODO: Implement Google Sign In
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "globe")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text("Sign up with Google")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
            }
            
            // Apple Sign In
            Button(action: {
                // TODO: Implement Apple Sign In
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text("Sign up with Apple")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
            }
        }
    }
    
    private var modernTermsText: some View {
        VStack(spacing: 8) {
            Text("Indem du dich registrierst, stimmst du unseren")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
            
            HStack(spacing: 4) {
                Button("Nutzungsbedingungen") {
                    // TODO: Open Terms
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.orange)
                
                Text("und")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                
                Button("Datenschutzrichtlinien") {
                    // TODO: Open Privacy Policy
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.orange)
                
                Text("zu.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .multilineTextAlignment(.center)
        .padding(.top, 16)
    }
    
    // MARK: - Validation and Actions
    
    private var isFormValid: Bool {
        if isLogin {
            return !email.isEmpty && !password.isEmpty
        } else {
            return !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && password == confirmPassword
        }
    }
    
    private func performAuthentication() {
        isLoading = true
        
        if isLogin {
            authManager.login(email: email, password: password)
        } else {
            // For now, use placeholder names since we don't have name fields yet
            authManager.signUp(firstName: "Placeholder", lastName: "User", email: email, password: password)
        }
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Forgot Password View
struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var isLoading = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background matching LoginView
                Color(red: 0.12, green: 0.16, blue: 0.24)
                    .ignoresSafeArea()
                
                // Subtle background gradient
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.4, blue: 0.2).opacity(0.08),
                        Color.clear,
                        Color(red: 1.0, green: 0.6, blue: 0.0).opacity(0.04)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header spacer
                        Spacer().frame(height: 20)
                        
                        // Forgot Password Header
                        forgotPasswordHeader
                        
                        if !showSuccess {
                            // Email Input
                            VStack(spacing: 20) {
                                emailInputField
                                instructionsText
                            }
                            .padding(.horizontal, 24)
                            
                            // Send Reset Button
                            sendResetButton
                                .padding(.horizontal, 24)
                        } else {
                            // Success State
                            successContent
                        }
                        
                        // Back to Login
                        backToLoginButton
                        
                        // Bottom spacer
                        Spacer().frame(height: 40)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Forgot Password Header
    private var forgotPasswordHeader: some View {
        VStack(spacing: 20) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "lock.rotation")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.orange)
            }
            
            VStack(spacing: 8) {
                Text("Passwort vergessen?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Kein Problem! Gib deine E-Mail-Adresse ein")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Email Input Field
    private var emailInputField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("E-Mail-Adresse")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            HStack(spacing: 12) {
                Image(systemName: "envelope")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(width: 20)
                
                TextField("", text: $email)
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
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Instructions Text
    private var instructionsText: some View {
        VStack(spacing: 12) {
            Text("Du erhältst eine E-Mail mit einem Link zum Zurücksetzen deines Passworts.")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
            
            // Additional Info
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                    
                    Text("Die E-Mail kann bis zu 5 Minuten dauern")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                    
                    Text("Prüfe auch deinen Spam-Ordner")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
    }
    
    // MARK: - Send Reset Button
    private var sendResetButton: some View {
        Button(action: {
            sendPasswordReset()
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "paperplane")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Reset-Link senden")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color.orange, Color.red],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .disabled(isLoading || !isEmailValid)
            .opacity(isEmailValid ? 1.0 : 0.6)
        }
    }
    
    // MARK: - Success Content
    private var successContent: some View {
        VStack(spacing: 24) {
            // Success Icon
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.green)
            }
            
            VStack(spacing: 12) {
                Text("E-Mail gesendet!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Wir haben dir einen Link zum Zurücksetzen des Passworts an \(email) gesendet.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            // Open Email App Button
            Button(action: {
                openEmailApp()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "envelope.open")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("E-Mail-App öffnen")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.orange)
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Back to Login Button
    private var backToLoginButton: some View {
        Button(action: {
            dismiss()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .medium))
                
                Text("Zurück zur Anmeldung")
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(.white.opacity(0.7))
        }
        .padding(.top, 8)
    }
    
    // MARK: - Computed Properties
    private var isEmailValid: Bool {
        email.contains("@") && email.contains(".") && email.count >= 5
    }
    
    // MARK: - Functions
    private func sendPasswordReset() {
        guard isEmailValid else {
            errorMessage = "Bitte gib eine gültige E-Mail-Adresse ein."
            showError = true
            return
        }
        
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isLoading = false
            
            // Simulate success (in real app, handle actual API response)
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showSuccess = true
            }
        }
    }
    
    private func openEmailApp() {
        // Try to open the default email app
        if let mailURL = URL(string: "mailto:") {
            if UIApplication.shared.canOpenURL(mailURL) {
                UIApplication.shared.open(mailURL)
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationManager())
}

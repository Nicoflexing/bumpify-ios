// BusinessLoginView.swift - Business Login & Registration
import SwiftUI

struct BusinessLoginView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var businessName = ""
    @State private var businessType = "Restaurant"
    @State private var isLogin = true
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var isLoading = false
    @State private var showingDashboard = false
    @State private var showingProfileCreation = false
    
    let businessTypes = ["Restaurant", "Café", "Bar", "Shop", "Fitness", "Friseur", "Eventlocation", "Hotel", "Sonstige"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background matching Bumpify theme
                Color(red: 0.12, green: 0.16, blue: 0.24)
                    .ignoresSafeArea()
                
                LinearGradient(
                    colors: [
                        Color.green.opacity(0.1),
                        Color.clear,
                        Color.mint.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        Spacer().frame(height: 20)
                        
                        // Header
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.green, Color.mint],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                    .shadow(color: Color.green.opacity(0.4), radius: 20, x: 0, y: 8)
                                
                                Image(systemName: "building.2")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 8) {
                                Text("Bumpify Business")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("Erreiche neue Kunden durch lokale Begegnungen")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 30)
                            }
                        }
                        
                        // Toggle Buttons
                        businessToggleButtons
                        
                        // Form and Actions
                        VStack(spacing: 20) {
                            businessFormFields
                            businessActionButton
                            
                            if !isLogin {
                                businessFeaturesPreview
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer().frame(height: 40)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Schließen") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                }
            }
        }
        .fullScreenCover(isPresented: $showingDashboard) {
            BusinessDashboardView()
        }
        .fullScreenCover(isPresented: $showingProfileCreation) {
            BusinessProfileCreationView(
                businessName: businessName,
                businessType: businessType
            ) {
                showingProfileCreation = false
                showingDashboard = true
            }
        }
    }
    
    private var businessToggleButtons: some View {
        HStack(spacing: 0) {
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
                                AnyShapeStyle(LinearGradient(colors: [Color.green, Color.mint], startPoint: .leading, endPoint: .trailing)) :
                                AnyShapeStyle(Color.clear)
                            )
                    )
            }
            
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
                                AnyShapeStyle(LinearGradient(colors: [Color.green, Color.mint], startPoint: .leading, endPoint: .trailing)) :
                                AnyShapeStyle(Color.clear)
                            )
                    )
            }
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
    
    private var businessFormFields: some View {
        VStack(spacing: 20) {
            businessTextField(
                title: "E-Mail",
                text: $email,
                icon: "envelope",
                keyboardType: .emailAddress
            )
            
            if !isLogin {
                businessTextField(
                    title: "Unternehmensname",
                    text: $businessName,
                    icon: "building"
                )
                
                businessTypePicker
            }
            
            businessPasswordField(
                title: "Passwort",
                text: $password,
                showPassword: $showPassword
            )
            
            if !isLogin {
                businessPasswordField(
                    title: "Passwort bestätigen",
                    text: $confirmPassword,
                    showPassword: $showConfirmPassword
                )
            }
        }
    }
    
    private var businessTypePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Branche")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            Menu {
                ForEach(businessTypes, id: \.self) { type in
                    Button(type) {
                        businessType = type
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "building.columns")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: 20)
                    
                    Text(businessType)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
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
    
    private func businessTextField(
        title: String,
        text: Binding<String>,
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
    
    private func businessPasswordField(
        title: String,
        text: Binding<String>,
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
    
    private var businessActionButton: some View {
        Button(action: {
            performBusinessAuthentication()
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text(isLogin ? "Anmelden" : "Business Account erstellen")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color.green, Color.mint],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color.green.opacity(0.4), radius: 12, x: 0, y: 6)
        }
        .disabled(!isFormValid || isLoading)
        .opacity(isFormValid ? 1.0 : 0.6)
        .padding(.top, 20)
    }
    
    private var businessFeaturesPreview: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Was du als Business bekommst:")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                BusinessFeatureRow(
                    icon: "location.circle.fill",
                    title: "Bumps auf der Karte",
                    description: "Erstelle virtuelle Bumps mit Angeboten"
                )
                
                BusinessFeatureRow(
                    icon: "dot.radiowaves.left.and.right",
                    title: "Beacon Bumps",
                    description: "Automatische Bumps mit physischen Beacons"
                )
                
                BusinessFeatureRow(
                    icon: "creditcard.fill",
                    title: "Bonus-Karten",
                    description: "Digitale Treuekarten für Stammkunden"
                )
                
                BusinessFeatureRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Analytics",
                    description: "Detaillierte Statistiken zu deinen Bumps"
                )
            }
        }
        .padding(20)
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
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
        .padding(.top, 20)
    }
    
    private var isFormValid: Bool {
        if isLogin {
            return !email.isEmpty && !password.isEmpty
        } else {
            return !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty &&
                   !businessName.isEmpty && password == confirmPassword
        }
    }
    
    private func performBusinessAuthentication() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isLoading = false
            if isLogin {
                showingDashboard = true
            } else {
                // For new registrations, show profile creation first
                showingProfileCreation = true
            }
        }
    }
}

struct BusinessFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.green)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
    }
}

// MARK: - Temporary Placeholder Views (until files are added to Xcode project)

struct BusinessDashboardView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var showingCreateBump = false
    @State private var showingBeaconSetup = false
    @State private var showingBonusCardCreator = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Overview Tab
            BusinessOverviewView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Übersicht")
                }
                .tag(0)
            
            // Map Bumps Tab
            BusinessMapBumpsView()
                .tabItem {
                    Image(systemName: "location.fill")
                    Text("Map Bumps")
                }
                .tag(1)
            
            // Beacon Management Tab
            BusinessBeaconView()
                .tabItem {
                    Image(systemName: "dot.radiowaves.left.and.right")
                    Text("Beacons")
                }
                .tag(2)
            
            // Bonus Cards Tab
            BusinessBonusCardsView()
                .tabItem {
                    Image(systemName: "creditcard.fill")
                    Text("Bonus Cards")
                }
                .tag(3)
            
            // Analytics Tab
            BusinessAnalyticsView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Analytics")
                }
                .tag(4)
        }
        .accentColor(.green)
    }
}

// MARK: - Business Overview View

struct BusinessOverviewView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingCreateBump = false
    @State private var showingBusinessProfile = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.12, green: 0.16, blue: 0.24).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Welcome Header
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Willkommen zurück!")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text("Café Luna • Restaurant")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.green)
                                }
                                
                                Spacer()
                                
                                Circle()
                                    .fill(LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Text("CL")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        }
                        
                        // Live Statistics
                        VStack(spacing: 16) {
                            HStack {
                                Text("Live Statistiken")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                                StatCard(title: "Neue Bumps", value: "47", change: "+12%", isPositive: true, icon: "location.fill")
                                StatCard(title: "Umsatz heute", value: "€234", change: "+8%", isPositive: true, icon: "eurosign.circle.fill")
                                StatCard(title: "Aktive Angebote", value: "8", change: "0%", isPositive: true, icon: "tag.fill")
                                StatCard(title: "Reichweite", value: "2.1k", change: "+23%", isPositive: true, icon: "person.3.fill")
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Quick Actions
                        VStack(spacing: 16) {
                            HStack {
                                Text("Schnellaktionen")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                            VStack(spacing: 12) {
                                QuickActionCard(
                                    icon: "plus.circle.fill",
                                    title: "Neuen Bump erstellen",
                                    description: "Platziere ein neues Angebot auf der Karte"
                                ) {
                                    showingCreateBump = true
                                }
                                
                                QuickActionCard(
                                    icon: "dot.radiowaves.left.and.right",
                                    title: "Beacon hinzufügen",
                                    description: "Richte einen neuen Beacon ein"
                                )
                                
                                QuickActionCard(
                                    icon: "creditcard.fill",
                                    title: "Bonus-Karte erstellen",
                                    description: "Neue Treuekarte für Stammkunden"
                                )
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Recent Activity
                        VStack(spacing: 16) {
                            HStack {
                                Text("Letzte Aktivitäten")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button("Alle anzeigen") {
                                    // Show all activities
                                }
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.green)
                            }
                            .padding(.horizontal, 20)
                            
                            VStack(spacing: 8) {
                                ActivityRow(icon: "location.fill", title: "Neuer Bump", subtitle: "Happy Hour Cocktails", time: "vor 2h", color: .green)
                                ActivityRow(icon: "person.fill", title: "Neuer Kunde", subtitle: "Max Mustermann", time: "vor 3h", color: .blue)
                                ActivityRow(icon: "creditcard.fill", title: "Bonus-Karte", subtitle: "Kaffee-Karte eingelöst", time: "vor 5h", color: .orange)
                                ActivityRow(icon: "chart.line.uptrend.xyaxis", title: "Meilenstein", subtitle: "100 Bumps erreicht!", time: "gestern", color: .purple)
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Performance Metrics
                        VStack(spacing: 16) {
                            HStack {
                                Text("Performance")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                            VStack(spacing: 16) {
                                PerformanceMetric(title: "Monats-Ziel", value: "€1,250", target: "€2,000", progress: 0.625)
                                PerformanceMetric(title: "Neue Kunden", value: "47", target: "100", progress: 0.47)
                                PerformanceMetric(title: "Bump Conversion", value: "8.4%", target: "12%", progress: 0.7)
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer().frame(height: 100)
                    }
                }
            }
            .navigationTitle("Business Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Profil") {
                        showingBusinessProfile = true
                    }
                    .foregroundColor(.green)
                }
            }
        }
        .sheet(isPresented: $showingCreateBump) {
            CreateMapBumpView { newBump in
                // Handle creation logic here
            }
        }
        .sheet(isPresented: $showingBusinessProfile) {
            BusinessProfileView()
        }
    }
}

// MARK: - Business Profile Creation View

struct BusinessProfileCreationView: View {
    let businessName: String
    let businessType: String
    let onComplete: () -> Void
    
    @State private var currentStep = 0
    @State private var businessProfile = BusinessProfile()
    
    let totalSteps = 5
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.12, green: 0.16, blue: 0.24).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress Header
                    profileProgressHeader
                    
                    // Content
                    TabView(selection: $currentStep) {
                        // Step 1: Basic Info
                        BasicInfoStep()
                            .tag(0)
                        
                        // Step 2: Contact & Location
                        ContactLocationStep()
                            .tag(1)
                        
                        // Step 3: Business Hours
                        BusinessHoursStep()
                            .tag(2)
                        
                        // Step 4: Services & Amenities
                        ServicesStep()
                            .tag(3)
                        
                        // Step 5: Final Setup
                        FinalSetupStep()
                            .tag(4)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    // Navigation Buttons
                    navigationButtons
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        onComplete()
                    }
                    .foregroundColor(.green)
                }
            }
        }
        .onAppear {
            businessProfile.businessName = businessName
            businessProfile.businessType = businessType
        }
    }
    
    private var profileProgressHeader: some View {
        VStack(spacing: 16) {
            // Progress Bar
            HStack(spacing: 8) {
                ForEach(0..<totalSteps, id: \.self) { step in
                    Rectangle()
                        .fill(step <= currentStep ? Color.green : Color.white.opacity(0.3))
                        .frame(height: 4)
                        .cornerRadius(2)
                }
            }
            .padding(.horizontal, 20)
            
            // Step Info
            VStack(spacing: 8) {
                Text("Schritt \(currentStep + 1) von \(totalSteps)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Text(getStepTitle())
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 20)
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if currentStep > 0 {
                Button("Zurück") {
                    withAnimation(.easeInOut) {
                        currentStep -= 1
                    }
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            }
            
            Button(currentStep == totalSteps - 1 ? "Profil erstellen" : "Weiter") {
                if currentStep == totalSteps - 1 {
                    // Complete profile creation
                    onComplete()
                } else {
                    withAnimation(.easeInOut) {
                        currentStep += 1
                    }
                }
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
    
    private func getStepTitle() -> String {
        switch currentStep {
        case 0: return "Grundinformationen"
        case 1: return "Kontakt & Standort"
        case 2: return "Öffnungszeiten"
        case 3: return "Services & Ausstattung"
        case 4: return "Fertigstellung"
        default: return ""
        }
    }
}

#Preview {
    BusinessLoginView()
}

// MARK: - Supporting Views and Models

struct BusinessProfile {
    var businessName = ""
    var businessType = ""
    var description = ""
    var slogan = ""
    var street = ""
    var city = ""
    var phone = ""
    var email = ""
    var website = ""
    var services: [String] = []
    var businessHours: [String: (Bool, Date, Date)] = [:]
}

// MARK: - Data Models for Dashboard

struct MapBump: Identifiable {
    let id: String
    var title: String
    var description: String
    var type: BumpType
    var isActive: Bool
    var views: Int
    var conversions: Int
    var validUntil: Date
}

enum BumpType {
    case discount
    case event
    case service
    
    var icon: String {
        switch self {
        case .discount: return "tag.fill"
        case .event: return "calendar.badge.exclamationmark"
        case .service: return "wrench.and.screwdriver.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .discount: return .orange
        case .event: return .purple
        case .service: return .blue
        }
    }
}

struct BusinessBeacon: Identifiable {
    let id: String
    var name: String
    var location: String
    var batteryLevel: Int
    var status: BeaconStatus
    var dailyBumps: Int
}

enum BeaconStatus {
    case online
    case offline
    case lowBattery
    
    var color: Color {
        switch self {
        case .online: return .green
        case .offline: return .red
        case .lowBattery: return .orange
        }
    }
    
    var text: String {
        switch self {
        case .online: return "Online"
        case .offline: return "Offline"
        case .lowBattery: return "Niedrige Batterie"
        }
    }
}

struct BonusCard: Identifiable {
    let id: String
    var name: String
    var description: String
    var stamps: Int
    var customers: Int
    var isActive: Bool
    var redeemed: Int
}

// MARK: - Supporting UI Components

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(value)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                
                HStack {
                    Text(title)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .background(Color.white.opacity(0.05))
        )
    }
}

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.green : Color.white.opacity(0.1))
                )
        }
    }
}

struct MapBumpCard: View {
    let bump: MapBump
    let onUpdate: (MapBump) -> Void
    @State private var localBump: MapBump
    
    init(bump: MapBump, onUpdate: @escaping (MapBump) -> Void) {
        self.bump = bump
        self.onUpdate = onUpdate
        self.localBump = bump
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(localBump.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(localBump.description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Image(systemName: localBump.type.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(localBump.type.color)
                    
                    Toggle("", isOn: $localBump.isActive)
                        .scaleEffect(0.8)
                        .tint(.green)
                        .onChange(of: localBump.isActive) { _, newValue in
                            onUpdate(localBump)
                        }
                }
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(localBump.views)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Views")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(localBump.conversions)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.green)
                    
                    Text("Conversions")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Gültig bis")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text(localBump.validUntil, style: .date)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .background(Color.white.opacity(0.05))
        )
    }
}

struct BeaconStatusCard: View {
    let title: String
    let count: Int
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
            
            Text("\(count)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .background(Color.white.opacity(0.05))
        )
    }
}

struct BeaconCard: View {
    let beacon: BusinessBeacon
    let onUpdate: (BusinessBeacon) -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(beacon.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(beacon.status.text)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(beacon.status.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(beacon.status.color.opacity(0.2))
                        )
                }
                
                Text(beacon.location)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "battery.100")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(beacon.batteryLevel > 20 ? .green : .orange)
                        
                        Text("\(beacon.batteryLevel)%")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.blue)
                        
                        Text("\(beacon.dailyBumps) Bumps")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .background(Color.white.opacity(0.05))
        )
    }
}

struct BonusCardItemView: View {
    let card: BonusCard
    let onUpdate: (BonusCard) -> Void
    @State private var localCard: BonusCard
    
    init(card: BonusCard, onUpdate: @escaping (BonusCard) -> Void) {
        self.card = card
        self.onUpdate = onUpdate
        self.localCard = card
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(localCard.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(localCard.description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Toggle("", isOn: $localCard.isActive)
                    .scaleEffect(0.8)
                    .tint(.green)
                    .onChange(of: localCard.isActive) { _, newValue in
                        onUpdate(localCard)
                    }
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(localCard.stamps)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.orange)
                    
                    Text("Stempel")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(localCard.customers)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Text("Kunden")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(localCard.redeemed)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.green)
                    
                    Text("Eingelöst")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .background(Color.white.opacity(0.05))
        )
    }
}

struct AnalyticsMetricCard: View {
    let title: String
    let value: String
    let change: String
    let isPositive: Bool
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.green)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(change)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(isPositive ? .green : .red)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(value)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                
                HStack {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .background(Color.white.opacity(0.05))
        )
    }
}

struct InsightCard: View {
    let title: String
    let value: String
    let description: String
    let trend: String
    let isPositive: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(trend)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isPositive ? .green : .red)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .background(Color.white.opacity(0.05))
        )
    }
}

struct CustomerMetricCard: View {
    let title: String
    let percentage: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(percentage) / 100)
                        .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(percentage)%")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .background(Color.white.opacity(0.05))
        )
    }
}

// MARK: - Creation Views

struct AddBeaconView: View {
    let onComplete: (BusinessBeacon) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var location = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.12, green: 0.16, blue: 0.24).ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("Neuen Beacon hinzufügen")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 16) {
                        ProfileTextField(title: "Beacon Name", text: $name, placeholder: "z.B. Eingang")
                        ProfileTextField(title: "Standort", text: $location, placeholder: "z.B. Haupteingang")
                    }
                    
                    Spacer()
                    
                    Button("Beacon hinzufügen") {
                        let newBeacon = BusinessBeacon(
                            id: UUID().uuidString,
                            name: name,
                            location: location,
                            batteryLevel: 100,
                            status: .online,
                            dailyBumps: 0
                        )
                        onComplete(newBeacon)
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(12)
                    .disabled(name.isEmpty || location.isEmpty)
                    .opacity((name.isEmpty || location.isEmpty) ? 0.6 : 1.0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 40)
            }
            .navigationTitle("Neuer Beacon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") { dismiss() }
                        .foregroundColor(.green)
                }
            }
        }
    }
}

struct CreateBonusCardView: View {
    let onComplete: (BonusCard) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var stamps = 10
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.12, green: 0.16, blue: 0.24).ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("Neue Bonus-Karte erstellen")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 16) {
                        ProfileTextField(title: "Karten Name", text: $name, placeholder: "z.B. Kaffee-Karte")
                        ProfileTextField(title: "Beschreibung", text: $description, placeholder: "z.B. 10 Kaffee kaufen, 1 gratis")
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Anzahl Stempel")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Stepper(value: $stamps, in: 3...20) {
                                Text("\(stamps) Stempel")
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
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    
                    Spacer()
                    
                    Button("Bonus-Karte erstellen") {
                        let newCard = BonusCard(
                            id: UUID().uuidString,
                            name: name,
                            description: description,
                            stamps: stamps,
                            customers: 0,
                            isActive: true,
                            redeemed: 0
                        )
                        onComplete(newCard)
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(12)
                    .disabled(name.isEmpty || description.isEmpty)
                    .opacity((name.isEmpty || description.isEmpty) ? 0.6 : 1.0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 40)
            }
            .navigationTitle("Neue Bonus-Karte")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") { dismiss() }
                        .foregroundColor(.green)
                }
            }
        }
    }
}

// MARK: - Missing Views and Components

struct BusinessMapBumpsView: View {
    @State private var searchText = ""
    @State private var showingCreateBump = false
    @State private var selectedFilter = "Alle"
    @State private var mapBumps: [MapBump] = [
        MapBump(id: "1", title: "Happy Hour Cocktails", description: "50% Rabatt auf alle Cocktails", type: .discount, isActive: true, views: 234, conversions: 23, validUntil: Date().addingTimeInterval(86400*7)),
        MapBump(id: "2", title: "Live Jazz Abend", description: "Jeden Freitag ab 20 Uhr", type: .event, isActive: true, views: 156, conversions: 45, validUntil: Date().addingTimeInterval(86400*3)),
        MapBump(id: "3", title: "Catering Service", description: "Professionelles Catering", type: .service, isActive: false, views: 89, conversions: 12, validUntil: Date().addingTimeInterval(86400*14))
    ]
    
    let filterOptions = ["Alle", "Aktiv", "Inaktiv", "Rabatte", "Events", "Services"]
    
    var filteredBumps: [MapBump] {
        let filtered = mapBumps.filter { bump in
            if searchText.isEmpty { return true }
            return bump.title.localizedCaseInsensitiveContains(searchText) || 
                   bump.description.localizedCaseInsensitiveContains(searchText)
        }
        
        switch selectedFilter {
        case "Aktiv": return filtered.filter { $0.isActive }
        case "Inaktiv": return filtered.filter { !$0.isActive }
        case "Rabatte": return filtered.filter { $0.type == .discount }
        case "Events": return filtered.filter { $0.type == .event }
        case "Services": return filtered.filter { $0.type == .service }
        default: return filtered
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.12, green: 0.16, blue: 0.24).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header Stats
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            StatBox(title: "Aktive Bumps", value: "\(mapBumps.filter { $0.isActive }.count)", icon: "location.fill", color: .green)
                            StatBox(title: "Heute Views", value: "479", icon: "eye.fill", color: .blue)
                            StatBox(title: "Conversions", value: "80", icon: "checkmark.circle.fill", color: .orange)
                        }
                        .padding(.horizontal, 20)
                        
                        // Search and Filter
                        VStack(spacing: 12) {
                            // Search Bar
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.white.opacity(0.6))
                                
                                TextField("Bumps durchsuchen...", text: $searchText)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            
                            // Filter Pills
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(filterOptions, id: \.self) { filter in
                                        FilterPill(title: filter, isSelected: selectedFilter == filter) {
                                            selectedFilter = filter
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    // Bumps List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredBumps) { bump in
                                MapBumpCard(bump: bump) { updatedBump in
                                    if let index = mapBumps.firstIndex(where: { $0.id == updatedBump.id }) {
                                        mapBumps[index] = updatedBump
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Map Bumps")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateBump = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreateBump) {
            CreateMapBumpView { newBumpTitle in
                let newBump = MapBump(
                    id: UUID().uuidString,
                    title: newBumpTitle,
                    description: "Neue Beschreibung",
                    type: .discount,
                    isActive: true,
                    views: 0,
                    conversions: 0,
                    validUntil: Date().addingTimeInterval(86400*7)
                )
                mapBumps.append(newBump)
            }
        }
    }
}

struct BusinessBeaconView: View {
    @State private var showingAddBeacon = false
    @State private var beacons: [BusinessBeacon] = [
        BusinessBeacon(id: "1", name: "Eingang", location: "Haupteingang", batteryLevel: 85, status: .online, dailyBumps: 45),
        BusinessBeacon(id: "2", name: "Theke", location: "Bar-Bereich", batteryLevel: 62, status: .online, dailyBumps: 78),
        BusinessBeacon(id: "3", name: "Terrasse", location: "Außenbereich", batteryLevel: 23, status: .lowBattery, dailyBumps: 34),
        BusinessBeacon(id: "4", name: "VIP Lounge", location: "Obergeschoss", batteryLevel: 0, status: .offline, dailyBumps: 0)
    ]
    
    var statusCounts: (online: Int, offline: Int, maintenance: Int) {
        let online = beacons.filter { $0.status == .online }.count
        let offline = beacons.filter { $0.status == .offline }.count  
        let maintenance = beacons.filter { $0.status == .lowBattery }.count
        return (online, offline, maintenance)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.12, green: 0.16, blue: 0.24).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Status Overview
                    VStack(spacing: 16) {
                        HStack {
                            Text("Beacon Status")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        HStack(spacing: 12) {
                            BeaconStatusCard(title: "Online", count: statusCounts.online, color: .green, icon: "checkmark.circle.fill")
                            BeaconStatusCard(title: "Offline", count: statusCounts.offline, color: .red, icon: "xmark.circle.fill")
                            BeaconStatusCard(title: "Wartung", count: statusCounts.maintenance, color: .orange, icon: "exclamationmark.triangle.fill")
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    // Beacons List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(beacons) { beacon in
                                BeaconCard(beacon: beacon) { updatedBeacon in
                                    if let index = beacons.firstIndex(where: { $0.id == updatedBeacon.id }) {
                                        beacons[index] = updatedBeacon
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Beacon Management")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddBeacon = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddBeacon) {
            AddBeaconView { newBeacon in
                beacons.append(newBeacon)
            }
        }
    }
}

struct BusinessBonusCardsView: View {
    @State private var showingCreateCard = false
    @State private var bonusCards: [BonusCard] = [
        BonusCard(id: "1", name: "Kaffee-Karte", description: "10 Kaffee kaufen, 1 gratis", stamps: 10, customers: 47, isActive: true, redeemed: 12),
        BonusCard(id: "2", name: "Cocktail-Karte", description: "5 Cocktails kaufen, 1 gratis", stamps: 5, customers: 23, isActive: true, redeemed: 8),
        BonusCard(id: "3", name: "Lunch-Karte", description: "7 Mittagessen kaufen, 1 gratis", stamps: 7, customers: 15, isActive: false, redeemed: 3)
    ]
    
    var totalCustomers: Int {
        bonusCards.reduce(0) { $0 + $1.customers }
    }
    
    var totalRedeemed: Int {
        bonusCards.reduce(0) { $0 + $1.redeemed }
    }
    
    var activeCards: Int {
        bonusCards.filter { $0.isActive }.count
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.12, green: 0.16, blue: 0.24).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Cards Overview
                    VStack(spacing: 16) {
                        HStack {
                            Text("Bonus Cards Übersicht")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        HStack(spacing: 12) {
                            StatBox(title: "Aktive Karten", value: "\(activeCards)", icon: "creditcard.fill", color: .green)
                            StatBox(title: "Kunden", value: "\(totalCustomers)", icon: "person.3.fill", color: .blue)
                            StatBox(title: "Eingelöst", value: "\(totalRedeemed)", icon: "checkmark.circle.fill", color: .orange)
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    // Bonus Cards List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(bonusCards) { card in
                                BonusCardItemView(card: card) { updatedCard in
                                    if let index = bonusCards.firstIndex(where: { $0.id == updatedCard.id }) {
                                        bonusCards[index] = updatedCard
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Bonus Cards")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateCard = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreateCard) {
            CreateBonusCardView { newCard in
                bonusCards.append(newCard)
            }
        }
    }
}

struct BusinessAnalyticsView: View {
    @State private var selectedPeriod = "Monat"
    let periods = ["Tag", "Woche", "Monat", "Jahr"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.12, green: 0.16, blue: 0.24).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Period Selector
                        VStack(spacing: 16) {
                            HStack {
                                Text("Zeitraum")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            
                            HStack(spacing: 8) {
                                ForEach(periods, id: \.self) { period in
                                    Button(period) {
                                        selectedPeriod = period
                                    }
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(selectedPeriod == period ? .white : .white.opacity(0.6))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(selectedPeriod == period ? Color.green : Color.white.opacity(0.1))
                                    )
                                }
                                
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Key Metrics
                        VStack(spacing: 16) {
                            HStack {
                                Text("Hauptkennzahlen")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                                AnalyticsMetricCard(title: "Gesamtumsatz", value: "€12,450", change: "+18.5%", isPositive: true, icon: "eurosign.circle.fill")
                                AnalyticsMetricCard(title: "Neue Kunden", value: "1,234", change: "+12.3%", isPositive: true, icon: "person.3.fill")
                                AnalyticsMetricCard(title: "Conversion Rate", value: "8.9%", change: "+2.1%", isPositive: true, icon: "chart.line.uptrend.xyaxis")
                                AnalyticsMetricCard(title: "Ø Wert", value: "€23.45", change: "-1.2%", isPositive: false, icon: "banknote.fill")
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Performance Insights
                        VStack(spacing: 16) {
                            HStack {
                                Text("Performance Insights")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                            VStack(spacing: 12) {
                                InsightCard(
                                    title: "Bestperformender Bump",
                                    value: "Happy Hour Cocktails",
                                    description: "234 Views • 23 Conversions",
                                    trend: "+45%",
                                    isPositive: true
                                )
                                
                                InsightCard(
                                    title: "Stoßzeiten",
                                    value: "18:00 - 21:00",
                                    description: "Höchste Aktivität",
                                    trend: "Peak",
                                    isPositive: true
                                )
                                
                                InsightCard(
                                    title: "Top Standort",
                                    value: "Haupteingang",
                                    description: "78 Bumps heute",
                                    trend: "+12%",
                                    isPositive: true
                                )
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Customer Analytics
                        VStack(spacing: 16) {
                            HStack {
                                Text("Kundenanalyse")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                            HStack(spacing: 12) {
                                CustomerMetricCard(title: "Wiederkehrende Kunden", percentage: 67, color: .green)
                                CustomerMetricCard(title: "Kundenzufriedenheit", percentage: 92, color: .blue)
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer().frame(height: 100)
                    }
                }
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let change: String
    let isPositive: Bool
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.green)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(change)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(isPositive ? .green : .red)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(value)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                
                HStack {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .background(Color.white.opacity(0.05))
        )
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let description: String
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ActivityRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let time: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Text(time)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.03))
        )
    }
}

struct PerformanceMetric: View {
    let title: String
    let value: String
    let target: String
    let progress: Double
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 8)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing))
                    .frame(width: CGFloat(progress) * 200, height: 8)
            }
            .frame(maxWidth: 200)
            
            HStack {
                Text("Ziel: \(target)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                
                Spacer()
            }
        }
    }
}

struct CreateMapBumpView: View {
    let onComplete: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.12, green: 0.16, blue: 0.24).ignoresSafeArea()
                
                VStack {
                    Text("Neuen Map Bump erstellen")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Hier können Sie einen neuen Map Bump erstellen")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 8)
                    
                    Spacer()
                    
                    Button("Bump erstellen") {
                        onComplete("Neuer Bump")
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(12)
                }
                .padding(.top, 40)
            }
            .navigationTitle("Neuer Bump")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") { dismiss() }
                        .foregroundColor(.green)
                }
            }
        }
    }
}

struct BusinessProfileView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.12, green: 0.16, blue: 0.24).ignoresSafeArea()
                
                VStack {
                    Text("Business Profile")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Hier können Sie Ihr Geschäftsprofil bearbeiten")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 8)
                    
                    Spacer()
                }
                .padding(.top, 40)
            }
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Schließen") { dismiss() }
                        .foregroundColor(.green)
                }
            }
        }
    }
}

// MARK: - Profile Creation Step Views

struct BasicInfoStep: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text("Erzählen Sie uns mehr über Ihr Unternehmen")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 16) {
                        ProfileTextField(title: "Geschäftsname", text: .constant(""), placeholder: "z.B. Café Luna")
                        ProfileTextField(title: "Beschreibung", text: .constant(""), placeholder: "Kurze Beschreibung Ihres Geschäfts")
                        ProfileTextField(title: "Slogan (optional)", text: .constant(""), placeholder: "Ihr Geschäfts-Slogan")
                    }
                }
                
                Spacer().frame(height: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
}

struct ContactLocationStep: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text("Wie können Kunden Sie erreichen?")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 16) {
                        ProfileTextField(title: "Straße & Hausnummer", text: .constant(""), placeholder: "Musterstraße 123")
                        ProfileTextField(title: "PLZ & Ort", text: .constant(""), placeholder: "12345 Musterstadt")
                        ProfileTextField(title: "Telefon", text: .constant(""), placeholder: "+49 123 456789")
                        ProfileTextField(title: "E-Mail", text: .constant(""), placeholder: "info@business.de")
                        ProfileTextField(title: "Website (optional)", text: .constant(""), placeholder: "www.business.de")
                    }
                }
                
                Spacer().frame(height: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
}

struct BusinessHoursStep: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text("Wann haben Sie geöffnet?")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 12) {
                        ForEach(["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"], id: \.self) { day in
                            HourRow(day: day)
                        }
                    }
                }
                
                Spacer().frame(height: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
}

struct ServicesStep: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text("Was bieten Sie an?")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 16) {
                        ServiceToggle(title: "WLAN", icon: "wifi")
                        ServiceToggle(title: "Parkplätze", icon: "car")
                        ServiceToggle(title: "Terrasse", icon: "tree")
                        ServiceToggle(title: "Rollstuhlgerecht", icon: "figure.roll")
                        ServiceToggle(title: "Kartenzahlung", icon: "creditcard")
                        ServiceToggle(title: "Lieferservice", icon: "bicycle")
                    }
                }
                
                Spacer().frame(height: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
}

struct FinalSetupStep: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Text("Fast geschafft!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Ihr Business-Profil ist bereit. Sie können jetzt mit der Erstellung von Bumps und Angeboten beginnen.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                Spacer().frame(height: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
}

// MARK: - Profile Creation Components

struct ProfileTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
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

struct HourRow: View {
    let day: String
    @State private var isOpen = true
    @State private var openTime = Date()
    @State private var closeTime = Date()
    
    var body: some View {
        HStack {
            Text(day)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 30, alignment: .leading)
            
            Toggle("", isOn: $isOpen)
                .tint(.green)
            
            if isOpen {
                DatePicker("", selection: $openTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .colorScheme(.dark)
                
                Text("bis")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                
                DatePicker("", selection: $closeTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .colorScheme(.dark)
            } else {
                Text("Geschlossen")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct ServiceToggle: View {
    let title: String
    let icon: String
    @State private var isEnabled = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.green)
                .frame(width: 30)
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            Toggle("", isOn: $isEnabled)
                .tint(.green)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}


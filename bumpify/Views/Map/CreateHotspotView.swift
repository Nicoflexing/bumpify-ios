import SwiftUI
import CoreLocation

struct CreateHotspotView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var hotspotName = ""
    @State private var description = ""
    @State private var location = ""
    @State private var selectedCategory = BumpifyHotspot.HotspotCategory.social
    @State private var startDate = Date().addingTimeInterval(3600) // 1 hour from now
    @State private var endDate = Date().addingTimeInterval(7200) // 2 hours from now
    @State private var maxParticipants = 10
    @State private var hasMaxLimit = true
    @State private var isCreating = false
    @State private var currentStep = 0
    
    private let totalSteps = 4
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.12, blue: 0.18).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerSection
                    
                    // Progress Indicator
                    progressSection
                    
                    // Content based on step
                    TabView(selection: $currentStep) {
                        basicInfoStep.tag(0)
                        categoryTimeStep.tag(1)
                        participantsStep.tag(2)
                        previewStep.tag(3)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
                    
                    // Bottom Navigation
                    bottomNavigationSection
                }
            }
        }
        .interactiveDismissDisabled(isCreating)
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Button("Abbrechen") {
                dismiss()
            }
            .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.1))
            .disabled(isCreating)
            
            Spacer()
            
            VStack(spacing: 2) {
                Text("Hotspot erstellen")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Schritt \(currentStep + 1) von \(totalSteps)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            if currentStep == totalSteps - 1 {
                Button("Erstellen") {
                    createHotspot()
                }
                .foregroundColor(isFormValid ? Color(red: 1.0, green: 0.5, blue: 0.1) : .gray)
                .disabled(!isFormValid || isCreating)
            } else {
                Button("Weiter") {
                    withAnimation {
                        currentStep = min(currentStep + 1, totalSteps - 1)
                    }
                }
                .foregroundColor(canProceedFromCurrentStep ? Color(red: 1.0, green: 0.5, blue: 0.1) : .gray)
                .disabled(!canProceedFromCurrentStep)
            }
        }
        .padding()
        .background(Color(red: 0.1, green: 0.12, blue: 0.18))
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    // MARK: - Progress Section
    private var progressSection: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Rectangle()
                    .fill(step <= currentStep ?
                          Color(red: 1.0, green: 0.4, blue: 0.2) :
                          Color.white.opacity(0.2))
                    .frame(height: 4)
                    .frame(maxWidth: .infinity)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 16)
    }
    
    // MARK: - Step 1: Basic Info
    private var basicInfoStep: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Step Header
                VStack(spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.2))
                    
                    Text("Grundinformationen")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Erzähle uns mehr über dein Event")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                VStack(spacing: 20) {
                    // Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Event-Name", systemImage: "textformat")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        TextField("z.B. After Work Drinks", text: $hotspotName)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(hotspotName.isEmpty ? Color.red.opacity(0.5) : Color.white.opacity(0.2), lineWidth: 1)
                            )
                        
                        if hotspotName.isEmpty {
                            Text("Event-Name ist erforderlich")
                                .font(.caption)
                                .foregroundColor(.red.opacity(0.8))
                        }
                    }
                    
                    // Description Field
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Beschreibung", systemImage: "text.alignleft")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        TextField("Was erwartet die Teilnehmer?", text: $description, axis: .vertical)
                            .lineLimit(3...5)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    // Location Field
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Ort", systemImage: "location")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        TextField("Murphy's Pub, Zweibrücken", text: $location)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(location.isEmpty ? Color.red.opacity(0.5) : Color.white.opacity(0.2), lineWidth: 1)
                            )
                        
                        if location.isEmpty {
                            Text("Ort ist erforderlich")
                                .font(.caption)
                                .foregroundColor(.red.opacity(0.8))
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Step 2: Category & Time
    private var categoryTimeStep: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Step Header
                VStack(spacing: 12) {
                    Image(systemName: "calendar.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.2))
                    
                    Text("Kategorie & Zeit")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Wann und in welcher Kategorie findet dein Event statt?")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                VStack(spacing: 20) {
                    // Category Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Kategorie", systemImage: "tag")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                            ForEach(BumpifyHotspot.HotspotCategory.allCases, id: \.self) { category in
                                CategoryButton(
                                    category: category,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                    }
                    
                    // Time Settings
                    VStack(alignment: .leading, spacing: 15) {
                        Label("Zeitraum", systemImage: "clock")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        VStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Startzeit")
                                    .foregroundColor(.white)
                                
                                DatePicker("", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .colorScheme(.dark)
                                    .padding()
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(12)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Endzeit")
                                    .foregroundColor(.white)
                                
                                DatePicker("", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .colorScheme(.dark)
                                    .padding()
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(12)
                            }
                            
                            if endDate <= startDate {
                                Text("Endzeit muss nach der Startzeit liegen")
                                    .font(.caption)
                                    .foregroundColor(.red.opacity(0.8))
                            }
                        }
                    }
                    
                    // Duration Info
                    if endDate > startDate {
                        HStack {
                            Image(systemName: "hourglass")
                                .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.1))
                            
                            Text("Dauer: \(formatDuration(from: startDate, to: endDate))")
                                .foregroundColor(.white.opacity(0.8))
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color(red: 1.0, green: 0.5, blue: 0.1).opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Step 3: Participants
    private var participantsStep: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Step Header
                VStack(spacing: 12) {
                    Image(systemName: "person.2.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.2))
                    
                    Text("Teilnehmer")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Wie viele Personen sollen teilnehmen können?")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                VStack(spacing: 20) {
                    // Max Limit Toggle
                    VStack(spacing: 15) {
                        Toggle("Maximale Teilnehmerzahl festlegen", isOn: $hasMaxLimit)
                            .tint(Color(red: 1.0, green: 0.5, blue: 0.1))
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                        
                        if hasMaxLimit {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Maximum: \(maxParticipants) Personen")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Slider(value: Binding(
                                    get: { Double(maxParticipants) },
                                    set: { maxParticipants = Int($0) }
                                ), in: 2...50, step: 1)
                                .tint(Color(red: 1.0, green: 0.5, blue: 0.1))
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                                
                                HStack {
                                    Text("2")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                    
                                    Spacer()
                                    
                                    Text("50")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Info Cards
                    VStack(spacing: 12) {
                        InfoCard(
                            icon: "checkmark.circle.fill",
                            title: "Du bist automatisch dabei",
                            description: "Als Ersteller nimmst du automatisch teil",
                            color: .green
                        )
                        
                        InfoCard(
                            icon: "person.badge.plus",
                            title: "Andere können beitreten",
                            description: "Nutzer in der Nähe sehen dein Event auf der Karte",
                            color: .blue
                        )
                        
                        if hasMaxLimit {
                            InfoCard(
                                icon: "person.2.slash",
                                title: "Automatische Sperrung",
                                description: "Event wird bei \(maxParticipants) Teilnehmern automatisch geschlossen",
                                color: .orange
                            )
                        } else {
                            InfoCard(
                                icon: "infinity",
                                title: "Unbegrenzte Teilnahme",
                                description: "Es gibt keine Begrenzung der Teilnehmerzahl",
                                color: .purple
                            )
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Step 4: Preview
    private var previewStep: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Step Header
                VStack(spacing: 12) {
                    Image(systemName: "eye.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.2))
                    
                    Text("Vorschau")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("So wird dein Hotspot anderen Nutzern angezeigt")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // Preview Card
                HotspotPreview(
                    name: hotspotName,
                    description: description,
                    location: location,
                    category: selectedCategory,
                    startTime: startDate,
                    endTime: endDate,
                    maxParticipants: hasMaxLimit ? maxParticipants : nil,
                    creatorName: authManager.currentUser?.firstName ?? "Du"
                )
                
                // Terms and Guidelines
                VStack(spacing: 12) {
                    Text("📋 Wichtige Hinweise")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        GuidelineRow(text: "Dein Hotspot wird für alle Nutzer in der Nähe sichtbar")
                        GuidelineRow(text: "Du kannst jederzeit Teilnehmer verwalten oder das Event beenden")
                        GuidelineRow(text: "Achte auf respektvolles Verhalten und Community-Richtlinien")
                        GuidelineRow(text: "Das Event wird automatisch nach der Endzeit entfernt")
                        GuidelineRow(text: "Andere Nutzer können dir Nachrichten senden")
                    }
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
            }
            .padding()
        }
    }
    
    // MARK: - Bottom Navigation
    private var bottomNavigationSection: some View {
        HStack {
            if currentStep > 0 {
                Button("Zurück") {
                    withAnimation {
                        currentStep = max(currentStep - 1, 0)
                    }
                }
                .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            if isCreating {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.white)
                    
                    Text("Erstelle Hotspot...")
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding()
        .background(Color(red: 0.1, green: 0.12, blue: 0.18))
    }
    
    // MARK: - Helper Properties
    private var canProceedFromCurrentStep: Bool {
        switch currentStep {
        case 0:
            return !hotspotName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                   !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 1:
            return endDate > startDate
        case 2:
            return true // Participants step always valid
        case 3:
            return isFormValid
        default:
            return false
        }
    }
    
    private var isFormValid: Bool {
        !hotspotName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        endDate > startDate
    }
    
    // MARK: - Helper Methods
    private func createHotspot() {
        guard let currentUserId = authManager.getCurrentUserId() else { return }
        
        isCreating = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let newHotspot = BumpifyHotspot(
                name: hotspotName.trimmingCharacters(in: .whitespacesAndNewlines),
                description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                location: BumpifyLocation(
                    latitude: 49.2041, // Mock coordinates for Zweibrücken
                    longitude: 7.3066,
                    address: location.trimmingCharacters(in: .whitespacesAndNewlines),
                    city: "Zweibrücken"
                ),
                creatorId: currentUserId,
                hotspotType: .user,
                startTime: startDate,
                endTime: endDate,
                participants: [currentUserId], // Creator is automatically participant
                maxParticipants: hasMaxLimit ? maxParticipants : nil,
                category: selectedCategory
            )
            
            // TODO: Save hotspot to backend
            print("Created hotspot: \(newHotspot.name)")
            
            isCreating = false
            dismiss()
        }
    }
    
    private func formatDuration(from start: Date, to end: Date) -> String {
        let duration = end.timeIntervalSince(start)
        let hours = Int(duration) / 3600
        let minutes = Int(duration % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)min"
        } else {
            return "\(minutes) Minuten"
        }
    }
}

// MARK: - Supporting Views
struct CategoryButton: View {
    let category: BumpifyHotspot.HotspotCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: category.icon)
                    .font(.body)
                
                Text(category.displayName)
                    .font(.body)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                isSelected ?
                Color(red: 1.0, green: 0.5, blue: 0.1).opacity(0.3) :
                Color.white.opacity(0.1)
            )
            .foregroundColor(isSelected ? Color(red: 1.0, green: 0.5, blue: 0.1) : .white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(red: 1.0, green: 0.5, blue: 0.1) : Color.white.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct HotspotPreview: View {
    let name: String
    let description: String
    let location: String
    let category: BumpifyHotspot.HotspotCategory
    let startTime: Date
    let endTime: Date
    let maxParticipants: Int?
    let creatorName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.2))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(name.isEmpty ? "Event-Name" : name)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    Text(location.isEmpty ? "Event-Ort" : location)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Text(category.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(red: 1.0, green: 0.4, blue: 0.2).opacity(0.2))
                    .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.2))
                    .cornerRadius(8)
            }
            
            // Description
            Text(description.isEmpty ? "Event-Beschreibung wird hier angezeigt..." : description)
                .font(.body)
                .foregroundColor(description.isEmpty ? .gray : .white.opacity(0.8))
                .italic(description.isEmpty)
                .fixedSize(horizontal: false, vertical: true)
            
            // Time and Participants
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(timeRangeString(start: startTime, end: endTime))
                        .font(.caption)
                        .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.1))
                    
                    if let maxParticipants = maxParticipants {
                        Text("Max. \(maxParticipants) Personen")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        Text("Unbegrenzt")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("1 Teilnehmer")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("Erstellt von \(creatorName)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // Action Button (Preview only)
            HStack {
                Spacer()
                
                Button("Teilnehmen") {
                    // Preview only - no action
                }
                .font(.caption)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(red: 1.0, green: 0.4, blue: 0.2))
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(true) // Preview only
                .opacity(0.7)
                
                Spacer()
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(red: 1.0, green: 0.4, blue: 0.2).opacity(0.3), lineWidth: 1)
        )
    }
    
    private func timeRangeString(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        
        if Calendar.current.isDate(start, inSameDayAs: end) {
            formatter.dateStyle = .none
            return "Heute \(formatter.string(from: start)) - \(formatter.string(from: end))"
        } else {
            return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
        }
    }
}

struct GuidelineRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.caption)
                .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.1))
            
            Text(text)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

// CreateHotspotView.swift - Ersetze deine bestehende CreateHotspotView

import SwiftUI
import CoreLocation

struct CreateHotspotView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var hotspotName = ""
    @State private var description = ""
    @State private var location = ""
    @State private var selectedCategory = HotspotType.user
    @State private var startDate = Date().addingTimeInterval(3600) // 1 hour from now
    @State private var endDate = Date().addingTimeInterval(7200) // 2 hours from now
    @State private var maxParticipants = 10
    @State private var hasMaxLimit = true
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button("Abbrechen") {
                            dismiss()
                        }
                        .foregroundColor(.orange)
                        
                        Spacer()
                        
                        Text("Hotspot erstellen")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button("Erstellen") {
                            createHotspot()
                        }
                        .foregroundColor(.orange)
                        .disabled(!isFormValid)
                        .opacity(isFormValid ? 1.0 : 0.5)
                    }
                    .padding()
                    
                    ScrollView {
                        VStack(spacing: 25) {
                            // Basic Info
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Grundinformationen")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Name")
                                        .foregroundColor(.white)
                                    
                                    TextField("z.B. After Work Drinks", text: $hotspotName)
                                        .padding()
                                        .background(Color.white.opacity(0.1))
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Beschreibung")
                                        .foregroundColor(.white)
                                    
                                    TextField("Was erwartet die Teilnehmer?", text: $description, axis: .vertical)
                                        .lineLimit(3...5)
                                        .padding()
                                        .background(Color.white.opacity(0.1))
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Ort")
                                        .foregroundColor(.white)
                                    
                                    TextField("Murphy's Pub, Zweibrücken", text: $location)
                                        .padding()
                                        .background(Color.white.opacity(0.1))
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                            }
                            
                            // Category Selection
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Kategorie")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                HStack(spacing: 12) {
                                    CategoryButton(
                                        type: .user,
                                        isSelected: selectedCategory == .user
                                    ) {
                                        selectedCategory = .user
                                    }
                                    
                                    CategoryButton(
                                        type: .business,
                                        isSelected: selectedCategory == .business
                                    ) {
                                        selectedCategory = .business
                                    }
                                }
                            }
                            
                            // Time Settings
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Zeit")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                VStack(spacing: 15) {
                                    DatePicker("Startzeit", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.white.opacity(0.05))
                                        .cornerRadius(12)
                                    
                                    DatePicker("Endzeit", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.white.opacity(0.05))
                                        .cornerRadius(12)
                                }
                            }
                            
                            // Participants Settings
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Teilnehmer")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                VStack(spacing: 15) {
                                    Toggle("Maximale Teilnehmerzahl festlegen", isOn: $hasMaxLimit)
                                        .tint(.orange)
                                        .padding()
                                        .background(Color.white.opacity(0.05))
                                        .cornerRadius(12)
                                    
                                    if hasMaxLimit {
                                        VStack(spacing: 8) {
                                            HStack {
                                                Text("Maximum: \(maxParticipants) Personen")
                                                    .foregroundColor(.white)
                                                
                                                Spacer()
                                            }
                                            
                                            Slider(value: Binding(
                                                get: { Double(maxParticipants) },
                                                set: { maxParticipants = Int($0) }
                                            ), in: 2...50, step: 1)
                                            .tint(.orange)
                                        }
                                        .padding()
                                        .background(Color.white.opacity(0.05))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            
                            // Preview
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Vorschau")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                HotspotPreviewCard(
                                    name: hotspotName.isEmpty ? "Dein Event" : hotspotName,
                                    description: description.isEmpty ? "Beschreibung deines Events" : description,
                                    location: location.isEmpty ? "Ort deines Events" : location,
                                    type: selectedCategory,
                                    startTime: startDate,
                                    endTime: endDate,
                                    maxParticipants: hasMaxLimit ? maxParticipants : nil
                                )
                            }
                            
                            // Terms
                            VStack(spacing: 10) {
                                Text("Hinweise:")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("• Dein Hotspot wird für alle Nutzer in der Nähe sichtbar")
                                    Text("• Du kannst jederzeit Teilnehmer verwalten")
                                    Text("• Achte auf respektvolles Verhalten")
                                }
                                .font(.caption)
                                .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                        }
                        .padding()
                    }
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !hotspotName.isEmpty && !location.isEmpty && !description.isEmpty
    }
    
    private func createHotspot() {
        // Create the hotspot with correct parameters
        let newHotspot = Hotspot(
            name: hotspotName,
            description: description,
            location: location,
            coordinate: BumpCoordinate(latitude: 49.2041, longitude: 7.3066), // Default coordinates
            type: selectedCategory,
            createdBy: authManager.currentUser?.id ?? "unknown",
            startTime: startDate,
            endTime: endDate,
            participantIds: [authManager.currentUser?.id ?? ""].compactMap { $0 },
            maxParticipants: hasMaxLimit ? maxParticipants : nil,
            isActive: true
        )
        
        // In a real app, you would save this to your backend
        print("Created hotspot: \(newHotspot)")
        
        dismiss()
    }
}

// MARK: - Category Button
struct CategoryButton: View {
    let type: HotspotType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.body)
                
                Text(type.displayName)
                    .font(.body)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                isSelected ?
                type.color.opacity(0.3) :
                Color.white.opacity(0.1)
            )
            .foregroundColor(isSelected ? type.color : .white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? type.color : Color.clear, lineWidth: 1)
            )
        }
    }
}

// MARK: - Hotspot Preview Card
struct HotspotPreviewCard: View {
    let name: String
    let description: String
    let location: String
    let type: HotspotType
    let startTime: Date
    let endTime: Date
    let maxParticipants: Int?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: type.icon)
                    .font(.title2)
                    .foregroundColor(type.color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(location)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            Text(description)
                .font(.body)
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack {
                Text(formatTimeRange(start: startTime, end: endTime))
                    .font(.caption)
                    .foregroundColor(.orange)
                
                Spacer()
                
                if let maxParticipants = maxParticipants {
                    Text("Max. \(maxParticipants) Personen")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            HStack {
                Text("Erstellt von dir")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button("Beitreten") {
                    // Join action
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(type.color)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(type.color.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func formatTimeRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
}

#Preview {
    CreateHotspotView()
        .environmentObject(AuthenticationManager())
}

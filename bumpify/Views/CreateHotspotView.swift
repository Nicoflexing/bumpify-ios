
import SwiftUI
import CoreLocation

struct CreateHotspotView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var hotspotName = ""
    @State private var description = ""
    @State private var location = ""
    @State private var selectedCategory = "Freunde"
    @State private var startDate = Date().addingTimeInterval(3600) // 1 hour from now
    @State private var endDate = Date().addingTimeInterval(7200) // 2 hours from now
    @State private var maxParticipants = 10
    @State private var hasMaxLimit = true
    
    let categories = ["Freunde", "Dating", "Sport", "Kultur", "Essen", "Business", "Sonstiges"]
    
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
                            // Create hotspot
                            dismiss()
                        }
                        .foregroundColor(.orange)
                        .disabled(hotspotName.isEmpty || location.isEmpty)
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
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                                    ForEach(categories, id: \.self) { category in
                                        CategorySelectionButton(
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
                                
                                HotspotPreviewSimple(
                                    name: hotspotName.isEmpty ? "Dein Event" : hotspotName,
                                    description: description.isEmpty ? "Beschreibung deines Events" : description,
                                    location: location.isEmpty ? "Ort deines Events" : location,
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
                                
                                Text("• Dein Hotspot wird für alle Nutzer in der Nähe sichtbar")
                                Text("• Du kannst jederzeit Teilnehmer verwalten")
                                Text("• Achte auf respektvolles Verhalten")
                            }
                            .font(.caption)
                            .foregroundColor(.gray)
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
}

struct CategorySelectionButton: View {
    let category: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    isSelected ?
                    Color.orange.opacity(0.3) :
                    Color.white.opacity(0.1)
                )
                .foregroundColor(isSelected ? .orange : .white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 1)
                )
        }
    }
}

struct HotspotPreviewSimple: View {
    let name: String
    let description: String
    let location: String
    let startTime: Date
    let endTime: Date
    let maxParticipants: Int?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.2.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                
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
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func formatTimeRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
}

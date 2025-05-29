// CreateHotspotView.swift - Vollständige korrigierte Version
// Ersetze deine CreateHotspotView.swift komplett mit diesem Code

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
    @State private var isPublic = true
    
    let categories = ["Freunde", "Dating", "Sport", "Kultur", "Essen", "Business", "Sonstiges"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.12, green: 0.16, blue: 0.24)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 15) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.orange, .red],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                            }
                            
                            Text("Hotspot erstellen")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding(.top, 20)
                        
                        // Basic Info
                        VStack(alignment: .leading, spacing: 15) {
                            HotspotSectionHeader(title: "Grundinformationen")
                            
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
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        
                        // Category Selection
                        VStack(alignment: .leading, spacing: 15) {
                            HotspotSectionHeader(title: "Kategorie")
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                                ForEach(categories, id: \.self) { category in
                                    HotspotCategoryButton(
                                        category: category,
                                        isSelected: selectedCategory == category
                                    ) {
                                        selectedCategory = category
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        
                        // Time Settings
                        VStack(alignment: .leading, spacing: 15) {
                            HotspotSectionHeader(title: "Zeit")
                            
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
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        
                        // Participants Settings
                        VStack(alignment: .leading, spacing: 15) {
                            HotspotSectionHeader(title: "Teilnehmer")
                            
                            VStack(spacing: 15) {
                                Toggle("Maximale Teilnehmerzahl festlegen", isOn: $hasMaxLimit)
                                    .tint(.orange)
                                    .padding()
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(12)
                                
                                if hasMaxLimit {
                                    VStack(spacing: 10) {
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
                                
                                Toggle("Öffentlich sichtbar", isOn: $isPublic)
                                    .tint(.orange)
                                    .padding()
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(12)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        
                        // Preview
                        VStack(alignment: .leading, spacing: 15) {
                            HotspotSectionHeader(title: "Vorschau")
                            
                            HotspotPreview(
                                name: hotspotName.isEmpty ? "Dein Event" : hotspotName,
                                description: description.isEmpty ? "Beschreibung deines Events" : description,
                                location: location.isEmpty ? "Ort deines Events" : location,
                                startTime: startDate,
                                endTime: endDate,
                                maxParticipants: hasMaxLimit ? maxParticipants : nil,
                                category: selectedCategory
                            )
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        
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
                        
                        Spacer().frame(height: 100)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Erstellen") {
                        // Create hotspot logic
                        createHotspot()
                        dismiss()
                    }
                    .foregroundColor(.orange)
                    .disabled(hotspotName.isEmpty || location.isEmpty)
                }
            }
        }
    }
    
    // MARK: - Actions
    private func createHotspot() {
        print("Hotspot erstellt: \(hotspotName) in \(location)")
        // Hier würde die tatsächliche Hotspot-Erstellung stattfinden
    }
}

// MARK: - Hotspot Components
struct HotspotSectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}

struct HotspotCategoryButton: View {
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

struct HotspotPreview: View {
    let name: String
    let description: String
    let location: String
    let startTime: Date
    let endTime: Date
    let maxParticipants: Int?
    let category: String
    
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
                
                Text(category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.3))
                    .foregroundColor(.orange)
                    .cornerRadius(8)
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
                    // Join action - disabled for preview
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(true)
                .opacity(0.7)
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
        formatter.locale = Locale(identifier: "de_DE")
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
}

// MARK: - Preview
struct CreateHotspotView_Previews: PreviewProvider {
    static var previews: some View {
        CreateHotspotView()
    }
}

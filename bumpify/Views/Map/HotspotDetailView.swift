// HotspotDetailView.swift - Ersetze deine HotspotDetailView komplett (Finaler Fix)

import SwiftUI
import MapKit

struct HotspotDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let hotspot: Hotspot
    @State private var hasJoined = false
    @State private var showingParticipants = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header Image/Map
                        ZStack {
                            // Simple colored rectangle instead of map for now
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [hotspot.type.color.opacity(0.3), hotspot.type.color.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(height: 200)
                                .cornerRadius(20)
                            
                            VStack {
                                Image(systemName: hotspot.type.icon)
                                    .font(.system(size: 40))
                                    .foregroundColor(hotspot.type.color)
                                
                                Text("📍 \(hotspot.location)")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.black.opacity(0.6))
                                    .cornerRadius(15)
                            }
                        }
                        
                        // Hotspot Info
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(hotspot.name)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Text(hotspot.location)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    HStack {
                                        Image(systemName: "clock")
                                            .foregroundColor(hotspot.type.color)
                                        
                                        Text(formatTimeRange())
                                            .font(.caption)
                                            .foregroundColor(hotspot.type.color)
                                    }
                                }
                                
                                Spacer()
                                
                                VStack(spacing: 8) {
                                    Text("\(hotspot.participantCount)")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Text("Teilnehmer")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Text(hotspot.description)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        
                        // Participants Preview
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("Teilnehmer (\(hotspot.participantCount))")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button("Alle anzeigen") {
                                    showingParticipants = true
                                }
                                .font(.caption)
                                .foregroundColor(hotspot.type.color)
                            }
                            
                            HStack(spacing: -8) {
                                ForEach(0..<min(hotspot.participantCount, 5), id: \.self) { index in
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.orange, .red],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Text(getMockParticipantInitial(index))
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                        )
                                        .overlay(
                                            Circle()
                                                .stroke(Color.black, lineWidth: 2)
                                        )
                                }
                                
                                if hotspot.participantCount > 5 {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Text("+\(hotspot.participantCount - 5)")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                        )
                                        .overlay(
                                            Circle()
                                                .stroke(Color.black, lineWidth: 2)
                                        )
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        
                        // Details
                        VStack(spacing: 15) {
                            DetailRow(
                                icon: "calendar",
                                title: "Datum",
                                value: formatDate(hotspot.startTime),
                                color: .blue
                            )
                            
                            DetailRow(
                                icon: "clock",
                                title: "Zeit",
                                value: formatTimeRange(),
                                color: .green
                            )
                            
                            if let maxParticipants = hotspot.maxParticipants {
                                DetailRow(
                                    icon: "person.2",
                                    title: "Maximale Teilnehmer",
                                    value: "\(maxParticipants) Personen",
                                    color: .purple
                                )
                            }
                            
                            DetailRow(
                                icon: "tag",
                                title: "Typ",
                                value: hotspot.type == .user ? "User Event" : "Business Event",
                                color: hotspot.type.color
                            )
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        
                        Spacer().frame(height: 100) // Space for floating button
                    }
                    .padding()
                }
                
                // Floating Join Button
                VStack {
                    Spacer()
                    
                    Button(action: {
                        hasJoined.toggle()
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: hasJoined ? "checkmark.circle.fill" : "plus.circle.fill")
                                .font(.title2)
                            
                            Text(hasJoined ? "Teilgenommen" : "Teilnehmen")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: hasJoined ? [.green, .green.opacity(0.8)] : [hotspot.type.color, hotspot.type.color.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(radius: 10)
                    }
                    .scaleEffect(hasJoined ? 0.98 : 1.0)
                    .animation(.spring(response: 0.3), value: hasJoined)
                    .padding()
                    .background(Color.black.opacity(0.8))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                            )
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                            )
                    }
                }
            }
        }
        .sheet(isPresented: $showingParticipants) {
            ParticipantsView(hotspot: hotspot)
        }
    }
    
    private func formatTimeRange() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: hotspot.startTime)) - \(formatter.string(from: hotspot.endTime))"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func getMockParticipantInitial(_ index: Int) -> String {
        let names = ["A", "M", "L", "S", "T"]
        return names[index % names.count]
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 25)
            
            Text(title)
                .font(.body)
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

// Participants View
struct ParticipantsView: View {
    @Environment(\.dismiss) private var dismiss
    let hotspot: Hotspot
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(0..<hotspot.participantCount, id: \.self) { index in
                            ParticipantRow(
                                name: getMockParticipantName(index),
                                age: getMockParticipantAge(index),
                                interests: getMockParticipantInterests(index)
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Teilnehmer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
    }
    
    private func getMockParticipantName(_ index: Int) -> String {
        let names = ["Anna", "Max", "Lisa", "Stefan", "Tina", "Ben", "Clara", "David"]
        return names[index % names.count]
    }
    
    private func getMockParticipantAge(_ index: Int) -> Int {
        return 22 + (index % 15)
    }
    
    private func getMockParticipantInterests(_ index: Int) -> [String] {
        let allInterests = [["Musik", "Reisen"], ["Sport", "Fotografie"], ["Kunst", "Café"], ["Tech", "Gaming"]]
        return allInterests[index % allInterests.count]
    }
}

struct ParticipantRow: View {
    let name: String
    let age: Int
    let interests: [String]
    
    var body: some View {
        HStack(spacing: 15) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.orange, .red],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(name.prefix(1)))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("\(age) Jahre")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack {
                    ForEach(interests, id: \.self) { interest in
                        Text(interest)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(10)
                    }
                }
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "message.fill")
                    .font(.title3)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

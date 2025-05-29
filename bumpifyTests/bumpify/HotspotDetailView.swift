import SwiftUI

struct HotspotDetailView: View {
    let hotspot: Hotspot
    @Environment(\.dismiss) private var dismiss
    @State private var hasJoined = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button("Schließen") {
                            dismiss()
                        }
                        .foregroundColor(.orange)
                        
                        Spacer()
                        
                        Text("Hotspot Details")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.orange)
                        }
                    }
                    .padding()
                    
                    ScrollView {
                        VStack(spacing: 25) {
                            // Header Info
                            VStack(spacing: 15) {
                                // Icon
                                ZStack {
                                    Circle()
                                        .fill(hotspot.type.color.opacity(0.2))
                                        .frame(width: 80, height: 80)
                                    
                                    Image(systemName: hotspot.type.icon)
                                        .font(.system(size: 30))
                                        .foregroundColor(hotspot.type.color)
                                }
                                
                                // Title
                                Text(hotspot.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                
                                // Location
                                HStack {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.gray)
                                    
                                    Text(hotspot.location)
                                        .foregroundColor(.gray)
                                }
                                
                                // Type Badge
                                Text(hotspot.type == .user ? "Nutzer-Event" : "Business-Angebot")
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(hotspot.type.color.opacity(0.2))
                                    .foregroundColor(hotspot.type.color)
                                    .cornerRadius(12)
                            }
                            
                            // Description
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Beschreibung")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text(hotspot.description)
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(12)
                            }
                            
                            // Time Info
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Zeit")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                HStack {
                                    Image(systemName: "clock.fill")
                                        .foregroundColor(hotspot.type.color)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(formatTimeRange(start: hotspot.startTime, end: hotspot.endTime))
                                            .foregroundColor(.white)
                                        
                                        Text(formatDate(hotspot.startTime))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                            }
                            
                            // Participants
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Teilnehmer")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                HStack {
                                    Image(systemName: "person.2.fill")
                                        .foregroundColor(hotspot.type.color)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("\(hotspot.participantCount) Teilnehmer")
                                            .foregroundColor(.white)
                                        
                                        if let maxParticipants = hotspot.maxParticipants {
                                            Text("Maximum: \(maxParticipants)")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    // Progress if max participants
                                    if let maxParticipants = hotspot.maxParticipants {
                                        VStack(spacing: 4) {
                                            Text("\(hotspot.participantCount)/\(maxParticipants)")
                                                .font(.caption)
                                                .foregroundColor(hotspot.type.color)
                                            
                                            ProgressView(value: Double(hotspot.participantCount), total: Double(maxParticipants))
                                                .tint(hotspot.type.color)
                                                .frame(width: 60)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                            }
                            
                            // Similar Events (if business)
                            if hotspot.type == .business {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Weitere Angebote")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    VStack(spacing: 8) {
                                        SimilarOfferRow(
                                            title: "Frühstücks-Special",
                                            description: "Vollständiges Frühstück für 9,99€",
                                            time: "08:00 - 11:00"
                                        )
                                        
                                        SimilarOfferRow(
                                            title: "Lunch Deal",
                                            description: "Suppe + Hauptgericht für 12,50€",
                                            time: "12:00 - 15:00"
                                        )
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    
                    // Action Button
                    HStack(spacing: 15) {
                        if hasJoined {
                            Button("Verlassen") {
                                hasJoined = false
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            
                            Button("Chat öffnen") {
                                // Open group chat
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .foregroundColor(.white)
                            .cornerRadius(15)
                        } else {
                            Button("Beitreten") {
                                hasJoined = true
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [hotspot.type.color, hotspot.type.color.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(15)
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    private func formatTimeRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        let startTime = formatter.string(from: start)
        let endTime = formatter.string(from: end)
        
        return "\(startTime) - \(endTime)"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        return formatter.string(from: date)
    }
}

struct SimilarOfferRow: View {
    let title: String
    let description: String
    let time: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "tag.circle.fill")
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(time)
                    .font(.caption)
                    .foregroundColor(.green)
            }
            
            Spacer()
            
            Button("Mehr") {
                // Show offer details
            }
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.green.opacity(0.2))
            .foregroundColor(.green)
            .cornerRadius(6)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
}

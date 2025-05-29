import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = "Max Mustermann"
    @State private var bio = "Hier für neue Freundschaften und interessante Gespräche 😊"
    @State private var selectedInterests: Set<String> = ["Musik", "Reisen", "Fotografie"]
    
    let availableInterests = [
        "Musik", "Reisen", "Fotografie", "Sport", "Café", "Kunst", "Bücher",
        "Wandern", "Kochen", "Gaming", "Filme", "Tanzen", "Yoga", "Tech"
    ]
    
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
                        
                        Text("Profil bearbeiten")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button("Speichern") {
                            dismiss()
                        }
                        .foregroundColor(.orange)
                    }
                    .padding()
                    
                    ScrollView {
                        VStack(spacing: 25) {
                            // Profile Image Edit
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
                                        .frame(width: 120, height: 120)
                                    
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.white)
                                    
                                    Button(action: {}) {
                                        Image(systemName: "camera.circle.fill")
                                            .font(.title)
                                            .foregroundColor(.orange)
                                            .background(Color.black)
                                            .clipShape(Circle())
                                    }
                                    .offset(x: 45, y: 45)
                                }
                                
                                Text("Profilbild ändern")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            // Name
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Name")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                TextField("Dein Name", text: $name)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            
                            // Bio
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Über mich")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                TextField("Erzähl etwas über dich...", text: $bio, axis: .vertical)
                                                                   .lineLimit(3...6)
                                                                   .padding()
                                                                   .background(Color.white.opacity(0.1))
                                                                   .foregroundColor(.white)
                                                                   .cornerRadius(12)
                                                           }
                                                           
                                                           // Interests
                                                           VStack(alignment: .leading, spacing: 15) {
                                                               Text("Interessen")
                                                                   .font(.headline)
                                                                   .foregroundColor(.white)
                                                               
                                                               LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                                                                   ForEach(availableInterests, id: \.self) { interest in
                                                                       InterestToggleView(
                                                                           interest: interest,
                                                                           isSelected: selectedInterests.contains(interest)
                                                                       ) {
                                                                           if selectedInterests.contains(interest) {
                                                                               selectedInterests.remove(interest)
                                                                           } else {
                                                                               selectedInterests.insert(interest)
                                                                           }
                                                                       }
                                                                   }
                                                               }
                                                           }
                                                       }
                                                       .padding()
                                                   }
                                               }
                                           }
                                       }
                                   }
                                }

                                struct InterestToggleView: View {
                                   let interest: String
                                   let isSelected: Bool
                                   let onToggle: () -> Void
                                   
                                   var body: some View {
                                       Button(action: onToggle) {
                                           Text(interest)
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

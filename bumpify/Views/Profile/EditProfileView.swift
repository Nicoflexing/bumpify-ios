// EditProfileView.swift - Neue Datei erstellen oder ersetzen

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var bio = ""
    @State private var selectedInterests: Set<String> = []
    
    let availableInterests = [
        "Musik", "Reisen", "Sport", "Fotografie", "Kunst", "Café",
        "Tech", "Design", "Gaming", "Kochen", "Lesen", "Filme",
        "Natur", "Fitness", "Tanzen", "Business"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
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
                                    .frame(width: 100, height: 100)
                                
                                if let user = authManager.currentUser {
                                    Text(user.initials)
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(.white)
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white)
                                }
                                
                                // Camera button
                                Button(action: {}) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.orange)
                                        .clipShape(Circle())
                                }
                                .offset(x: 35, y: 35)
                            }
                            
                            Text("Profil bearbeiten")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        // Basic Info
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Grundinformationen")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            HStack(spacing: 15) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Vorname")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    TextField("Vorname", text: $firstName)
                                        .font(.body)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(10)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Nachname")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    TextField("Nachname", text: $lastName)
                                        .font(.body)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(10)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Bio")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                TextField("Erzähle etwas über dich...", text: $bio, axis: .vertical)
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .lineLimit(3...6)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        
                        // Interests
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Interessen")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("Wähle bis zu 5 Interessen aus")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                                ForEach(availableInterests, id: \.self) { interest in
                                    InterestButton(
                                        interest: interest,
                                        isSelected: selectedInterests.contains(interest)
                                    ) {
                                        if selectedInterests.contains(interest) {
                                            selectedInterests.remove(interest)
                                        } else if selectedInterests.count < 5 {
                                            selectedInterests.insert(interest)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        
                        Spacer().frame(height: 100)
                    }
                    .padding()
                }
                
                // Save Button
                VStack {
                    Spacer()
                    
                    Button(action: {
                        authManager.updateProfile(
                            firstName: firstName,
                            lastName: lastName,
                            bio: bio,
                            interests: Array(selectedInterests)
                        )
                        dismiss()
                    }) {
                        Text("Änderungen speichern")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
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
            }
        }
        .onAppear {
            loadCurrentUserData()
        }
    }
    
    private func loadCurrentUserData() {
        if let user = authManager.currentUser {
            firstName = user.firstName
            lastName = user.lastName
            bio = user.bio
            selectedInterests = Set(user.interests)
        }
    }
}

struct InterestButton: View {
    let interest: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(interest)
                .font(.body)
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
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

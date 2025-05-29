// OnboardingWelcomeView.swift - ERSETZE KOMPLETTEN INHALT
import SwiftUI

struct OnboardingWelcomeView: View {
    let onComplete: () -> Void
    
    init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }
    
    var body: some View {
        ZStack {
            // Hintergrund
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 0.1, green: 0.1, blue: 0.15), location: 0.0),
                    .init(color: Color(red: 0.05, green: 0.05, blue: 0.1), location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo
                Text("bumpify")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.orange, Color.red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                // Titel
                VStack(spacing: 16) {
                    Text("Willkommen bei Bumpify")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Entdecke Menschen, Orte und Dienstleistungen\nin deiner Nähe")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                
                // Features
                VStack(spacing: 20) {
                    SimpleFeatureRow(
                        icon: "person.2.fill",
                        title: "Echtzeit-Begegnungen",
                        description: "Automatische Erkennung von anderen Nutzern"
                    )
                    
                    SimpleFeatureRow(
                        icon: "building.2.fill",
                        title: "Business Bumps",
                        description: "Angebote lokaler Unternehmen"
                    )
                    
                    SimpleFeatureRow(
                        icon: "info.circle.fill",
                        title: "Service Bumps",
                        description: "Nützliche Infos zur richtigen Zeit"
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Button
                Button(action: {
                    onComplete()
                }) {
                    HStack {
                        Text("Los geht's")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Image(systemName: "arrow.right")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.orange, Color.red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
    }
}

struct SimpleFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.orange)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

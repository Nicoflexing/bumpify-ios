import SwiftUI

// MARK: - Onboarding View
struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Logo and Title
                    VStack(spacing: 20) {
                        Text("bumpify")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Echte Begegnungen.\nDigitale Verbindungen.")
                            .font(.title2)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .opacity(0.9)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 20) {
                        FeatureCard(
                            icon: "location.circle.fill",
                            title: "Begegnungen erkennen",
                            description: "Automatische Erkennung von Personen in deiner Nähe"
                        )
                        
                        FeatureCard(
                            icon: "heart.fill",
                            title: "Echte Matches",
                            description: "Nur bei gegenseitigem Interesse wird ein Chat freigeschaltet"
                        )
                        
                        FeatureCard(
                            icon: "shield.fill",
                            title: "Privatsphäre first",
                            description: "Deine Daten bleiben sicher und privat"
                        )
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            appState.isLoggedIn = true
                        }
                    }) {
                        Text("Jetzt starten")
                            .font(.headline)
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
                    .padding(.horizontal)
                }
                .padding()
            }
        }
    }
}

// MARK: - Feature Card Component
struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.orange)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

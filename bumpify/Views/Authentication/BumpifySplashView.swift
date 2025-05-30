// BumpifySplashView.swift
// Erstelle diese Datei als: bumpify/Views/Authentication/BumpifySplashView.swift

import SwiftUI

struct BumpifySplashView: View {
    let onComplete: (() -> Void)?
    
    init(onComplete: (() -> Void)? = nil) {
        self.onComplete = onComplete
    }
    
    var body: some View {
        ZStack {
            // Background - genau wie BumpView
            backgroundGradient
            
            // Main content
            VStack(spacing: 20) {
                Spacer()
                
                // App name - das untere Logo
                Image("BumpifyLogo") // Aus Assets.xcassets
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 220, height: 100)
                
                // Tagline
                Text("Echte Menschen, echte Begegnungen")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding(.horizontal, 40)
        }
        .onAppear {
            // Optional: Nach 2 Sekunden automatisch weiter
            if let completion = onComplete {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    completion()
                }
            }
        }
    }
    
    // MARK: - Background (genau wie BumpView)
    private var backgroundGradient: some View {
        ZStack {
            Color(red: 0.12, green: 0.16, blue: 0.24)
                .ignoresSafeArea()
            
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.4, blue: 0.2).opacity(0.1),
                    Color.clear,
                    Color(red: 1.0, green: 0.6, blue: 0.0).opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }
}

// MARK: - Preview
#Preview {
    BumpifySplashView {
        print("Splash animation completed")
    }
}

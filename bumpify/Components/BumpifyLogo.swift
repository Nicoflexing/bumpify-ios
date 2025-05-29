// BumpifyLogo.swift - Wiederverwendbare Logo-Komponente
// Erstelle diese Datei in: bumpify/Components/BumpifyLogo.swift

import SwiftUI

struct BumpifyLogo: View {
    let size: LogoSize
    let style: LogoStyle
    
    enum LogoSize {
        case small          // 24px
        case medium         // 32px
        case large          // 48px
        case extraLarge     // 64px
        case hero           // 100px
        case splash         // 120px
        case custom(CGFloat)
        
        var dimension: CGFloat {
            switch self {
            case .small: return 24
            case .medium: return 32
            case .large: return 48
            case .extraLarge: return 64
            case .hero: return 100
            case .splash: return 120
            case .custom(let size): return size
            }
        }
    }
    
    enum LogoStyle {
        case image          // Verwendet dein Upload-Logo
        case text           // Text-basiert "bumpify"
        case combined       // Logo + Text
        case iconOnly       // Nur Icon/Symbol
        
        var hasText: Bool {
            switch self {
            case .text, .combined: return true
            case .image, .iconOnly: return false
            }
        }
    }
    
    var body: some View {
        switch style {
        case .image:
            logoImage
            
        case .text:
            logoText
            
        case .combined:
            HStack(spacing: 8) {
                logoImage
                logoText
            }
            
        case .iconOnly:
            logoIcon
        }
    }
    
    // MARK: - Logo Components
    
    private var logoImage: some View {
        Group {
            // Erst versuchen, dein hochgeladenes Logo zu verwenden
            if let _ = UIImage(named: "BumpifyLogo") {
                Image("BumpifyLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size.dimension, height: size.dimension)
            } else {
                // Fallback: Generiertes Logo
                logoIcon
            }
        }
    }
    
    private var logoText: some View {
        Text("bumpify")
            .font(.system(size: textSize, weight: .bold, design: .rounded))
            .foregroundStyle(
                LinearGradient(
                    colors: [Color.orange, Color.red],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }
    
    private var logoIcon: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.orange, Color.red],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size.dimension, height: size.dimension)
            
            Image(systemName: "location.circle.fill")
                .font(.system(size: iconSize, weight: .medium))
                .foregroundColor(.white)
        }
        .shadow(
            color: Color.orange.opacity(0.3),
            radius: shadowRadius,
            x: 0,
            y: shadowOffset
        )
    }
    
    // MARK: - Computed Properties
    
    private var textSize: CGFloat {
        switch size {
        case .small: return 16
        case .medium: return 20
        case .large: return 24
        case .extraLarge: return 32
        case .hero: return 40
        case .splash: return 48
        case .custom(let customSize): return customSize * 0.6
        }
    }
    
    private var iconSize: CGFloat {
        size.dimension * 0.6
    }
    
    private var shadowRadius: CGFloat {
        size.dimension * 0.1
    }
    
    private var shadowOffset: CGFloat {
        size.dimension * 0.05
    }
}

// MARK: - Convenience Initializers
extension BumpifyLogo {
    // Standard-Logo für Navigation
    static var navigation: some View {
        BumpifyLogo(size: .medium, style: .text)
    }
    
    // Logo für Splash Screen
    static var splash: some View {
        BumpifyLogo(size: .splash, style: .combined)
    }
    
    // Logo für Login/Onboarding
    static var auth: some View {
        BumpifyLogo(size: .hero, style: .combined)
    }
    
    // Kleines Logo für Headers
    static var header: some View {
        BumpifyLogo(size: .large, style: .text)
    }
    
    // Icon für Benachrichtigungen
    static var notification: some View {
        BumpifyLogo(size: .small, style: .iconOnly)
    }
}

// MARK: - Preview
#Preview("Logo Varianten") {
    VStack(spacing: 30) {
        Group {
            Text("Logo Styles")
                .font(.headline)
            
            BumpifyLogo(size: .large, style: .image)
            BumpifyLogo(size: .large, style: .text)
            BumpifyLogo(size: .large, style: .combined)
            BumpifyLogo(size: .large, style: .iconOnly)
            
            Text("Logo Sizes")
                .font(.headline)
            
            HStack(spacing: 20) {
                BumpifyLogo(size: .small, style: .iconOnly)
                BumpifyLogo(size: .medium, style: .iconOnly)
                BumpifyLogo(size: .large, style: .iconOnly)
                BumpifyLogo(size: .extraLarge, style: .iconOnly)
            }
            
            Text("Convenience Logos")
                .font(.headline)
            
            VStack(spacing: 15) {
                BumpifyLogo.navigation
                BumpifyLogo.header
                BumpifyLogo.auth
            }
        }
    }
    .padding()
    .background(Color.black)
}

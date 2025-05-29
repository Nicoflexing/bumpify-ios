// BumpifyLogo.swift - Immer PNG Logo anzeigen
// Erstelle diese Datei in: bumpify/Components/BumpifyLogo.swift

import SwiftUI

struct BumpifyLogo: View {
    let size: LogoSize
    let style: LogoStyle = .image // Immer Image verwenden
    
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
        case image          // Verwendet dein PNG-Logo
        case text           // Fallback Text
        case combined       // Logo + Text
        case iconOnly       // Nur Icon/Symbol
    }
    
    var body: some View {
        // IMMER das PNG-Logo verwenden
        logoImage
    }
    
    // MARK: - Logo Image (PNG aus Assets)
    private var logoImage: some View {
        Image("BumpifyLogo") // Dein PNG aus Assets.xcassets
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size.dimension, height: size.dimension)
    }
}

// MARK: - Convenience Initializers
extension BumpifyLogo {
    // Standard-Logo für Navigation
    static var navigation: some View {
        BumpifyLogo(size: .medium)
    }
    
    // Logo für Splash Screen
    static var splash: some View {
        BumpifyLogo(size: .splash)
    }
    
    // Logo für Login/Onboarding
    static var auth: some View {
        BumpifyLogo(size: .hero)
    }
    
    // Kleines Logo für Headers
    static var header: some View {
        BumpifyLogo(size: .large)
    }
    
    // Icon für Benachrichtigungen
    static var notification: some View {
        BumpifyLogo(size: .small)
    }
    
    // Großes Logo für Startscreen
    static var main: some View {
        BumpifyLogo(size: .extraLarge)
    }
}

// MARK: - Preview
#Preview("Logo Größen") {
    VStack(spacing: 30) {
        Text("Bumpify Logo - Verschiedene Größen")
            .font(.headline)
            .foregroundColor(.white)
        
        VStack(spacing: 20) {
            // Kleine Logos
            HStack(spacing: 20) {
                VStack {
                    BumpifyLogo(size: .small)
                    Text("Small (24px)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                VStack {
                    BumpifyLogo(size: .medium)
                    Text("Medium (32px)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                VStack {
                    BumpifyLogo(size: .large)
                    Text("Large (48px)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // Große Logos
            HStack(spacing: 30) {
                VStack {
                    BumpifyLogo(size: .extraLarge)
                    Text("Extra Large (64px)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                VStack {
                    BumpifyLogo(size: .hero)
                    Text("Hero (100px)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // Splash Logo
            VStack {
                BumpifyLogo(size: .splash)
                Text("Splash (120px)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        
        Divider()
            .background(Color.gray)
        
        Text("Convenience Logos")
            .font(.headline)
            .foregroundColor(.white)
        
        VStack(spacing: 15) {
            HStack(spacing: 20) {
                VStack {
                    BumpifyLogo.navigation
                    Text("Navigation")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                VStack {
                    BumpifyLogo.header
                    Text("Header")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                VStack {
                    BumpifyLogo.notification
                    Text("Notification")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            HStack(spacing: 30) {
                VStack {
                    BumpifyLogo.auth
                    Text("Auth/Login")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                VStack {
                    BumpifyLogo.splash
                    Text("Splash Screen")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
    .padding()
    .background(Color.black)
}

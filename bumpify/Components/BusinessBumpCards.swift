// BusinessBumpCards.swift
// Neue Datei erstellen: bumpify/Views/Components/BusinessBumpCards.swift

import SwiftUI

// MARK: - Business Bump Card
struct BusinessBumpCard: View {
    let bump: BusinessBump
    let onTap: () -> Void
    let onClaim: () -> Void
    
    @State private var isPressed = false
    @State private var showSuccess = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showSuccess = true
            }
            onTap()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showSuccess = false
            }
        }) {
            VStack(spacing: 0) {
                // Header mit Logo und Business Info
                HStack(spacing: 12) {
                    // Business Logo
                    ZStack {
                        Circle()
                            .fill(bump.location.category.color.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        if let logo = bump.businessLogo {
                            Image(systemName: logo)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(bump.location.category.color)
                        } else {
                            Image(systemName: bump.location.category.icon)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(bump.location.category.color)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(bump.businessName)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.orange)
                            
                            Text(bump.formattedDistance)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    Spacer()
                    
                    // Priority Badge
                    priorityBadge
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                // Offer Content
                VStack(alignment: .leading, spacing: 12) {
                    // Offer Title mit Discount
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(bump.offerTitle)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(2)
                            
                            Text(bump.offerDescription)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(3)
                        }
                        
                        Spacer()
                        
                        if let discount = bump.discount {
                            discountBadge(discount)
                        }
                    }
                    
                    // Offer Details
                    HStack {
                        // Offer Type
                        HStack(spacing: 6) {
                            Image(systemName: bump.offerType.icon)
                                .font(.system(size: 12))
                                .foregroundColor(bump.offerType.color)
                            
                            Text(bump.offerType.displayName)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(bump.offerType.color)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(bump.offerType.color.opacity(0.2))
                        .cornerRadius(12)
                        
                        Spacer()
                        
                        // Time Remaining
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text(bump.timeRemaining)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    
                    // Action Button
                    Button(action: {
                        withAnimation(.spring()) {
                            showSuccess = true
                        }
                        onClaim()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showSuccess = false
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: showSuccess ? "checkmark.circle.fill" : "gift.fill")
                                .font(.system(size: 14, weight: .semibold))
                            
                            Text(showSuccess ? "Aktiviert!" : "Angebot aktivieren")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: showSuccess ? [.green, .mint] : [.orange, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .scaleEffect(showSuccess ? 1.05 : 1.0)
                    }
                    .disabled(showSuccess)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(glassBackground)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                bump.location.category.color.opacity(0.3),
                                bump.offerType.color.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .shadow(
                color: bump.location.category.color.opacity(0.2),
                radius: 10,
                x: 0,
                y: 8
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0) { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        } perform: {}
    }
    
    // MARK: - Priority Badge
    private var priorityBadge: some View {
        Group {
            if bump.priority.rawValue > BusinessPriority.normal.rawValue {
                HStack(spacing: 4) {
                    if bump.priority == .urgent {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 10))
                    } else {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                    }
                    
                    Text(bump.priority.displayName)
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(bump.priority.color)
                .cornerRadius(10)
            }
        }
    }
    
    // MARK: - Discount Badge
    private func discountBadge(_ discount: String) -> some View {
        VStack(spacing: 2) {
            Text(discount)
                .font(.system(size: 18, weight: .black))
                .foregroundColor(.white)
            
            Text("RABATT")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            LinearGradient(
                colors: [.red, .pink],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Glass Background
    private var glassBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.ultraThinMaterial)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
    }
}

// MARK: - Compact Business Bump Card (für Listen)
struct CompactBusinessBumpCard: View {
    let bump: BusinessBump
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Business Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(bump.location.category.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: bump.businessLogo ?? bump.location.category.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(bump.location.category.color)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(bump.businessName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(bump.offerTitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        Text(bump.formattedDistance)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.orange)
                        
                        if let discount = bump.discount {
                            Text(discount)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Spacer()
                
                // Time & Priority
                VStack(alignment: .trailing, spacing: 4) {
                    if bump.priority.rawValue > BusinessPriority.normal.rawValue {
                        Image(systemName: bump.priority == .urgent ? "exclamationmark.triangle.fill" : "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(bump.priority.color)
                    }
                    
                    Text(bump.timeRemaining)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(glassBackground)
            .cornerRadius(16)
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0) { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        } perform: {}
    }
    
    private var glassBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThinMaterial)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}

// MARK: - Business Bump Notification Banner
struct BusinessBumpNotificationBanner: View {
    let bump: BusinessBump
    let onTap: () -> Void
    let onDismiss: () -> Void
    
    @State private var slideIn = false
    @State private var pulseAnimation = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Animated Icon
            ZStack {
                Circle()
                    .fill(bump.location.category.color)
                    .frame(width: 40, height: 40)
                
                Circle()
                    .fill(bump.location.category.color.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .scaleEffect(pulseAnimation ? 1.5 : 1.0)
                    .opacity(pulseAnimation ? 0.0 : 1.0)
                
                Image(systemName: bump.businessLogo ?? bump.location.category.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: false)
                ) {
                    pulseAnimation = true
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text("🎯 Business Bump!")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.orange)
                
                Text("\(bump.businessName): \(bump.offerTitle)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    Text(bump.formattedDistance)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    if let discount = bump.discount {
                        Text("• \(discount)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.green)
                    }
                }
            }
            
            Spacer()
            
            // Dismiss Button
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(8)
                    .background(Circle().fill(Color.white.opacity(0.1)))
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [
                    bump.location.category.color.opacity(0.8),
                    bump.offerType.color.opacity(0.6)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
        .shadow(color: bump.location.category.color.opacity(0.3), radius: 10, x: 0, y: 5)
        .scaleEffect(slideIn ? 1.0 : 0.8)
        .opacity(slideIn ? 1.0 : 0.0)
        .offset(y: slideIn ? 0 : -50)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                slideIn = true
            }
        }
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Business Bump Section Header
struct BusinessBumpSectionHeader: View {
    let title: String
    let subtitle: String?
    let icon: String
    let onSeeAll: (() -> Void)?
    
    init(title: String, subtitle: String? = nil, icon: String, onSeeAll: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.onSeeAll = onSeeAll
    }
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            
            Spacer()
            
            if let onSeeAll = onSeeAll {
                Button("Alle anzeigen", action: onSeeAll)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.orange)
            }
        }
    }
}

// MARK: - Preview
#Preview("Business Bump Card") {
    VStack(spacing: 20) {
        BusinessBumpCard(
            bump: BusinessBump.sampleData[0],
            onTap: { print("Card tapped") },
            onClaim: { print("Offer claimed") }
        )
        
        CompactBusinessBumpCard(
            bump: BusinessBump.sampleData[1],
            onTap: { print("Compact card tapped") }
        )
    }
    .padding()
    .background(Color.black)
}

#Preview("Business Bump Notification") {
    BusinessBumpNotificationBanner(
        bump: BusinessBump.sampleData[0],
        onTap: { print("Notification tapped") },
        onDismiss: { print("Notification dismissed") }
    )
    .padding()
    .background(Color.black)
}

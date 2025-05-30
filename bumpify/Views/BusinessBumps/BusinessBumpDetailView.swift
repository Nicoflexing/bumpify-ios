// BusinessBumpDetailView.swift
// Neue Datei erstellen: bumpify/Views/BusinessBumps/BusinessBumpDetailView.swift

import SwiftUI
import MapKit

struct BusinessBumpDetailView: View {
    let businessBump: BusinessBump
    @Environment(\.dismiss) private var dismiss
    @StateObject private var businessBumpManager = BusinessBumpManager()
    
    @State private var showingSuccessAnimation = false
    @State private var showingMapSheet = false
    @State private var showingShareSheet = false
    @State private var isClaimed = false
    @State private var pulseAnimation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                backgroundGradient
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Header Image/Logo Section
                        headerSection
                        
                        // Main Content
                        VStack(spacing: 24) {
                            // Business Info Card
                            businessInfoCard
                            
                            // Offer Details Card
                            offerDetailsCard
                            
                            // Additional Info Card
                            additionalInfoCard
                            
                            // Map Preview Card
                            mapPreviewCard
                            
                            // Action Buttons
                            actionButtonsSection
                            
                            Spacer().frame(height: 50)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, -30) // Overlap mit Header
                    }
                }
                
                // Success Animation Overlay
                if showingSuccessAnimation {
                    successAnimationOverlay
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingMapSheet) {
            BusinessBumpMapView(businessBump: businessBump)
        }
        .sheet(isPresented: $showingShareSheet) {
            BusinessBumpShareSheet(businessBump: businessBump)
        }
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        ZStack {
            Color(red: 0.12, green: 0.16, blue: 0.24)
                .ignoresSafeArea()
            
            LinearGradient(
                colors: [
                    businessBump.location.category.color.opacity(0.3),
                    Color.clear,
                    businessBump.offerType.color.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        ZStack(alignment: .bottom) {
            // Background gradient
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            businessBump.location.category.color,
                            businessBump.location.category.color.opacity(0.7)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 200)
            
            // Close button
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.black.opacity(0.3)))
                    }
                    
                    Spacer()
                    
                    Button(action: { showingShareSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.black.opacity(0.3)))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                Spacer()
            }
            
            // Business Logo and Name
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 100, height: 100)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    
                    Circle()
                        .fill(businessBump.location.category.color.opacity(0.2))
                        .frame(width: 90, height: 90)
                    
                    Image(systemName: businessBump.businessLogo ?? businessBump.location.category.icon)
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundColor(businessBump.location.category.color)
                }
                .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true),
                    value: pulseAnimation
                )
                .onAppear {
                    pulseAnimation = true
                }
                
                VStack(spacing: 8) {
                    Text(businessBump.businessName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.3), radius: 5)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text(businessBump.formattedDistance)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
            }
            .offset(y: 50) // Ragt in den Content-Bereich
        }
    }
    
    // MARK: - Business Info Card
    private var businessInfoCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Geschäftsinformationen")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Category Badge
                HStack(spacing: 6) {
                    Image(systemName: businessBump.location.category.icon)
                        .font(.system(size: 12))
                    
                    Text(businessBump.location.category.displayName)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(businessBump.location.category.color)
                .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                InfoRow(
                    icon: "building.2.fill",
                    title: "Adresse",
                    value: businessBump.location.address,
                    color: .blue
                )
                
                InfoRow(
                    icon: "clock.fill",
                    title: "Gültig bis",
                    value: formatDate(businessBump.validUntil),
                    color: .orange
                )
                
                InfoRow(
                    icon: "eye.fill",
                    title: "Angesehen",
                    value: "\(businessBump.viewCount) mal",
                    color: .purple
                )
                
                InfoRow(
                    icon: "checkmark.circle.fill",
                    title: "Eingelöst",
                    value: "\(businessBump.claimCount) mal",
                    color: .green
                )
            }
        }
        .padding(20)
        .background(glassBackground)
        .cornerRadius(20)
    }
    
    // MARK: - Offer Details Card
    private var offerDetailsCard: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Angebot")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Priority Badge
                if businessBump.priority.rawValue > BusinessPriority.normal.rawValue {
                    HStack(spacing: 4) {
                        Image(systemName: businessBump.priority == .urgent ? "exclamationmark.triangle.fill" : "star.fill")
                            .font(.system(size: 10))
                        
                        Text(businessBump.priority.displayName)
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(businessBump.priority.color)
                    .cornerRadius(10)
                }
            }
            
            // Offer Title with Discount
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(businessBump.offerTitle)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Text(businessBump.offerDescription)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.leading)
                }
                
                if let discount = businessBump.discount {
                    VStack(spacing: 4) {
                        Text(discount)
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(.white)
                        
                        Text("SPAREN")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [.red, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: .red.opacity(0.4), radius: 12, x: 0, y: 6)
                }
            }
            
            // Offer Type and Time
            HStack(spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: businessBump.offerType.icon)
                        .font(.system(size: 16))
                        .foregroundColor(businessBump.offerType.color)
                    
                    Text(businessBump.offerType.displayName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(businessBump.offerType.color)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(businessBump.offerType.color.opacity(0.2))
                .cornerRadius(12)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text(businessBump.timeRemaining)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Text(formatTime(businessBump.validUntil))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .padding(20)
        .background(glassBackground)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [
                            businessBump.offerType.color.opacity(0.5),
                            businessBump.offerType.color.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
    }
    
    // MARK: - Additional Info Card
    private var additionalInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let terms = businessBump.terms {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.orange)
                        
                        Text("Bedingungen")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Text(terms)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.leading, 24)
                }
            }
            
            // Target Audience
            if let audience = businessBump.targetAudience, !audience.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                        
                        Text("Zielgruppe")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    HStack {
                        ForEach(audience, id: \.self) { target in
                            Text(target.capitalized)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.3))
                                .cornerRadius(8)
                        }
                        
                        Spacer()
                    }
                    .padding(.leading, 24)
                }
            }
        }
        .padding(20)
        .background(glassBackground)
        .cornerRadius(20)
    }
    
    // MARK: - Map Preview Card
    private var mapPreviewCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "map.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.green)
                
                Text("Standort")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Route") {
                    showingMapSheet = true
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.green)
            }
            
            // Simplified Map Preview
            Button(action: { showingMapSheet = true }) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.green.opacity(0.2))
                    .frame(height: 120)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "map")
                                .font(.system(size: 30))
                                .foregroundColor(.green)
                            
                            Text("Auf Karte anzeigen")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.green)
                        }
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(20)
        .background(glassBackground)
        .cornerRadius(20)
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            // Main Action Button
            Button(action: {
                claimOffer()
            }) {
                HStack(spacing: 12) {
                    Image(systemName: isClaimed ? "checkmark.circle.fill" : "gift.fill")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text(isClaimed ? "Angebot aktiviert!" : "Angebot aktivieren")
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: isClaimed ? [.green, .mint] : [.orange, .red],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(
                    color: (isClaimed ? Color.green : Color.orange).opacity(0.4),
                    radius: 12,
                    x: 0,
                    y: 6
                )
            }
            .disabled(isClaimed)
            .scaleEffect(isClaimed ? 1.05 : 1.0)
            .animation(.spring(), value: isClaimed)
            
            // Secondary Actions
            HStack(spacing: 16) {
                Button("Route anzeigen") {
                    showingMapSheet = true
                    businessBumpManager.markAsClicked(businessBump)
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.15))
                .cornerRadius(12)
                
                Button("Teilen") {
                    showingShareSheet = true
                    businessBumpManager.shareBusinessBump(businessBump)
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.15))
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Success Animation Overlay
    private var successAnimationOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(showingSuccessAnimation ? 1.2 : 0.5)
                .opacity(showingSuccessAnimation ? 1.0 : 0.0)
                
                Text("Angebot aktiviert!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .scaleEffect(showingSuccessAnimation ? 1.0 : 0.5)
                    .opacity(showingSuccessAnimation ? 1.0 : 0.0)
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showingSuccessAnimation)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    showingSuccessAnimation = false
                }
            }
        }
    }
    
    // MARK: - Glass Background
    private var glassBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.ultraThinMaterial)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
    
    // MARK: - Helper Functions
    private func claimOffer() {
        // Haptic Feedback
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
        
        // Success Animation
        withAnimation(.spring()) {
            showingSuccessAnimation = true
            isClaimed = true
        }
        
        // Success Feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let successFeedback = UINotificationFeedbackGenerator()
            successFeedback.notificationOccurred(.success)
        }
        
        // Analytics
        businessBumpManager.markAsClaimed(businessBump)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Info Row Component
struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
    }
}

// MARK: - Business Bump Map View
struct BusinessBumpMapView: View {
    let businessBump: BusinessBump
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    Text("🗺️ Karte zu \(businessBump.businessName)")
                        .font(.title)
                        .foregroundColor(.white)
                    
                    Text("Hier würde eine echte Karte mit Navigation angezeigt")
                        .foregroundColor(.gray)
                        .padding()
                    
                    Text("📍 \(businessBump.location.address)")
                        .foregroundColor(.orange)
                    
                    Text("📏 \(businessBump.formattedDistance)")
                        .foregroundColor(.blue)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Schließen") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
    }
}

// MARK: - Business Bump Share Sheet
struct BusinessBumpShareSheet: View {
    let businessBump: BusinessBump
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("📤 Angebot teilen")
                        .font(.title)
                        .foregroundColor(.white)
                    
                    Text("Teile dieses tolle Angebot mit deinen Freunden!")
                        .foregroundColor(.gray)
                    
                    VStack(spacing: 12) {
                        Text(businessBump.offerTitle)
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        Text("bei \(businessBump.businessName)")
                            .foregroundColor(.white)
                        
                        if let discount = businessBump.discount {
                            Text("\(discount) sparen!")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(16)
                    
                    Text("Share-Funktionalität wird hier implementiert")
                        .foregroundColor(.gray)
                        .italic()
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Schließen") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
    }
}

#Preview {
    BusinessBumpDetailView(businessBump: BusinessBump.sampleData[0])
}

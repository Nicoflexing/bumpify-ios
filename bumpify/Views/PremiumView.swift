import SwiftUI

struct PremiumView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan = 0
    
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
                        
                        Text("Bumpify Premium")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Spacer for symmetry
                        Text("Schließen")
                            .opacity(0)
                    }
                    .padding()
                    
                    ScrollView {
                        VStack(spacing: 30) {
                            // Premium Hero
                            VStack(spacing: 20) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.yellow, .orange],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 100, height: 100)
                                    
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white)
                                }
                                
                                Text("Upgrade zu Premium")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("Mehr Kontrolle und bessere Matches für echte Verbindungen")
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            
                            // Features
                            VStack(spacing: 20) {
                                PremiumFeatureView(
                                    icon: "eye.fill",
                                    title: "Profilvorschau",
                                    description: "Sieh Profile bevor du einen Bump annimmst"
                                )
                                
                                PremiumFeatureView(
                                    icon: "photo.stack.fill",
                                    title: "Bis zu 3 Profilbilder",
                                    description: "Zeige mehr von dir mit mehreren Bildern"
                                )
                                
                                PremiumFeatureView(
                                    icon: "mappin.and.ellipse",
                                    title: "Mehrere Hotspots",
                                    description: "Erstelle und verwalte mehrere Treffpunkte gleichzeitig"
                                )
                                
                                PremiumFeatureView(
                                    icon: "calendar.badge.plus",
                                    title: "5 Tage Vorausplanung",
                                    description: "Plane Hotspots bis zu 5 Tage im Voraus"
                                )
                                
                                PremiumFeatureView(
                                    icon: "star.circle.fill",
                                    title: "Bumpify Moments",
                                    description: "Speichere und markiere besondere Begegnungen"
                                )
                                
                                PremiumFeatureView(
                                    icon: "arrow.clockwise.circle.fill",
                                    title: "Echo-Bump",
                                    description: "Erkenne wiederholte Begegnungen mit denselben Personen"
                                )
                            }
                            
                            // Pricing
                            VStack(spacing: 15) {
                                Text("Wähle deinen Plan")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                VStack(spacing: 10) {
                                    PricingCardView(
                                        title: "Monatlich",
                                        price: "3,99 €",
                                        period: "pro Monat",
                                        isSelected: selectedPlan == 0,
                                        onSelect: { selectedPlan = 0 }
                                    )
                                    
                                    PricingCardView(
                                        title: "Jährlich",
                                        price: "39,99 €",
                                        period: "pro Jahr",
                                        savings: "Spare 17%",
                                        isSelected: selectedPlan == 1,
                                        onSelect: { selectedPlan = 1 }
                                    )
                                }
                            }
                            
                            // Subscribe Button
                            Button(action: {
                                // Handle premium subscription
                                dismiss()
                            }) {
                                Text("Premium aktivieren")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            colors: [.yellow, .orange],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(15)
                            }
                            
                            // Terms
                            VStack(spacing: 10) {
                                Text("• Jederzeit kündbar")
                                Text("• Keine versteckten Kosten")
                                Text("• 7 Tage Geld-zurück-Garantie")
                            }
                            .font(.caption)
                            .foregroundColor(.gray)
                        }
                        .padding()
                    }
                }
            }
        }
    }
}

struct PremiumFeatureView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.yellow)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct PricingCardView: View {
    let title: String
    let price: String
    let period: String
    let savings: String?
    let isSelected: Bool
    let onSelect: () -> Void
    
    init(title: String, price: String, period: String, savings: String? = nil, isSelected: Bool, onSelect: @escaping () -> Void) {
        self.title = title
        self.price = price
        self.period = period
        self.savings = savings
        self.isSelected = isSelected
        self.onSelect = onSelect
    }
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        if let savings = savings {
                            Text(savings)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    
                    Text("\(price) \(period)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Circle()
                    .stroke(isSelected ? Color.orange : Color.gray, lineWidth: 2)
                    .fill(isSelected ? Color.orange : Color.clear)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 8, height: 8)
                            .opacity(isSelected ? 1 : 0)
                    )
            }
            .padding()
            .background(Color.white.opacity(isSelected ? 0.1 : 0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MapFiltersView.swift
// Speichere diese Datei unter: bumpify/Views/Map/MapFiltersView.swift

import SwiftUI

struct MapFiltersView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory = "Alle"
    @State private var maxDistance = 5.0
    @State private var showUserEvents = true
    @State private var showBusinessEvents = true
    @State private var showActiveOnly = false
    @State private var selectedTimeRange = "Heute"
    
    let categories = ["Alle", "Dating", "Freunde", "Business", "Sport", "Kultur", "Essen"]
    let timeRanges = ["Jetzt", "Heute", "Diese Woche", "Immer"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 16) {
                            Text("🗺️ Karten-Filter")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Passe die Anzeige der Karte an deine Wünsche an")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // Distance Filter
                        VStack(alignment: .leading, spacing: 15) {
                            Text("📍 Entfernung")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Radius: \(Int(maxDistance)) km")
                                        .font(.body)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("Max: 25 km")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Slider(value: $maxDistance, in: 1...25, step: 1)
                                    .tint(.orange)
                                
                                HStack {
                                    Text("1 km")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    Spacer()
                                    
                                    Text("25 km")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                        }
                        
                        // Category Filter
                        VStack(alignment: .leading, spacing: 15) {
                            Text("🏷️ Kategorie")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                                ForEach(categories, id: \.self) { category in
                                    Button(action: {
                                        selectedCategory = category
                                    }) {
                                        Text(category)
                                            .font(.body)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                selectedCategory == category ?
                                                Color.orange.opacity(0.3) :
                                                Color.white.opacity(0.1)
                                            )
                                            .foregroundColor(selectedCategory == category ? .orange : .white)
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(selectedCategory == category ? Color.orange : Color.clear, lineWidth: 1)
                                            )
                                    }
                                }
                            }
                        }
                        
                        // Event Type Filter
                        VStack(alignment: .leading, spacing: 15) {
                            Text("🎯 Event-Typen")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                FilterToggleRow(
                                    icon: "person.2.fill",
                                    title: "User Events",
                                    subtitle: "Von Nutzern erstellte Hotspots",
                                    isOn: $showUserEvents,
                                    color: .orange
                                )
                                
                                FilterToggleRow(
                                    icon: "building.2.fill",
                                    title: "Business Events",
                                    subtitle: "Angebote von Unternehmen",
                                    isOn: $showBusinessEvents,
                                    color: .green
                                )
                                
                                FilterToggleRow(
                                    icon: "clock.fill",
                                    title: "Nur aktive Events",
                                    subtitle: "Verstecke vergangene Events",
                                    isOn: $showActiveOnly,
                                    color: .blue
                                )
                            }
                        }
                        
                        // Time Range Filter
                        VStack(alignment: .leading, spacing: 15) {
                            Text("⏰ Zeitraum")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            HStack(spacing: 8) {
                                ForEach(timeRanges, id: \.self) { timeRange in
                                    Button(action: {
                                        selectedTimeRange = timeRange
                                    }) {
                                        Text(timeRange)
                                            .font(.body)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                selectedTimeRange == timeRange ?
                                                Color.orange :
                                                Color.white.opacity(0.1)
                                            )
                                            .foregroundColor(.white)
                                            .cornerRadius(20)
                                    }
                                }
                            }
                        }
                        
                        // Active Filters Summary
                        VStack(alignment: .leading, spacing: 15) {
                            Text("✅ Aktuelle Filter")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("• Radius: \(Int(maxDistance)) km")
                                Text("• Kategorie: \(selectedCategory)")
                                Text("• Zeitraum: \(selectedTimeRange)")
                                Text("• User Events: \(showUserEvents ? "An" : "Aus")")
                                Text("• Business Events: \(showBusinessEvents ? "An" : "Aus")")
                            }
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                        }
                        
                        Spacer().frame(height: 100)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Zurück") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Zurücksetzen") {
                        resetFilters()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
    }
    
    private func resetFilters() {
        selectedCategory = "Alle"
        maxDistance = 5.0
        showUserEvents = true
        showBusinessEvents = true
        showActiveOnly = false
        selectedTimeRange = "Heute"
    }
}

struct FilterToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 25)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(.orange)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

#Preview {
    MapFiltersView()
}

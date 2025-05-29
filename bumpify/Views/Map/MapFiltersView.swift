// MapFiltersView.swift - Erstelle diese Datei in: Views/Map/MapFiltersView.swift

import SwiftUI

struct MapFiltersView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showUserEvents = true
    @State private var showBusinessEvents = true
    @State private var showTodayOnly = false
    @State private var maxDistance: Double = 5.0
    @State private var selectedCategories: Set<String> = ["Alle"]
    
    let categories = ["Alle", "Dating", "Freunde", "Sport", "Kultur", "Essen", "Business"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.12, green: 0.16, blue: 0.24)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 10) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                            
                            Text("Karten-Filter")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding(.top, 20)
                        
                        // Event Types
                        VStack(spacing: 15) {
                            FilterSectionHeader(title: "Event-Typen")
                            
                            FilterToggleItem(
                                icon: "person.2.fill",
                                title: "User Events",
                                subtitle: "Von Nutzern erstellte Treffpunkte",
                                isOn: $showUserEvents,
                                color: .orange
                            )
                            
                            FilterToggleItem(
                                icon: "building.2.fill",
                                title: "Business Events",
                                subtitle: "Angebote von Unternehmen",
                                isOn: $showBusinessEvents,
                                color: .green
                            )
                            
                            FilterToggleItem(
                                icon: "clock.fill",
                                title: "Nur heute",
                                subtitle: "Nur Events von heute anzeigen",
                                isOn: $showTodayOnly,
                                color: .blue
                            )
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        
                        // Distance Filter
                        VStack(spacing: 15) {
                            FilterSectionHeader(title: "Entfernung")
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Maximale Entfernung:")
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("\(String(format: "%.1f", maxDistance)) km")
                                        .font(.headline)
                                        .foregroundColor(.orange)
                                }
                                
                                Slider(value: $maxDistance, in: 0.5...20.0, step: 0.5)
                                    .tint(.orange)
                            }
                            .padding()
                            .background(Color.white.opacity(0.02))
                            .cornerRadius(10)
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        
                        // Categories
                        VStack(spacing: 15) {
                            FilterSectionHeader(title: "Kategorien")
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                                ForEach(categories, id: \.self) { category in
                                    CategoryFilterButton(
                                        category: category,
                                        isSelected: selectedCategories.contains(category)
                                    ) {
                                        if category == "Alle" {
                                            if selectedCategories.contains("Alle") {
                                                selectedCategories.removeAll()
                                            } else {
                                                selectedCategories = Set(categories)
                                            }
                                        } else {
                                            if selectedCategories.contains(category) {
                                                selectedCategories.remove(category)
                                                selectedCategories.remove("Alle")
                                            } else {
                                                selectedCategories.insert(category)
                                                if selectedCategories.count == categories.count - 1 {
                                                    selectedCategories.insert("Alle")
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        
                        // Reset Button
                        Button(action: resetFilters) {
                            Text("Filter zurücksetzen")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.2))
                                .cornerRadius(12)
                        }
                        
                        Spacer().frame(height: 50)
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
                    Button("Anwenden") {
                        // Apply filters
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
    }
    
    private func resetFilters() {
        showUserEvents = true
        showBusinessEvents = true
        showTodayOnly = false
        maxDistance = 5.0
        selectedCategories = ["Alle"]
    }
}

// MARK: - Filter Components
struct FilterSectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}

struct FilterToggleItem: View {
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
        .background(Color.white.opacity(0.02))
        .cornerRadius(10)
    }
}

struct CategoryFilterButton: View {
    let category: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category)
                .font(.body)
                .padding()
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

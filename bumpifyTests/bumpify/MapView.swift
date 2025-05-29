import SwiftUI
import MapKit

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 49.2041, longitude: 7.3066),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var showingFilters = false
    @State private var showingCreateHotspot = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    HStack {
                        Text("🗺️ Karte")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: { showingFilters = true }) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.title2)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding()
                    
                    Map(coordinateRegion: $region)
                        .frame(height: 400)
                        .cornerRadius(20)
                        .padding()
                    
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showingFilters) {
            Text("Filter") // Vereinfacht für jetzt
        }
        .sheet(isPresented: $showingCreateHotspot) {
            Text("Hotspot erstellen") // Vereinfacht für jetzt
        }
    }
}

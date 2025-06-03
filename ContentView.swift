// ContentView.swift - Einfache Weiterleitung zur RootView

import SwiftUI

struct ContentView: View {
    var body: some View {
        RootView()
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationManager())
}

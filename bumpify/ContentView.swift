import SwiftUI

// MARK: - Main App Structure
@main
struct BumpifyApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        if appState.isLoggedIn {
            // Haupt-App mit Tabs - verwendet deine vorhandenen Views
            TabView {
                // Deine HomeView.swift
                HomeView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                
                // Deine BumpView.swift
                BumpView()
                    .tabItem {
                        Image(systemName: "location.circle.fill")
                        Text("Bump")
                    }
                
                // Deine MapView.swift
                MapView()
                    .tabItem {
                        Image(systemName: "map.fill")
                        Text("Karte")
                    }
                
                // Deine MessagesView.swift
                MessagesView()
                    .tabItem {
                        Image(systemName: "message.fill")
                        Text("Chats")
                    }
                
                // Deine ProfileView.swift mit Logout-Funktion
                ProfileViewWithLogout()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profil")
                    }
            }
            .accentColor(.orange)
        } else {
            // Login/Register Flow
            AuthenticationFlow()
        }
    }
}

// MARK: - Authentication Flow
struct AuthenticationFlow: View {
    @State private var showingSignUp = false
    
    var body: some View {
        if showingSignUp {
            // Deine SignUpView.swift
            SignUpView()
        } else {
            // Deine LoginView.swift
            LoginView()
        }
    }
}

// MARK: - Profile View mit Logout (Wrapper für deine ProfileView)
struct ProfileViewWithLogout: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            ZStack {
                // Deine originale ProfileView im Hintergrund
                ProfileView()
                
                // Logout Button oben rechts
                VStack {
                    HStack {
                        Spacer()
                        Button("Logout") {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                appState.isLoggedIn = false
                            }
                        }
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(8)
                        .padding(.top, 10)
                        .padding(.trailing, 20)
                    }
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
    }
}

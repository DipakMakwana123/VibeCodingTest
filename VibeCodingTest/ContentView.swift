//
//  ContentView.swift
//  VibeCodingTest
//
//  Created by Dipak Makwana on 27/05/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Camera Tab
            NavigationView {
                CameraView()
            }
            .tabItem {
                Label("Camera", systemImage: "camera")
            }
            .tag(0)
            
            // History Tab
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock")
                }
                .tag(1)
        }
        .onAppear {
            // Set tab bar appearance for both light and dark mode
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            UITabBar.appearance().standardAppearance = tabBarAppearance
            
            // Set navigation bar appearance for both light and dark mode
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithDefaultBackground()
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        }
        .preferredColorScheme(.none) // Allow system to control dark/light mode
    }
}

// Custom color extension for consistent colors across themes
extension Color {
    static let systemBackground = Color(UIColor.systemBackground)
    static let secondarySystemBackground = Color(UIColor.secondarySystemBackground)
    static let tertiarySystemBackground = Color(UIColor.tertiarySystemBackground)
    
    static let systemGroupedBackground = Color(UIColor.systemGroupedBackground)
    static let secondarySystemGroupedBackground = Color(UIColor.secondarySystemGroupedBackground)
    static let tertiarySystemGroupedBackground = Color(UIColor.tertiarySystemGroupedBackground)
    
    static let label = Color(UIColor.label)
    static let secondaryLabel = Color(UIColor.secondaryLabel)
    static let tertiaryLabel = Color(UIColor.tertiaryLabel)
}

#Preview {
    ContentView()
}

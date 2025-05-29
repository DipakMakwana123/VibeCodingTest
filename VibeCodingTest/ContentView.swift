//
//  ContentView.swift
//  VibeCodingTest
//
//  Created by Dipak Makwana on 27/05/25.
//

import SwiftUI
import os

struct ContentView: View {
    @State private var selectedTab = 0
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "VibeCodingTest", category: "ContentView")
    
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
                    Label("History", systemImage: "calendar")
                }
                .tag(1)
        }
    }
}

#Preview {
    ContentView()
}

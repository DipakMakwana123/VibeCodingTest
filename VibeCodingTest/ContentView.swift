//
//  ContentView.swift
//  VibeCodingTest
//
//  Created by Dipak Makwana on 27/05/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    // Replace with your actual OpenAI API key
    private let openAIApiKey = "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"
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Camera Tab
            NavigationView {
                CameraView(apiKey: openAIApiKey)
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

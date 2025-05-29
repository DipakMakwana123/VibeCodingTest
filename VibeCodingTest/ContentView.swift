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
    
    private var openAIApiKey: String {
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            logger.error("OpenAI API key not found in environment variables")
            return ""
        }
        return apiKey
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Camera Tab
            NavigationView {
                if openAIApiKey.isEmpty {
                    Text("Please set OPENAI_API_KEY environment variable")
                        .foregroundColor(.red)
                } else {
                    CameraView(apiKey: openAIApiKey)
                }
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

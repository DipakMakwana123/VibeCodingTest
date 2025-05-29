//
//  ContentView.swift
//  VibeCodingTest
//
//  Created by Dipak Makwana on 27/05/25.
//

import SwiftUI
import os.log

struct ContentView: View {
    @State private var selectedTab = 0
    private let logger = Logger(subsystem: "com.vibe.foodcalories", category: "ContentView")
    
    private var openAIApiKey: String {
        do {
            // Get API key from environment variable or secure storage
            if let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
                return apiKey
            }
            return try ConfigurationManager.shared.openAIAPIKey
        } catch {
            logger.error("Failed to get OpenAI API key: \(error.localizedDescription)")
            return ""
        }
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                // Camera Tab
                NavigationView {
                    if openAIApiKey.isEmpty {
                        if #available(iOS 17.0, *) {
                            ContentUnavailableView(
                                "API Key Missing",
                                systemImage: "exclamationmark.triangle",
                                description: Text("Please add your OpenAI API key to Config.plist")
                            )
                        } else {
                            Color(UIColor.systemBackground)
                                .overlay(
                                    ToastView(
                                        message: "API Key Missing",
                                        systemImage: "exclamationmark.triangle",
                                        description: "Please add your OpenAI API key to Config.plist"
                                    )
                                )
                        }
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
}

#Preview {
    ContentView()
}

//
//  ContentView.swift
//  BobChat
//
//  Created by James Goodwill on 6/26/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var ollamaService = OllamaService()
    @StateObject private var chatViewModel = ChatViewModel()
    @StateObject private var modelViewModel = ModelViewModel()
    
    var body: some View {
        NavigationStack {
            if ollamaService.baseURL.isEmpty {
                OnboardingView()
            } else {
                ChatView()
            }
        }
        .environmentObject(ollamaService)
        .environmentObject(chatViewModel)
        .environmentObject(modelViewModel)
    }
}

#Preview {
    ContentView()
}

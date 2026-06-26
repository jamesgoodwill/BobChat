//
//  OnboardingView.swift
//  BobChat
//
//  Created by James Goodwill on 6/26/26.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var ollamaService: OllamaService
    @Environment(\.dismiss) private var dismiss
    
    @State private var baseURL = ""
    @State private var isConfigured = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "messagebubble.and.text.below.rectangle")
                    .font(.system(size: 64, weight: .thin))
                    .foregroundColor(.blue)
                    .padding(.bottom, 20)
                
                Text("Welcome to BobChat")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Connect to your local Ollama server to start chatting")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Ollama Server URL")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    TextField("Enter Ollama URL", text: $baseURL)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Text("Default: http://10.0.0.155:11434")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                Button("Connect to Ollama") {
                    configureConnection()
                }
                .disabled(baseURL.isEmpty)
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .padding()
            .onAppear {
                baseURL = ollamaService.baseURL
            }
        }
    }
    
    private func configureConnection() {
        guard !baseURL.isEmpty else {
            errorMessage = "Please enter a server URL"
            return
        }
        
        do {
            // Validate URL format
            guard let _ = URL(string: baseURL) else {
                errorMessage = "Please enter a valid URL"
                return
            }
            
            ollamaService.setBaseURL(baseURL)
            isConfigured = true
            errorMessage = nil
            
            // Dismiss this view - the app will now show the chat view
            dismiss()
        } catch {
            errorMessage = "Invalid URL format"
        }
    }
}

#Preview {
    OnboardingView()
}
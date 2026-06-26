//
//  SettingsView.swift
//  BobChat
//
//  Created by James Goodwill on 6/26/26.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var ollamaService: OllamaService
    @Environment(\.dismiss) private var dismiss
    
    @State private var baseURL = ""
    @State private var isShowingDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Connection")) {
                    TextField("Ollama Server URL", text: $baseURL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onSubmit {
                            saveSettings()
                        }
                    
                    Text("Default: http://10.0.0.155:11434")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("App")) {
                    Button("Clear Conversation History") {
                        isShowingDeleteAlert = true
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text("About")) {
                    Text("BobChat v0.1")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("A native iOS client for Ollama")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        saveSettings()
                        dismiss()
                    }
                }
            }
            .alert("Clear History", isPresented: $isShowingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    // This would typically clear conversation history
                    // For this implementation, we're just showing the alert
                }
            } message: {
                Text("Are you sure you want to clear the conversation history?")
            }
            .onAppear {
                baseURL = ollamaService.baseURL
            }
        }
    }
    
    private func saveSettings() {
        guard !baseURL.isEmpty else { return }
        
        // Validate URL format
        guard URL(string: baseURL) != nil else {
            return
        }
        
        ollamaService.setBaseURL(baseURL)
    }
}

#Preview {
    SettingsView()
        .environmentObject(OllamaService())
}
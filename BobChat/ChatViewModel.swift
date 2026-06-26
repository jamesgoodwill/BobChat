//
//  ChatViewModel.swift
//  BobChat
//
//  Created by James Goodwill on 6/26/26.
//

import Foundation
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var isStreaming = false
    @Published var userPrompt = ""
    @Published var errorMessage: String?
    
    private let ollamaService: OllamaService
    
    init(ollamaService: OllamaService = .init()) {
        self.ollamaService = ollamaService
    }
    
    func sendMessage() async {
        guard !userPrompt.isEmpty else { return }
        
        // Add user message to chat
        let userMessage = ChatMessage(role: "user", content: userPrompt)
        messages.append(userMessage)
        userPrompt = ""
        
        // Start streaming assistant response
        isStreaming = true
        isLoading = true
        errorMessage = nil
        
        // Create a new message for the assistant - we'll append to this as we get responses
        let assistantMessage = ChatMessage(role: "assistant", content: "")
        messages.append(assistantMessage)
        
        do {
            // Fetch models to get the selected model
            let models = try await ollamaService.fetchModels()
            if let firstModel = models.first {
                // Now we send to the model with the full conversation context
                let allMessages = messages.filter { $0.role == "user" || $0.role == "assistant" }
                
                let stream = try await ollamaService.sendMessage(
                    model: firstModel.name,
                    messages: allMessages
                )
                
                // Process the streaming response - simplified approach
                for await response in stream {
                    if response.done {
                        // End of response
                        isStreaming = false
                        isLoading = false
                        break
                    } else {
                        // Update the last assistant message with new content
                        if let lastAssistantIndex = messages.lastIndex(where: { $0.role == "assistant" }) {
                            // Create new message with updated content
                            var updatedMessage = messages[lastAssistantIndex]
                            updatedMessage.content += response.message.content
                            messages[lastAssistantIndex] = updatedMessage
                        }
                    }
                }
            }
        } catch {
            isLoading = false
            isStreaming = false
            errorMessage = error.localizedDescription
            print("Error streaming response: \(error)")
        }
    }
    
    func clearChat() {
        messages.removeAll()
    }
    
    func addMessage(role: String, content: String) {
        let message = ChatMessage(role: role, content: content)
        messages.append(message)
    }
}
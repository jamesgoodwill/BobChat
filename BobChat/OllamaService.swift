//
//  OllamaService.swift
//  BobChat
//
//  Created by James Goodwill on 6/26/26.
//

import Foundation
import Combine

class OllamaService: ObservableObject {
    @Published var baseURL: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userDefaults = UserDefaults.standard
    private let baseURLKey = "OllamaBaseURL"
    private let session = URLSession.shared
    
    init() {
        // Load saved base URL
        if let savedURL = userDefaults.string(forKey: baseURLKey) {
            baseURL = savedURL
        } else {
            // Default to local Ollama server
            baseURL = "http://10.0.0.155:11434"
        }
    }
    
    func setBaseURL(_ url: String) {
        baseURL = url
        userDefaults.set(url, forKey: baseURLKey)
        userDefaults.synchronize()
    }
    
    func fetchModels() async throws -> [OllamaModel] {
        guard !baseURL.isEmpty else {
            throw URLError(.badURL)
        }
        
        guard let url = URL(string: "\(baseURL)/api/tags") else {
            throw URLError(.badURL)
        }
        
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        do {
            let (data, response) = try await session.data(for: .init(url: url))
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.cannotDecodeContentData)
            }
            
            let result = try JSONDecoder().decode(OllamaTagsResponse.self, from: data)
            return result.models
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func sendMessage(model: String, messages: [ChatMessage]) async throws -> AsyncStream<ChatResponse> {
        guard !baseURL.isEmpty else {
            throw URLError(.badURL)
        }
        
        guard let url = URL(string: "\(baseURL)/api/chat") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let chatRequest = ChatRequest(model: model, messages: messages, stream: true)
        request.httpBody = try JSONEncoder().encode(chatRequest)
        
        let (streamingData, response) = try await session.bytes(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.cannotDecodeContentData)
        }
        
        return AsyncStream<ChatResponse> { continuation in
            Task {
                for try await line in streamingData.lines {
                    if line.isEmpty { continue }
                    
                    do {
                        let response = try JSONDecoder().decode(ChatResponse.self, from: line.data(using: .utf8)!)
                        continuation.yield(response)
                    } catch {
                        // If we can't decode one line, continue with others
                        print("Error decoding line: \(error)")
                    }
                }
                continuation.finish()
            }
        }
    }
}

// MARK: - Data Models

struct OllamaModel: Codable, Identifiable {
    let id = UUID()
    let name: String
    let modifiedAt: Date
    let size: Int
    let digest: String
}

struct OllamaTagsResponse: Codable {
    let models: [OllamaModel]
}

struct ChatMessage: Identifiable, Codable {
    let id = UUID()
    var role: String // "user" or "assistant"
    var content: String
    let timestamp: Date
    
    init(role: String, content: String) {
        self.role = role
        self.content = content
        self.timestamp = Date()
    }
}


struct ChatRequest: Codable {
    let model: String
    let messages: [ChatMessage]
    let stream: Bool
}

struct ChatResponse: Codable {
    let model: String
    let createdAt: Date
    let message: ChatMessage
    let done: Bool
    let totalDuration: TimeInterval?
    let loadDuration: TimeInterval?
    let promptEvalCount: Int?
    let evalCount: Int?
    let evalDuration: TimeInterval?
}
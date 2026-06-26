//
//  ModelViewModel.swift
//  BobChat
//
//  Created by James Goodwill on 6/26/26.
//

import Foundation
import Combine

class ModelViewModel: ObservableObject {
    @Published var models: [OllamaModel] = []
    @Published var selectedModel: OllamaModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userDefaults = UserDefaults.standard
    private let selectedModelKey = "SelectedModel"
    private let ollamaService: OllamaService
    
    init(ollamaService: OllamaService = .init()) {
        self.ollamaService = ollamaService
        loadSelectedModel()
    }
    
    func fetchModels() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedModels = try await ollamaService.fetchModels()
            models = fetchedModels
            
            // Select the first model if none selected
            if selectedModel == nil, let firstModel = fetchedModels.first {
                selectModel(firstModel)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func selectModel(_ model: OllamaModel) {
        selectedModel = model
        userDefaults.set(model.name, forKey: selectedModelKey)
        userDefaults.synchronize()
    }
    
    private func loadSelectedModel() {
        if let modelName = userDefaults.string(forKey: selectedModelKey),
           let model = models.first(where: { $0.name == modelName }) {
            selectedModel = model
        }
    }
    
    func refreshModels() {
        Task {
            await fetchModels()
        }
    }
}
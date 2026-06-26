//
//  ModelPickerView.swift
//  BobChat
//
//  Created by James Goodwill on 6/26/26.
//

import SwiftUI

struct ModelPickerView: View {
    @EnvironmentObject private var modelViewModel: ModelViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                if modelViewModel.isLoading {
                    ProgressView("Loading models...")
                        .padding()
                } else if let errorMessage = modelViewModel.errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48, weight: .thin))
                            .foregroundColor(.orange)
                        
                        Text("Error loading models")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(errorMessage)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding()
                        
                        Button("Retry") {
                            Task {
                                await modelViewModel.fetchModels()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                    }
                    .padding()
                } else if modelViewModel.models.isEmpty {
                    VStack {
                        Image(systemName: "clock")
                            .font(.system(size: 48, weight: .thin))
                            .foregroundColor(.secondary)
                        
                        Text("No models found")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Connect to your Ollama server and make sure models are pulled")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding()
                    }
                    .padding()
                } else {
                    List(modelViewModel.models, id: \.id) { model in
                        Button {
                            modelViewModel.selectModel(model)
                            dismiss()
                        } label: {
                            HStack {
                                Text(model.name)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                if modelViewModel.selectedModel?.name == model.name {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Models")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Refresh") {
                        Task {
                            await modelViewModel.fetchModels()
                        }
                    }
                    .disabled(modelViewModel.isLoading)
                }
            }
            .onAppear {
                Task {
                    await modelViewModel.fetchModels()
                }
            }
        }
    }
}

#Preview {
    ModelPickerView()
        .environmentObject(ModelViewModel())
}
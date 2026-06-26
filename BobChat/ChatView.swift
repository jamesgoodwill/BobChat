//
//  ChatView.swift
//  BobChat
//
//  Created by James Goodwill on 6/26/26.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject private var ollamaService: OllamaService
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @EnvironmentObject private var modelViewModel: ModelViewModel
    
    @State private var isModelPickerPresented = false
    @State private var isSettingsPresented = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if chatViewModel.messages.isEmpty {
                    emptyChatView
                } else {
                    messageListView
                }
                
                inputView
            }
            .navigationTitle("BobChat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("New Chat") {
                        chatViewModel.clearChat()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Model") {
                        isModelPickerPresented = true
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Settings") {
                        isSettingsPresented = true
                    }
                }
            }
            .sheet(isPresented: $isModelPickerPresented) {
                ModelPickerView()
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $isSettingsPresented) {
                SettingsView()
                    .presentationDetents([.medium])
            }
            .onAppear {
                Task {
                    await modelViewModel.fetchModels()
                }
            }
        }
    }
    
    private var emptyChatView: some View {
        VStack(spacing: 20) {
            Image(systemName: "messagebubble.and.text.below.rectangle")
                .font(.system(size: 64, weight: .thin))
                .foregroundColor(.blue)
            
            Text("BobChat")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Start a conversation with your Ollama model")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
    
    private var messageListView: some View {
        ScrollView {
            ScrollViewReader { proxy in
                ForEach(chatViewModel.messages) { message in
                    MessageBubbleView(message: message)
                        .id(message.id)
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                }
                .onChange(of: chatViewModel.messages) { _ in
                    // Scroll to bottom when new message is added
                    if let lastId = chatViewModel.messages.last?.id {
                        DispatchQueue.main.async {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }
        }
        .scrollIndicators(.never)
    }
    
    private var inputView: some View {
        HStack {
            TextField("Type a message...", text: $chatViewModel.userPrompt, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(5)
                .padding(.vertical, 8)
            
            Button("Send") {
                Task {
                    await chatViewModel.sendMessage()
                }
            }
            .disabled(chatViewModel.userPrompt.isEmpty || chatViewModel.isStreaming)
            .buttonStyle(.borderedProminent)
            .tint(.blue)
        }
        .padding()
    }
}

struct MessageBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.role == "user" {
                Spacer()
            }
            
            VStack(alignment: message.role == "user" ? .trailing : .leading) {
                Text(message.content)
                    .padding(12)
                    .background(message.role == "user" ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(message.role == "user" ? .white : .primary)
                    .cornerRadius(16)
                    .multilineTextAlignment(.leading)
            }
            .padding(.vertical, 2)
            
            if message.role == "assistant" {
                Spacer()
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    ChatView()
        .environmentObject(OllamaService())
        .environmentObject(ChatViewModel())
        .environmentObject(ModelViewModel())
}
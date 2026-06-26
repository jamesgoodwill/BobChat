# BobChat

BobChat is a native iOS/iPadOS SwiftUI application that serves as a chat front-end for Ollama, a local large language model server.

## Features

- Connect to your local Ollama server
- Chat with your local LLM models
- Apple Messages-style interface
- Streaming responses from Ollama
- Model selection
- Conversation management

## Requirements

- iOS 17+ or iPadOS 17+
- Xcode 16+
- Local Ollama server running on the same network

## Setup

1. Start your Ollama server locally
2. Open BobChat in Xcode
3. Run the app
4. Enter your Ollama server URL in Settings (default: `http://10.0.0.155:11434`)
5. Select a model from the model picker
6. Start chatting!

## How to Run

- Open the BobChat.xcodeproj file in Xcode
- Select your target device (iPhone or iPad)
- Build and run the application

## Notes

- BobChat communicates with Ollama over plain HTTP (local use only)
- For Simulator, Ollama should be reachable at `http://localhost:11434`
- The app stores server URL in UserDefaults
- Conversation history is not persisted (for this implementation)
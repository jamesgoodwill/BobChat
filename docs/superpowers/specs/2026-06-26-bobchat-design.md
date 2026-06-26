# BobChat Design Specification

## Project Overview
BobChat is a native iOS/iPadOS SwiftUI application that serves as a chat front-end for Ollama, a local large language model server. The app provides a first-party Apple experience with clean, responsive UI that feels familiar to iOS users.

## System Architecture

### Core Components

1. **OllamaService** - Handles all networking with the Ollama server
2. **ChatViewModel** - Manages chat state and business logic
3. **ModelViewModel** - Manages model selection and state
4. **ContentView** - Main app entry point
5. **ChatView** - Main chat interface
6. **ModelPickerView** - Model selection UI
7. **SettingsView** - Configuration settings

### Architecture Pattern
MVVM with ObservableObject / @Observable (iOS 17+) for state management
Actor-based architecture for thread-safe networking operations

## Data Flow

### Initialization Flow
1. App launches
2. Check if Ollama URL is configured in UserDefaults
3. If not configured, show onboarding
4. If configured, fetch available models
5. Load last selected model
6. Show chat interface

### Chat Flow
1. User enters message
2. Message added to conversation history
3. POST request to `/api/chat` with streaming enabled
4. Stream NDJSON responses from Ollama
5. Parse each JSON line and append to assistant response
6. Once response completes, mark as finished

## Implementation Details

### Networking Layer (OllamaService)
- URLSession with streaming data task
- Handles connection errors gracefully
- Parse NDJSON responses into appropriate models
- Uses official Ollama REST API endpoints:
  - GET `/api/tags` for model list
  - POST `/api/chat` with streaming for chat

### Data Models
```swift
struct OllamaModel: Codable {
    let name: String
    let modifiedAt: Date
    let size: Int
    let digest: String
}

struct ChatMessage: Identifiable, Codable {
    let id = UUID()
    let role: String // "user" or "assistant"
    let content: String
    let timestamp: Date
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
```

### UI Components

#### ContentView
- Root view that manages navigation
- Shows onboarding if no URL configured
- Displays the main chat interface
- Manages model selection and settings

#### ChatView
- Scrollable message list
- Message bubbles styled like Apple Messages:
  - User messages: right-aligned, blue bubble
  - Assistant messages: left-aligned, gray bubble
- Input bar with multi-line TextField and Send button
- Auto-scroll to latest message
- Disable Send button during streaming
- Show Stop button to cancel in-flight requests

#### ModelPickerView
- List of available models from `/api/tags`
- Pull-to-refresh functionality
- Show loading indicator while fetching
- Empty-state view if Ollama unreachable
- Persist last-selected model in UserDefaults

#### SettingsView
- Server URL entry field (default: `http://10.0.0.155:11434`)
- Clear conversation history
- About section

### Error Handling
- Graceful handling of network errors
- User-facing alerts for connection issues
- Retry mechanisms for failed requests
- Empty state views for unavailable models

### Platform Support
- iOS 17+ and iPadOS 17+
- Universal support for iPhone and iPad
- NavigationSplitView for iPad layout
- NavigationStack for iPhone layout
- Dark Mode support via semantic colors

## Technical Requirements

### Dependencies
- Only Apple frameworks (SwiftUI, Foundation, Swift Concurrency)
- No third-party dependencies or CocoaPods

### Network Security
- Add `NSAppTransportSecurity` → `NSAllowsLocalNetworking: YES` to Info.plist
- Communicate over plain HTTP (local use only)
- Local network access required for Ollama connection

### Performance Considerations
- Streaming responses handled efficiently
- Memory management for long conversations
- Auto-scroll optimization
- Thread safety with async/await and proper state management

## Implementation Plan (Summary)
1. Create data models and networking layer
2. Implement OllamaService with URLSession streaming
3. Build ViewModels for chat and model selection
4. Create UI components following design guidelines
5. Implement full chat flow with streaming
6. Add settings and configuration
7. Polish UI/UX and add nice-to-have features
8. Testing and validation

## Future Extensions (Optional)
- Markdown rendering in assistant messages
- Token-per-second display
- Haptic feedback on response completion
- App icon design
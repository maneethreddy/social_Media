# Social Media Feed App

A Twitter-like social media feed application built with SwiftUI, demonstrating MVVM architecture with Combine for reactive programming.

## Features

### ✅ Implemented Requirements

1. **MVVM Architecture Implementation**
   - Clear separation between Model, View, and ViewModel
   - Data binding using Combine without third-party libraries
   - ViewModels are fully testable without UI dependencies
   - Reactive programming with Combine

2. **Feed Functionality**
   - Display posts with text, images, and user information
   - Pull-to-refresh functionality
   - Infinite scrolling with pagination
   - Real-time state management

3. **UI Modularity**
   - Reusable feed item components
   - Support for multiple feed item types (text, image, video preview)
   - Plugin system for custom feed items
   - Dynamic height calculation for variable content

4. **Complex State Management**
   - State machines with multiple concurrent states
   - Complex state transitions and error handling
   - Network state monitoring and offline detection
   - Sync state management with pending operations

5. **Real-time Updates**
   - WebSocket simulation for live updates
   - Real-time post notifications
   - Live like/comment updates
   - Connection status monitoring
   - Heartbeat mechanism for connection health

6. **Offline Functionality**
   - Local data persistence with UserDefaults and file system
   - Offline-first architecture with data caching
   - Pending operations queue for offline actions
   - Automatic sync when connection is restored
   - Image caching for offline viewing

### 🎯 Additional Features

- **Beautiful UI**: Modern, clean design with proper spacing and shadows
- **Loading States**: Proper loading indicators and empty states
- **Error Handling**: User-friendly error messages
- **Responsive Design**: Adapts to different screen sizes
- **Mock Data**: Realistic mock data for demonstration

## Architecture

### MVVM + Combine

The app follows the MVVM (Model-View-ViewModel) architecture pattern with Combine for reactive data binding:

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│       View      │◄──►│   ViewModel      │◄──►│      Model      │
│   (SwiftUI)     │    │   (Combine)      │    │   (Data)        │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### Project Structure

```
social_Media/
├── Models/
│   ├── Post.swift                 # Data models for posts and users
│   └── AppState.swift             # Complex state management and state machines
├── Services/
│   ├── PostService.swift          # Data layer and API calls
│   ├── OfflineStorageService.swift # Offline data persistence and caching
│   └── RealTimeService.swift      # Real-time updates and WebSocket simulation
├── ViewModels/
│   └── FeedViewModel.swift        # Business logic and state management
├── Views/
│   ├── FeedView.swift             # Main feed view with complex state handling
│   └── Components/
│       └── PostCardView.swift     # Reusable post component
├── Plugins/
│   └── FeedItemPlugin.swift       # Plugin system for feed items
└── ContentView.swift              # Root view
```

## Key Components

### 1. Models (`Post.swift`)
- `Post`: Represents a social media post with all necessary properties
- `User`: Represents a user with profile information
- `PostType`: Enum for different post types

### 2. Services
- **PostService.swift**: Handles data operations and API calls
- **OfflineStorageService.swift**: Manages local data persistence and offline functionality
- **RealTimeService.swift**: Handles real-time updates and WebSocket connections

### 3. ViewModels (`FeedViewModel.swift`)
- Manages application state using `@Published` properties
- Handles data fetching with Combine
- Implements pagination and refresh logic
- Provides utility functions for formatting
- Integrates complex state management, offline functionality, and real-time updates

### 4. Views
- **FeedView**: Main container with complex state handling and navigation
- **PostCardView**: Reusable component for displaying posts
- **LoadingView**: Loading state component
- **EmptyStateView**: Empty state component
- **OfflineStateView**: Offline mode interface
- **ErrorStateView**: Error handling interface
- **ConnectionStatusView**: Real-time connection indicator

### 5. Plugin System (`FeedItemPlugin.swift`)
- Extensible architecture for different post types
- Supports text, image, and video posts
- Easy to add new post types without modifying existing code

## Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0 or later
- Swift 5.9 or later

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd social_Media
```

2. Open the project in Xcode:
```bash
open social_Media.xcodeproj
```

3. Build and run the project:
   - Select your target device or simulator
   - Press `Cmd + R` or click the Run button

## Usage

### Basic Features

1. **View Feed**: The app loads with a social media feed showing mock posts
2. **Pull to Refresh**: Pull down on the feed to refresh and load new posts
3. **Infinite Scrolling**: Scroll to the bottom to automatically load more posts
4. **Like Posts**: Tap the heart icon to like/unlike posts
5. **View Different Post Types**: The feed includes text-only, image, and video posts

### Plugin System

The app uses a plugin system to handle different post types:

```swift
// Register a new plugin
let customPlugin = CustomPostPlugin(identifier: "custom")
pluginManager.registerPlugin(customPlugin)
```

## Technical Implementation

### Combine Integration

The app extensively uses Combine for reactive programming:

```swift
// Example: Fetching posts with Combine
postService.fetchPosts(page: currentPage, limit: postsPerPage)
    .receive(on: DispatchQueue.main)
    .sink(
        receiveCompletion: { completion in
            // Handle completion
        },
        receiveValue: { posts in
            // Handle received posts
        }
    )
    .store(in: &cancellables)
```

### State Management

State is managed through `@Published` properties in the ViewModel:

```swift
@Published var posts: [Post] = []
@Published var isLoading = false
@Published var isRefreshing = false
@Published var errorMessage: String?
```

### Error Handling

Comprehensive error handling with user-friendly messages:

```swift
.alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
    Button("OK") {
        viewModel.errorMessage = nil
    }
} message: {
    if let errorMessage = viewModel.errorMessage {
        Text(errorMessage)
    }
}
```

## Testing

The architecture is designed for easy testing:

- ViewModels can be tested independently of UI
- Services can be mocked for unit testing
- Models are simple data structures
- UI components are isolated and reusable

## Future Enhancements

1. **Real API Integration**: Replace mock data with real API calls
2. **User Authentication**: Add login/signup functionality
3. **Comments System**: Implement comment functionality
4. **Push Notifications**: Add real-time notifications
5. **Core Data Integration**: Replace file-based storage with Core Data
6. **Video Playback**: Add actual video player functionality
7. **Search**: Add search functionality
8. **User Profiles**: Add user profile pages
9. **Real WebSocket**: Replace simulation with actual WebSocket connections
10. **Background Sync**: Implement background app refresh for data sync

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is created for educational purposes as part of an iOS development assignment.

## Acknowledgments

- Built with SwiftUI and Combine
- Uses MVVM architecture pattern
- Implements modern iOS development practices
- Demonstrates reactive programming concepts 
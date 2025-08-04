import Foundation
import Combine

// MARK: - Complex State Management

enum FeedState: Equatable {
    case idle
    case loading
    case refreshing
    case loadingMore
    case error(String)
    case offline
    case empty
    case populated
}

enum NetworkState: Equatable {
    case connected
    case disconnected
    case connecting
}

enum SyncState: Equatable {
    case synced
    case syncing
    case pendingChanges
    case conflict
}

class AppStateManager: ObservableObject {
    @Published var feedState: FeedState = .idle
    @Published var networkState: NetworkState = .connected
    @Published var syncState: SyncState = .synced
    @Published var isOfflineMode = false
    @Published var pendingOperations: [String] = []
    @Published var lastSyncTimestamp: Date?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupStateObservers()
    }
    
    private func setupStateObservers() {
        // Monitor network state changes
        NotificationCenter.default.publisher(for: .connectivityChanged)
            .sink { [weak self] _ in
                self?.updateNetworkState()
            }
            .store(in: &cancellables)
    }
    
    func updateNetworkState() {
        // In a real app, you'd check actual network connectivity
        let isConnected = true // Placeholder
        networkState = isConnected ? .connected : .disconnected
        isOfflineMode = !isConnected
    }
    
    func setFeedState(_ state: FeedState) {
        DispatchQueue.main.async {
            self.feedState = state
        }
    }
    
    func addPendingOperation(_ operation: String) {
        pendingOperations.append(operation)
        syncState = .pendingChanges
    }
    
    func removePendingOperation(_ operation: String) {
        pendingOperations.removeAll { $0 == operation }
        if pendingOperations.isEmpty {
            syncState = .synced
        }
    }
}

// MARK: - State Transitions

extension AppStateManager {
    func transitionToLoading() {
        setFeedState(.loading)
    }
    
    func transitionToRefreshing() {
        setFeedState(.refreshing)
    }
    
    func transitionToLoadingMore() {
        setFeedState(.loadingMore)
    }
    
    func transitionToError(_ error: String) {
        setFeedState(.error(error))
    }
    
    func transitionToOffline() {
        setFeedState(.offline)
        isOfflineMode = true
    }
    
    func transitionToPopulated() {
        setFeedState(.populated)
    }
    
    func transitionToEmpty() {
        setFeedState(.empty)
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let connectivityChanged = Notification.Name("connectivityChanged")
    static let dataSyncCompleted = Notification.Name("dataSyncCompleted")
    static let offlineModeEnabled = Notification.Name("offlineModeEnabled")
} 
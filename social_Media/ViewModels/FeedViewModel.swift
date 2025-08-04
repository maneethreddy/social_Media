import Foundation
import Combine

class FeedViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var errorMessage: String?
    @Published var hasMorePosts = true
    
    // Complex state management
    @Published var appState: AppStateManager
    @Published var offlineStorage: OfflineStorageService
    
    private let postService = PostService()
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 1
    private let postsPerPage = 10
    
    init() {
        self.appState = AppStateManager()
        self.offlineStorage = OfflineStorageService()
        setupOfflineObservers()
        loadPosts()
    }
    
    func loadPosts() {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        appState.setFeedState(.loading)
        
        postService.fetchPosts(page: currentPage, limit: postsPerPage)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.appState.setFeedState(.error(error.localizedDescription))
                    } else {
                        self?.appState.setFeedState(self?.posts.isEmpty == false ? .populated : .empty)
                    }
                },
                receiveValue: { [weak self] newPosts in
                    self?.posts.append(contentsOf: newPosts)
                    self?.hasMorePosts = newPosts.count == self?.postsPerPage
                    self?.currentPage += 1
                    
                    // Save posts offline for future use
                    self?.savePostsOffline()
                }
            )
            .store(in: &cancellables)
    }
    
    func refreshPosts() {
        guard !isRefreshing else { return }
        
        isRefreshing = true
        currentPage = 1
        hasMorePosts = true
        appState.setFeedState(.refreshing)
        
        postService.fetchPosts(page: currentPage, limit: postsPerPage)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isRefreshing = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.appState.setFeedState(.error(error.localizedDescription))
                    } else {
                        self?.appState.setFeedState(self?.posts.isEmpty == false ? .populated : .empty)
                    }
                },
                receiveValue: { [weak self] newPosts in
                    self?.posts = newPosts
                    self?.hasMorePosts = newPosts.count == self?.postsPerPage
                    self?.currentPage += 1
                    
                    // Save posts offline for future use
                    self?.savePostsOffline()
                }
            )
            .store(in: &cancellables)
    }
    
    func loadMorePosts() {
        guard hasMorePosts && !isLoading else { return }
        loadPosts()
    }
    
    func likePost(_ post: Post) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        
        postService.likePost(post)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Error liking post: \(error)")
                    }
                },
                receiveValue: { [weak self] updatedPost in
                    self?.posts[index] = updatedPost
                }
            )
            .store(in: &cancellables)
    }
    
    func formatTimestamp(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    func formatCount(_ count: Int) -> String {
        if count >= 1000000 {
            return String(format: "%.1fM", Double(count) / 1000000.0)
        } else if count >= 1000 {
            return String(format: "%.1fK", Double(count) / 1000.0)
        } else {
            return "\(count)"
        }
    }
    
    // MARK: - Offline Support
    
    private func setupOfflineObservers() {
        // Monitor offline storage changes
        offlineStorage.$isOfflineMode
            .sink { [weak self] isOffline in
                self?.handleOfflineModeChange(isOffline)
            }
            .store(in: &cancellables)
    }
    
    private func handleOfflineModeChange(_ isOffline: Bool) {
        if isOffline {
            appState.transitionToOffline()
        } else {
            appState.transitionToPopulated()
        }
    }
    
    func loadOfflinePosts() {
        let offlinePosts = offlineStorage.loadPosts()
        if !offlinePosts.isEmpty {
            posts = offlinePosts
            appState.transitionToPopulated()
        } else {
            appState.transitionToEmpty()
        }
    }
    
    func savePostsOffline() {
        offlineStorage.savePosts(posts)
    }
    
    func likePostOffline(_ post: Post) {
        let operation = PendingOperation(
            type: .likePost,
            data: ["postId": post.id, "isLiked": "true"]
        )
        offlineStorage.addPendingOperation(operation)
        
        // Update local state immediately for better UX
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            var updatedPost = posts[index]
            // Update like status
            posts[index] = updatedPost
        }
    }
    
    // MARK: - Testing Methods
    
    func simulateOfflineMode() {
        offlineStorage.isOfflineMode = true
        appState.transitionToOffline()
    }
    
    func simulateOnlineMode() {
        offlineStorage.isOfflineMode = false
        appState.transitionToPopulated()
    }
}

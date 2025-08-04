import SwiftUI

// Protocol for feed item plugins
protocol FeedItemPlugin {
    var identifier: String { get }
    func canHandle(_ post: Post) -> Bool
    func createView(for post: Post, viewModel: FeedViewModel) -> AnyView
}

// Base plugin implementation
class BaseFeedItemPlugin: FeedItemPlugin {
    let identifier: String
    
    init(identifier: String) {
        self.identifier = identifier
    }
    
    func canHandle(_ post: Post) -> Bool {
        return true // Default implementation
    }
    
    func createView(for post: Post, viewModel: FeedViewModel) -> AnyView {
        return AnyView(PostCardView(post: post, viewModel: viewModel))
    }
}

// Text-only post plugin
class TextPostPlugin: BaseFeedItemPlugin {
    override init(identifier: String) {
        super.init(identifier: "text_post")
    }
    
    override func canHandle(_ post: Post) -> Bool {
        return post.mediaURLs == nil || post.mediaURLs!.isEmpty
    }
    
    override func createView(for post: Post, viewModel: FeedViewModel) -> AnyView {
        return AnyView(TextPostCardView(post: post, viewModel: viewModel))
    }
}

// Image post plugin
class ImagePostPlugin: BaseFeedItemPlugin {
    override init(identifier: String) {
        super.init(identifier: "image_post")
    }
    
    override func canHandle(_ post: Post) -> Bool {
        return post.mediaURLs != nil && !post.mediaURLs!.isEmpty
    }
    
    override func createView(for post: Post, viewModel: FeedViewModel) -> AnyView {
        return AnyView(ImagePostCardView(post: post, viewModel: viewModel))
    }
}

// Video post plugin (for future extension)
class VideoPostPlugin: BaseFeedItemPlugin {
    override init(identifier: String) {
        super.init(identifier: "video_post")
    }
    
    override func canHandle(_ post: Post) -> Bool {
        // In a real app, you'd check for video URLs
        return post.content.lowercased().contains("video") || 
               post.content.lowercased().contains("watch")
    }
    
    override func createView(for post: Post, viewModel: FeedViewModel) -> AnyView {
        return AnyView(VideoPostCardView(post: post, viewModel: viewModel))
    }
}

// Plugin manager
class FeedItemPluginManager: ObservableObject {
    @Published var plugins: [FeedItemPlugin] = []
    
    init() {
        registerDefaultPlugins()
    }
    
    func registerPlugin(_ plugin: FeedItemPlugin) {
        plugins.append(plugin)
    }
    
    func getPlugin(for post: Post) -> FeedItemPlugin {
        return plugins.first { $0.canHandle(post) } ?? BaseFeedItemPlugin(identifier: "default")
    }
    
    private func registerDefaultPlugins() {
        registerPlugin(TextPostPlugin(identifier: "text"))
        registerPlugin(ImagePostPlugin(identifier: "image"))
        registerPlugin(VideoPostPlugin(identifier: "video"))
    }
}

// Specialized view for text-only posts
struct TextPostCardView: View {
    let post: Post
    let viewModel: FeedViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header (same as PostCardView)
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: post.author.profileImageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Text(String(post.author.displayName.prefix(1)))
                                .font(.headline)
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(post.author.displayName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if post.author.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                    }
                    
                    Text("@\(post.author.username)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.formatTimestamp(post.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Content with enhanced typography for text posts
            Text(post.content)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .lineSpacing(2)
            
            // Action buttons
            HStack(spacing: 20) {
                ActionButton(
                    icon: post.isLiked ? "heart.fill" : "heart",
                    count: post.likes,
                    color: post.isLiked ? .red : .secondary
                ) {
                    viewModel.likePost(post)
                }
                
                ActionButton(
                    icon: "message",
                    count: post.comments,
                    color: .secondary
                ) {
                    // Comment action
                }
                
                ActionButton(
                    icon: "arrow.2.squarepath",
                    count: post.shares,
                    color: .secondary
                ) {
                    // Share action
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// Specialized view for image posts
struct ImagePostCardView: View {
    let post: Post
    let viewModel: FeedViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header (same as PostCardView)
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: post.author.profileImageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Text(String(post.author.displayName.prefix(1)))
                                .font(.headline)
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(post.author.displayName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if post.author.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                    }
                    
                    Text("@\(post.author.username)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.formatTimestamp(post.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Content
            Text(post.content)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            // Enhanced media view for image posts
            if let mediaURLs = post.mediaURLs, !mediaURLs.isEmpty {
                MediaView(urls: mediaURLs)
                    .cornerRadius(12)
            }
            
            // Action buttons
            HStack(spacing: 20) {
                ActionButton(
                    icon: post.isLiked ? "heart.fill" : "heart",
                    count: post.likes,
                    color: post.isLiked ? .red : .secondary
                ) {
                    viewModel.likePost(post)
                }
                
                ActionButton(
                    icon: "message",
                    count: post.comments,
                    color: .secondary
                ) {
                    // Comment action
                }
                
                ActionButton(
                    icon: "arrow.2.squarepath",
                    count: post.shares,
                    color: .secondary
                ) {
                    // Share action
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// Placeholder for video posts
struct VideoPostCardView: View {
    let post: Post
    let viewModel: FeedViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: post.author.profileImageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Text(String(post.author.displayName.prefix(1)))
                                .font(.headline)
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(post.author.displayName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if post.author.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                    }
                    
                    Text("@\(post.author.username)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.formatTimestamp(post.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Content
            Text(post.content)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            // Video placeholder
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 200)
                .overlay(
                    VStack {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                        Text("Video Content")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                )
                .cornerRadius(12)
            
            // Action buttons
            HStack(spacing: 20) {
                ActionButton(
                    icon: post.isLiked ? "heart.fill" : "heart",
                    count: post.likes,
                    color: post.isLiked ? .red : .secondary
                ) {
                    viewModel.likePost(post)
                }
                
                ActionButton(
                    icon: "message",
                    count: post.comments,
                    color: .secondary
                ) {
                    // Comment action
                }
                
                ActionButton(
                    icon: "arrow.2.squarepath",
                    count: post.shares,
                    color: .secondary
                ) {
                    // Share action
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
} 
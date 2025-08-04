import Foundation
import Combine

class PostService: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    // Mock data for demonstration
    private let mockUsers = [
        User(username: "john_doe", displayName: "John Doe", profileImageURL: "https://picsum.photos/50/50?random=1", isVerified: true),
        User(username: "jane_smith", displayName: "Jane Smith", profileImageURL: "https://picsum.photos/50/50?random=2"),
        User(username: "tech_guru", displayName: "Tech Guru", profileImageURL: "https://picsum.photos/50/50?random=3", isVerified: true),
        User(username: "design_master", displayName: "Design Master", profileImageURL: "https://picsum.photos/50/50?random=4"),
        User(username: "swift_dev", displayName: "Swift Developer", profileImageURL: "https://picsum.photos/50/50?random=5", isVerified: true)
    ]
    
    private let mockImages = [
        "https://picsum.photos/400/300?random=10",
        "https://picsum.photos/400/300?random=11",
        "https://picsum.photos/400/300?random=12",
        "https://picsum.photos/400/300?random=13",
        "https://picsum.photos/400/300?random=14"
    ]
    
    func fetchPosts(page: Int = 1, limit: Int = 10) -> AnyPublisher<[Post], Error> {
        // Simulate network delay
        return Future<[Post], Error> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let posts = self.generateMockPosts(count: limit)
                promise(.success(posts))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func likePost(_ post: Post) -> AnyPublisher<Post, Error> {
        return Future<Post, Error> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                var updatedPost = post
                // In a real app, this would be handled by the backend
                promise(.success(updatedPost))
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func generateMockPosts(count: Int) -> [Post] {
        let mockContents = [
            "Just finished building an amazing iOS app with SwiftUI! 🚀 #iOS #SwiftUI #Development",
            "The new iOS 17 features are absolutely incredible. Can't wait to implement them in my projects! 📱",
            "Designing beautiful user interfaces is both an art and a science. Here's what I learned today...",
            "Working on a new social media app. The MVVM architecture with Combine is making everything so clean! 💻",
            "Sometimes the best code is the code you don't write. Keep it simple, keep it clean! ✨",
            "Debugging is like being a detective in a crime movie where you are also the murderer.",
            "The only way to learn a new programming language is by writing programs in it.",
            "Code is read much more often than it is written. Make it readable! 📖",
            "Just deployed my first app to the App Store! The journey has been incredible. 🎉",
            "SwiftUI has completely changed how I think about iOS development. The declarative approach is game-changing!"
        ]
        
        var posts: [Post] = []
        
        for i in 0..<count {
            let randomUser = mockUsers.randomElement()!
            let randomContent = mockContents.randomElement()!
            let randomLikes = Int.random(in: 0...1000)
            let randomComments = Int.random(in: 0...100)
            let randomShares = Int.random(in: 0...50)
            let randomTimestamp = Date().addingTimeInterval(-Double.random(in: 0...86400 * 7)) // Last 7 days
            
            // Randomly add media to some posts
            let hasMedia = Bool.random()
            let mediaURLs = hasMedia ? [mockImages.randomElement()!] : nil
            
            let post = Post(
                author: randomUser,
                content: randomContent,
                mediaURLs: mediaURLs,
                likes: randomLikes,
                comments: randomComments,
                shares: randomShares,
                timestamp: randomTimestamp
            )
            
            posts.append(post)
        }
        
        return posts.sorted { $0.timestamp > $1.timestamp }
    }
} 
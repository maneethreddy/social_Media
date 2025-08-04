import SwiftUI

struct PostCardView: View {
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
                
                Button(action: {
                    // More options
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondary)
                }
            }
            
            // Content
            Text(post.content)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            // Media
            if let mediaURLs = post.mediaURLs, !mediaURLs.isEmpty {
                MediaView(urls: mediaURLs)
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
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct ActionButton: View {
    let icon: String
    let count: Int
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text("\(count)")
                    .font(.caption)
            }
            .foregroundColor(color)
        }
    }
}

struct MediaView: View {
    let urls: [String]
    
    var body: some View {
        if urls.count == 1 {
            AsyncImage(url: URL(string: urls[0])) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    )
            }
            .frame(height: 200)
            .clipped()
            .cornerRadius(8)
        } else if urls.count > 1 {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 2), spacing: 4) {
                ForEach(urls.prefix(4), id: \.self) { url in
                    AsyncImage(url: URL(string: url)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                    }
                    .frame(height: 100)
                    .clipped()
                    .cornerRadius(4)
                }
            }
        }
    }
}

#Preview {
    let mockUser = User(username: "john_doe", displayName: "John Doe", profileImageURL: "https://picsum.photos/50/50?random=1", isVerified: true)
    let mockPost = Post(
        author: mockUser,
        content: "Just finished building an amazing iOS app with SwiftUI! 🚀 #iOS #SwiftUI #Development",
        mediaURLs: ["https://picsum.photos/400/300?random=10"],
        likes: 1234,
        comments: 56,
        shares: 7
    )
    
    PostCardView(post: mockPost, viewModel: FeedViewModel())
        .padding()
} 
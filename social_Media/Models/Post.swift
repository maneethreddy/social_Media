import Foundation

struct Post: Identifiable, Codable {
    let id: String
    let author: User
    let content: String
    let mediaURLs: [String]?
    let likes: Int
    let comments: Int
    let shares: Int
    let timestamp: Date
    let isLiked: Bool
    
    init(id: String = UUID().uuidString,
         author: User,
         content: String,
         mediaURLs: [String]? = nil,
         likes: Int = 0,
         comments: Int = 0,
         shares: Int = 0,
         timestamp: Date = Date(),
         isLiked: Bool = false) {
        self.id = id
        self.author = author
        self.content = content
        self.mediaURLs = mediaURLs
        self.likes = likes
        self.comments = comments
        self.shares = shares
        self.timestamp = timestamp
        self.isLiked = isLiked
    }
}

struct User: Identifiable, Codable {
    let id: String
    let username: String
    let displayName: String
    let profileImageURL: String?
    let isVerified: Bool
    
    init(id: String = UUID().uuidString,
         username: String,
         displayName: String,
         profileImageURL: String? = nil,
         isVerified: Bool = false) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.profileImageURL = profileImageURL
        self.isVerified = isVerified
    }
}

enum PostType {
    case text
    case image
    case video
    case mixed
} 
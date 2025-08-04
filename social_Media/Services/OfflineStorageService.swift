import Foundation
import Combine

// MARK: - Offline Storage Service

class OfflineStorageService: ObservableObject {
    private let userDefaults = UserDefaults.standard
    private let fileManager = FileManager.default
    private let documentsPath: String
    
    @Published var isOfflineMode = false
    @Published var lastSyncDate: Date?
    @Published var pendingOperations: [PendingOperation] = []
    
    init() {
        documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        loadOfflineData()
    }
    
    // MARK: - Data Persistence
    
    func savePosts(_ posts: [Post]) {
        do {
            let data = try JSONEncoder().encode(posts)
            let filePath = "\(documentsPath)/offline_posts.json"
            try data.write(to: URL(fileURLWithPath: filePath))
            userDefaults.set(Date(), forKey: "lastPostsSync")
        } catch {
            print("Error saving posts: \(error)")
        }
    }
    
    func loadPosts() -> [Post] {
        do {
            let filePath = "\(documentsPath)/offline_posts.json"
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            let posts = try JSONDecoder().decode([Post].self, from: data)
            return posts
        } catch {
            print("Error loading posts: \(error)")
            return []
        }
    }
    
    func saveUser(_ user: User) {
        do {
            let data = try JSONEncoder().encode(user)
            let filePath = "\(documentsPath)/user_profile.json"
            try data.write(to: URL(fileURLWithPath: filePath))
        } catch {
            print("Error saving user: \(error)")
        }
    }
    
    func loadUser() -> User? {
        do {
            let filePath = "\(documentsPath)/user_profile.json"
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            let user = try JSONDecoder().decode(User.self, from: data)
            return user
        } catch {
            print("Error loading user: \(error)")
            return nil
        }
    }
    
    // MARK: - Pending Operations
    
    func addPendingOperation(_ operation: PendingOperation) {
        pendingOperations.append(operation)
        savePendingOperations()
    }
    
    func removePendingOperation(_ id: String) {
        pendingOperations.removeAll { $0.id == id }
        savePendingOperations()
    }
    
    private func savePendingOperations() {
        do {
            let data = try JSONEncoder().encode(pendingOperations)
            userDefaults.set(data, forKey: "pendingOperations")
        } catch {
            print("Error saving pending operations: \(error)")
        }
    }
    
    private func loadOfflineData() {
        // Load pending operations
        if let data = userDefaults.data(forKey: "pendingOperations") {
            do {
                pendingOperations = try JSONDecoder().decode([PendingOperation].self, from: data)
            } catch {
                print("Error loading pending operations: \(error)")
            }
        }
        
        // Load last sync date
        lastSyncDate = userDefaults.object(forKey: "lastPostsSync") as? Date
    }
    
    // MARK: - Cache Management
    
    func cacheImage(_ imageData: Data, for url: String) {
        let fileName = url.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "image"
        let filePath = "\(documentsPath)/cache/\(fileName).jpg"
        
        do {
            try FileManager.default.createDirectory(atPath: "\(documentsPath)/cache", withIntermediateDirectories: true)
            try imageData.write(to: URL(fileURLWithPath: filePath))
        } catch {
            print("Error caching image: \(error)")
        }
    }
    
    func getCachedImage(for url: String) -> Data? {
        let fileName = url.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "image"
        let filePath = "\(documentsPath)/cache/\(fileName).jpg"
        
        do {
            return try Data(contentsOf: URL(fileURLWithPath: filePath))
        } catch {
            return nil
        }
    }
    
    func clearCache() {
        do {
            let cachePath = "\(documentsPath)/cache"
            try FileManager.default.removeItem(atPath: cachePath)
        } catch {
            print("Error clearing cache: \(error)")
        }
    }
    
    // MARK: - Offline Mode Management
    
    func enableOfflineMode() {
        isOfflineMode = true
        userDefaults.set(true, forKey: "offlineMode")
    }
    
    func disableOfflineMode() {
        isOfflineMode = false
        userDefaults.set(false, forKey: "offlineMode")
    }
    
    func checkOfflineMode() {
        isOfflineMode = userDefaults.bool(forKey: "offlineMode")
    }
}

// MARK: - Pending Operation Model

struct PendingOperation: Codable, Identifiable {
    let id: String
    let type: OperationType
    let data: [String: String]
    let timestamp: Date
    
    init(type: OperationType, data: [String: String]) {
        self.id = UUID().uuidString
        self.type = type
        self.data = data
        self.timestamp = Date()
    }
}

enum OperationType: String, Codable {
    case likePost = "like_post"
    case createPost = "create_post"
    case deletePost = "delete_post"
    case updateProfile = "update_profile"
} 
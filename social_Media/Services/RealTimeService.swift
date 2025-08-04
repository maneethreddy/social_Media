import Foundation
import Combine
import UIKit

// MARK: - Real-time Service

class RealTimeService: ObservableObject {
    @Published var isConnected = false
    @Published var lastMessageTimestamp: Date?
    @Published var connectionStatus: ConnectionStatus = .disconnected
    
    private var cancellables = Set<AnyCancellable>()
    private var messageTimer: Timer?
    private var heartbeatTimer: Timer?
    
    // Simulated WebSocket connection
    private var webSocketSimulator: WebSocketSimulator?
    
    init() {
        setupRealTimeConnection()
        setupNotificationObservers()
    }
    
    deinit {
        disconnect()
    }
    
    // MARK: - Connection Management
    
    func connect() {
        connectionStatus = .connecting
        
        // Simulate connection delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.connectionStatus = .connected
            self?.isConnected = true
            self?.startHeartbeat()
            self?.startMessageSimulation()
            
            // Notify that connection is established
            NotificationCenter.default.post(name: .realTimeConnected, object: nil)
        }
    }
    
    func disconnect() {
        connectionStatus = .disconnected
        isConnected = false
        stopHeartbeat()
        stopMessageSimulation()
        
        NotificationCenter.default.post(name: .realTimeDisconnected, object: nil)
    }
    
    // MARK: - Real-time Updates
    
    func subscribeToFeedUpdates() {
        // In a real app, this would subscribe to a specific feed channel
        print("Subscribed to feed updates")
    }
    
    func unsubscribeFromFeedUpdates() {
        // In a real app, this would unsubscribe from the feed channel
        print("Unsubscribed from feed updates")
    }
    
    func sendLikeUpdate(postId: String, isLiked: Bool) {
        let message = RealTimeMessage(
            type: .likeUpdate,
            data: [
                "postId": postId,
                "isLiked": String(isLiked),
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]
        )
        
        sendMessage(message)
    }
    
    func sendNewPost(_ post: Post) {
        let message = RealTimeMessage(
            type: .newPost,
            data: [
                "postId": post.id,
                "authorId": post.author.id,
                "content": post.content,
                "timestamp": ISO8601DateFormatter().string(from: post.timestamp)
            ]
        )
        
        sendMessage(message)
    }
    
    private func sendMessage(_ message: RealTimeMessage) {
        guard isConnected else {
            // Store for later if offline
            storeOfflineMessage(message)
            return
        }
        
        // Simulate message sending
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.lastMessageTimestamp = Date()
            NotificationCenter.default.post(name: .messageSent, object: message)
        }
    }
    
    // MARK: - Message Simulation
    
    private func startMessageSimulation() {
        messageTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.simulateIncomingMessage()
        }
    }
    
    private func stopMessageSimulation() {
        messageTimer?.invalidate()
        messageTimer = nil
    }
    
    private func simulateIncomingMessage() {
        guard isConnected else { return }
        
        let messageTypes: [MessageType] = [.newPost, .likeUpdate, .commentUpdate]
        let randomType = messageTypes.randomElement() ?? .newPost
        
        let message = RealTimeMessage(
            type: randomType,
            data: [
                "timestamp": ISO8601DateFormatter().string(from: Date()),
                "simulated": "true"
            ]
        )
        
        DispatchQueue.main.async { [weak self] in
            self?.handleIncomingMessage(message)
        }
    }
    
    private func handleIncomingMessage(_ message: RealTimeMessage) {
        lastMessageTimestamp = Date()
        
        switch message.type {
        case .newPost:
            NotificationCenter.default.post(name: .newPostReceived, object: message)
        case .likeUpdate:
            NotificationCenter.default.post(name: .likeUpdateReceived, object: message)
        case .commentUpdate:
            NotificationCenter.default.post(name: .commentUpdateReceived, object: message)
        case .userOnline:
            NotificationCenter.default.post(name: .userOnlineReceived, object: message)
        case .heartbeat:
            // Handle heartbeat - no notification needed
            break
        }
    }
    
    // MARK: - Heartbeat
    
    private func startHeartbeat() {
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.sendHeartbeat()
        }
    }
    
    private func stopHeartbeat() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
    }
    
    private func sendHeartbeat() {
        guard isConnected else { return }
        
        let heartbeat = RealTimeMessage(
            type: .heartbeat,
            data: ["timestamp": ISO8601DateFormatter().string(from: Date())]
        )
        
        // Simulate heartbeat
        print("Heartbeat sent")
    }
    
    // MARK: - Offline Message Storage
    
    private func storeOfflineMessage(_ message: RealTimeMessage) {
        // Store message for later sync
        var offlineMessages = UserDefaults.standard.array(forKey: "offlineMessages") as? [Data] ?? []
        
        do {
            let data = try JSONEncoder().encode(message)
            offlineMessages.append(data)
            UserDefaults.standard.set(offlineMessages, forKey: "offlineMessages")
        } catch {
            print("Error storing offline message: \(error)")
        }
    }
    
    func syncOfflineMessages() {
        guard isConnected else { return }
        
        let offlineMessages = UserDefaults.standard.array(forKey: "offlineMessages") as? [Data] ?? []
        
        for messageData in offlineMessages {
            do {
                let message = try JSONDecoder().decode(RealTimeMessage.self, from: messageData)
                sendMessage(message)
            } catch {
                print("Error decoding offline message: \(error)")
            }
        }
        
        // Clear offline messages after sync
        UserDefaults.standard.removeObject(forKey: "offlineMessages")
    }
    
    // MARK: - Setup
    
    private func setupRealTimeConnection() {
        // Auto-connect when service is initialized
        connect()
    }
    
    private func setupNotificationObservers() {
        // Listen for app state changes
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                if let self = self, !self.isConnected {
                    self.connect()
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                // Keep connection alive but reduce activity
                self?.stopMessageSimulation()
            }
            .store(in: &cancellables)
    }
}

// MARK: - Models

enum ConnectionStatus {
    case connected
    case connecting
    case disconnected
    case reconnecting
}

enum MessageType: String, Codable {
    case newPost = "new_post"
    case likeUpdate = "like_update"
    case commentUpdate = "comment_update"
    case userOnline = "user_online"
    case heartbeat = "heartbeat"
}

struct RealTimeMessage: Codable {
    let id: String
    let type: MessageType
    let data: [String: String]
    let timestamp: Date
    
    init(type: MessageType, data: [String: String]) {
        self.id = UUID().uuidString
        self.type = type
        self.data = data
        self.timestamp = Date()
    }
}

// MARK: - WebSocket Simulator

class WebSocketSimulator {
    private var isConnected = false
    private var messageHandler: ((RealTimeMessage) -> Void)?
    
    func connect() {
        isConnected = true
    }
    
    func disconnect() {
        isConnected = false
    }
    
    func send(_ message: RealTimeMessage) {
        // Simulate WebSocket send
        print("WebSocket: Sending message \(message.type)")
    }
    
    func onMessage(_ handler: @escaping (RealTimeMessage) -> Void) {
        messageHandler = handler
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let realTimeConnected = Notification.Name("realTimeConnected")
    static let realTimeDisconnected = Notification.Name("realTimeDisconnected")
    static let newPostReceived = Notification.Name("newPostReceived")
    static let likeUpdateReceived = Notification.Name("likeUpdateReceived")
    static let commentUpdateReceived = Notification.Name("commentUpdateReceived")
    static let userOnlineReceived = Notification.Name("userOnlineReceived")
    static let messageSent = Notification.Name("messageSent")
} 
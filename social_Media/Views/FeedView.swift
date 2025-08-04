import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @StateObject private var pluginManager = FeedItemPluginManager()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.posts.isEmpty && !viewModel.isLoading {
                    EmptyStateView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.posts) { post in
                                pluginManager.getPlugin(for: post).createView(for: post, viewModel: viewModel)
                                    .onAppear {
                                        if post.id == viewModel.posts.last?.id {
                                            viewModel.loadMorePosts()
                                        }
                                    }
                            }
                            
                            if viewModel.isLoading && !viewModel.posts.isEmpty {
                                LoadingView()
                                    .padding()
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        viewModel.refreshPosts()
                    }
                }
                
                if viewModel.isLoading && viewModel.posts.isEmpty {
                    LoadingView()
                }
                
                // Offline indicator
                if viewModel.offlineStorage.isOfflineMode {
                    VStack {
                        HStack {
                            Spacer()
                            HStack(spacing: 8) {
                                Image(systemName: "wifi.slash")
                                    .foregroundColor(.orange)
                                Text("Offline Mode")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(12)
                            .padding()
                        }
                        Spacer()
                    }
                }
            }
            .navigationTitle("Social Feed")
            .navigationBarTitleDisplayMode(.large)

            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Posts Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Pull down to refresh and see the latest posts from your network.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.2)
            
            Text("Loading posts...")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}



#Preview {
    FeedView()
} 
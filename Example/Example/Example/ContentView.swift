//
//  ContentView.swift
//  Example
//
//  Created by Nemanja Vlahovic on 31/5/25.
//

import SwiftUI
import FloeKit

struct ContentView: View {
    @State private var selectedTabId = "feed"
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var searchText = ""
    @State private var progressValue: Double = 0.0
    @State private var sliderValue: Double = 50.0
    @State private var profileText = "Building amazing apps with FloeKit! 🚀\n\nThis is a comprehensive showcase of all the beautiful components available in our design system."
    @State private var isProgressRunning = false
    
    // Mock data for demonstration
    @State private var posts: [Post] = [
        Post(id: 1, author: "Sarah Chen", avatar: "person.circle.fill", content: "Just shipped a new feature using FloeKit! The component library is incredible 🎉", likes: 42, timeAgo: "2h"),
        Post(id: 2, author: "Alex Rivera", avatar: "person.circle", content: "Working on some exciting UI animations. Can't wait to share the results!", likes: 28, timeAgo: "4h"),
        Post(id: 3, author: "Jordan Kim", avatar: "person.circle.fill", content: "FloeKit's design system makes building consistent UIs so much easier. Highly recommend! 💯", likes: 67, timeAgo: "6h")
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Main content area
                    ZStack {
                        // Tab content
                        Group {
                            if selectedTabId == "feed" {
                                feedView
                            } else if selectedTabId == "search" {
                                searchView
                            } else if selectedTabId == "profile" {
                                profileView
                            } else {
                                settingsView
                            }
                        }
                        
                        // Floating Action Button (only on feed tab)
                        if selectedTabId == "feed" {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Button {
                                        showToastMessage("New post created! 📝")
                                    } label: {
                                        Image(systemName: "plus")
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .frame(width: 56, height: 56)
                                            .background(FloeColors.primary)
                                            .clipShape(Circle())
                                            .shadow(color: FloeColors.primary.opacity(0.3), radius: 12, x: 0, y: 4)
                                    }
                                    .padding(.trailing, FloeSpacing.Size.lg.value)
                                    .padding(.bottom, 120) // Above floating tab bar
                                }
                            }
                        }
                        
                        // Toast overlay
                        if showToast {
                            VStack {
                                Spacer()
                                FloeToast(
                                    toastMessage,
                                    style: .success
                                )
                                .padding(.bottom, 140) // Above floating tab bar
                            }
                            .transition(.move(edge: .bottom))
                            .animation(.easeInOut, value: showToast)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // Floating Tab Bar
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(spacing: 0) {
                            FloeTabBar(
                                tabs: [
                                    FloeTabBar.Tab(id: "feed", title: "Feed", icon: Image(systemName: "house.fill")),
                                    FloeTabBar.Tab(id: "search", title: "Search", icon: Image(systemName: "magnifyingglass")),
                                    FloeTabBar.Tab(id: "profile", title: "Profile", icon: Image(systemName: "person.fill")),
                                    FloeTabBar.Tab(id: "settings", title: "Settings", icon: Image(systemName: "gearshape.fill"))
                                ],
                                selectedTabId: selectedTabId,
                                onTabSelected: { tabId in
                                    selectedTabId = tabId
                                }
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(.regularMaterial)
                                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 8)
                            )
                            .padding(.horizontal, FloeSpacing.Size.lg.value)
                            .padding(.bottom, geometry.safeAreaInsets.bottom + FloeSpacing.Size.sm.value - 48)
                        }
                        Spacer()
                    }
                }
            }
        }
    }
    
    // MARK: - Feed View
    private var feedView: some View {
        ScrollView {
            LazyVStack(spacing: FloeSpacing.Size.lg.value) {
                // Header
                VStack(spacing: FloeSpacing.Size.lg.value) {
                    HStack {
                        Text("Social Feed")
                            .font(FloeFont.font(.title))
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.horizontal, FloeSpacing.Size.lg.value)
                    .padding(.top, FloeSpacing.Size.md.value)
                }
                
                // Posts
                ForEach(posts) { post in
                    FloeCard {
                        VStack(alignment: .leading, spacing: FloeSpacing.Size.lg.value) {
                            // Post header
                            HStack(spacing: FloeSpacing.Size.md.value) {
                                FloeAvatar(
                                    initials: String(post.author.prefix(2)),
                                    size: .medium
                                )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(post.author)
                                        .font(FloeFont.font(.headline))
                                        .foregroundColor(.primary)
                                    Text(post.timeAgo)
                                        .font(FloeFont.font(.caption))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            
                            // Post content
                            Text(post.content)
                                .font(FloeFont.font(.body))
                                .foregroundColor(.primary)
                                .lineSpacing(4)
                            
                            // Post actions
                            HStack(spacing: FloeSpacing.Size.md.value) {
                                FloeButton("❤️ \(post.likes)", size: .small, backgroundColor: FloeColors.secondary, textColor: .white) {
                                    showToastMessage("Liked post by \(post.author)!")
                                }
                                
                                FloeButton("💬 Reply", size: .small, backgroundColor: FloeColors.surface, borderColor: FloeColors.primary, textColor: FloeColors.primary) {
                                    showToastMessage("Reply feature coming soon!")
                                }
                                
                                Spacer()
                            }
                        }
                        .padding(FloeSpacing.Size.lg.value)
                    }
                    .padding(.horizontal, FloeSpacing.Size.lg.value)
                }
            }
            .padding(.bottom, 140) // Space for floating tab bar
        }
    }
    
    // MARK: - Search View
    private var searchView: some View {
        VStack(spacing: 0) {
            // Search header
            VStack(spacing: FloeSpacing.Size.lg.value) {
                HStack {
                    Text("Discover")
                        .font(FloeFont.font(.title))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.horizontal, FloeSpacing.Size.lg.value)
                
                FloeSearchBar(
                    text: $searchText,
                    placeholder: "Search users, posts, topics..."
                )
                .padding(.horizontal, FloeSpacing.Size.lg.value)
            }
            .padding(.top, FloeSpacing.Size.md.value)
            
            // Search results
            ScrollView {
                LazyVStack(spacing: FloeSpacing.Size.lg.value) {
                    if searchText.isEmpty {
                        // Trending section when no search
                        VStack(alignment: .leading, spacing: FloeSpacing.Size.lg.value) {
                            HStack {
                                Text("Trending Topics")
                                    .font(FloeFont.font(.headline))
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding(.horizontal, FloeSpacing.Size.lg.value)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: FloeSpacing.Size.md.value) {
                                    ForEach(["SwiftUI", "FloeKit", "iOS", "Design", "Development"], id: \.self) { topic in
                                        FloeButton("#\(topic)", size: .small, backgroundColor: FloeColors.secondary, textColor: .white) {
                                            searchText = topic
                                            showToastMessage("Searching for \(topic)...")
                                        }
                                    }
                                }
                                .padding(.horizontal, FloeSpacing.Size.lg.value)
                            }
                        }
                    } else {
                        // Mock search results
                        ForEach(posts.filter { $0.content.localizedCaseInsensitiveContains(searchText) || $0.author.localizedCaseInsensitiveContains(searchText) }) { post in
                            FloeCard {
                                HStack(spacing: FloeSpacing.Size.md.value) {
                                    FloeAvatar(
                                        initials: String(post.author.prefix(2)),
                                        size: .small
                                    )
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(post.author)
                                            .font(FloeFont.font(.headline))
                                            .foregroundColor(.primary)
                                        Text(post.content)
                                            .font(FloeFont.font(.body))
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(FloeSpacing.Size.lg.value)
                            }
                            .padding(.horizontal, FloeSpacing.Size.lg.value)
                        }
                    }
                }
                .padding(.top, FloeSpacing.Size.lg.value)
                .padding(.bottom, 140) // Space for floating tab bar
            }
        }
    }
    
    // MARK: - Profile View
    private var profileView: some View {
        ScrollView {
            VStack(spacing: FloeSpacing.Size.xl.value) {
                // Profile header
                VStack(spacing: FloeSpacing.Size.lg.value) {
                    FloeAvatar(
                        initials: "YU",
                        size: .large
                    )
                    
                    VStack(spacing: FloeSpacing.Size.sm.value) {
                        Text("Your Profile")
                            .font(FloeFont.font(.title))
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("FloeKit Enthusiast")
                            .font(FloeFont.font(.subheadline))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, FloeSpacing.Size.lg.value)
                
                // Bio section
                FloeCard {
                    VStack(alignment: .leading, spacing: FloeSpacing.Size.lg.value) {
                        Text("Bio")
                            .font(FloeFont.font(.headline))
                            .foregroundColor(.primary)
                        
                        FloeTextView(
                            text: $profileText,
                            placeholder: "Tell us about yourself...",
                            size: .medium
                        )
                        
                        FloeButton("Save Bio", size: .medium, backgroundColor: FloeColors.primary, textColor: .white) {
                            showToastMessage("Bio updated successfully! ✨")
                        }
                    }
                    .padding(FloeSpacing.Size.lg.value)
                }
                .padding(.horizontal, FloeSpacing.Size.lg.value)
                
                // Stats section
                FloeCard {
                    VStack(spacing: FloeSpacing.Size.lg.value) {
                        Text("Profile Stats")
                            .font(FloeFont.font(.headline))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: FloeSpacing.Size.xl.value) {
                            VStack(spacing: FloeSpacing.Size.sm.value) {
                                Text("128")
                                    .font(FloeFont.font(.title))
                                    .fontWeight(.bold)
                                    .foregroundColor(FloeColors.accent)
                                Text("Posts")
                                    .font(FloeFont.font(.caption))
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(spacing: FloeSpacing.Size.sm.value) {
                                Text("1.2K")
                                    .font(FloeFont.font(.title))
                                    .fontWeight(.bold)
                                    .foregroundColor(FloeColors.accent)
                                Text("Followers")
                                    .font(FloeFont.font(.caption))
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(spacing: FloeSpacing.Size.sm.value) {
                                Text("486")
                                    .font(FloeFont.font(.title))
                                    .fontWeight(.bold)
                                    .foregroundColor(FloeColors.accent)
                                Text("Following")
                                    .font(FloeFont.font(.caption))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(FloeSpacing.Size.lg.value)
                }
                .padding(.horizontal, FloeSpacing.Size.lg.value)
            }
            .padding(.bottom, 140) // Space for floating tab bar
        }
    }
    
    // MARK: - Settings View
    private var settingsView: some View {
        ScrollView {
            VStack(spacing: FloeSpacing.Size.xl.value) {
                // Settings header
                HStack {
                    Text("Settings")
                        .font(FloeFont.font(.title))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.horizontal, FloeSpacing.Size.lg.value)
                .padding(.top, FloeSpacing.Size.lg.value)
                
                // Progress demo section
                FloeCard {
                    VStack(alignment: .leading, spacing: FloeSpacing.Size.lg.value) {
                        Text("Progress Indicator Demo")
                            .font(FloeFont.font(.headline))
                            .foregroundColor(.primary)
                        
                        FloeProgressIndicator(
                            progress: progressValue,
                            style: .linear,
                            size: .medium
                        )
                        
                        HStack {
                            FloeButton(isProgressRunning ? "Stop" : "Start Demo", size: .small, backgroundColor: FloeColors.primary, textColor: .white) {
                                toggleProgress()
                            }
                            
                            Spacer()
                            
                            Text("\(Int(progressValue * 100))%")
                                .font(FloeFont.font(.caption))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(FloeSpacing.Size.lg.value)
                }
                .padding(.horizontal, FloeSpacing.Size.lg.value)
                
                // Slider demo section
                FloeCard {
                    VStack(alignment: .leading, spacing: FloeSpacing.Size.lg.value) {
                        Text("Volume Control")
                            .font(FloeFont.font(.headline))
                            .foregroundColor(.primary)
                        
                        FloeSlider(
                            value: $sliderValue,
                            step: 1
                        )
                        
                        Text("Volume: \(Int(sliderValue))%")
                            .font(FloeFont.font(.caption))
                            .foregroundColor(.secondary)
                    }
                    .padding(FloeSpacing.Size.lg.value)
                }
                .padding(.horizontal, FloeSpacing.Size.lg.value)
                
                // Account section
                FloeCard {
                    VStack(spacing: FloeSpacing.Size.lg.value) {
                        Text("Account Actions")
                            .font(FloeFont.font(.headline))
                            .foregroundColor(.primary)
                        
                        VStack(spacing: FloeSpacing.Size.md.value) {
                            FloeButton("Edit Profile", size: .medium, backgroundColor: FloeColors.secondary, textColor: .white) {
                                showToastMessage("Profile editor coming soon!")
                            }
                            
                            FloeButton("Privacy Settings", size: .medium, backgroundColor: FloeColors.secondary, textColor: .white) {
                                showToastMessage("Privacy settings updated!")
                            }
                            
                            FloeButton("Sign Out", size: .medium, backgroundColor: FloeColors.error, textColor: .white) {
                                showToastMessage("Signed out successfully! 👋")
                            }
                        }
                    }
                    .padding(FloeSpacing.Size.lg.value)
                }
                .padding(.horizontal, FloeSpacing.Size.lg.value)
            }
            .padding(.bottom, 140) // Space for floating tab bar
        }
    }
    
    // MARK: - Helper Methods
    private func showToastMessage(_ message: String) {
        toastMessage = message
        showToast = true
        
        // Auto-dismiss after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showToast = false
        }
    }
    
    private func toggleProgress() {
        isProgressRunning.toggle()
        
        if isProgressRunning {
            // Simulate progress
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                if progressValue < 1.0 && isProgressRunning {
                    progressValue += 0.02
                } else {
                    timer.invalidate()
                    if progressValue >= 1.0 {
                        progressValue = 0.0
                        isProgressRunning = false
                        showToastMessage("Progress completed! 🎉")
                    }
                }
            }
        } else {
            progressValue = 0.0
        }
    }
}

// MARK: - Supporting Models
struct Post: Identifiable {
    let id: Int
    let author: String
    let avatar: String
    let content: String
    let likes: Int
    let timeAgo: String
}

#Preview {
    ContentView()
}

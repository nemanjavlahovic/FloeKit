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
    @State private var toastStyle: FloeToast.Style = .success
    @State private var searchText = ""
    @State private var progressValue: Double = 0.0
    @State private var sliderValue: Double = 50.0
    @State private var profileText = "Building amazing apps with FloeKit! 🚀\n\nThis is a comprehensive showcase of all the beautiful components available in our design system. I love creating beautiful user interfaces and exploring the latest in SwiftUI development. FloeKit makes it so much easier to build consistent, elegant apps with proper spacing, typography, and component architecture."
    @State private var isProgressRunning = false
    @State private var isLoadingFeed = false
    @State private var isLoadingSearch = false
    @State private var notificationCount = 3
    @State private var isDarkMode = false
    
    // Mock data for demonstration
    @State private var posts: [Post] = [
        Post(id: 1, author: "Sarah Chen", avatar: "person.circle.fill", content: "Just shipped a new feature using FloeKit! The component library is incredible 🎉", likes: 42, timeAgo: "2h", isVerified: true, isOnline: true),
        Post(id: 2, author: "Alex Rivera", avatar: "person.circle", content: "Working on some exciting UI animations. Can't wait to share the results!", likes: 28, timeAgo: "4h", isVerified: false, isOnline: false),
        Post(id: 3, author: "Jordan Kim", avatar: "person.circle.fill", content: "FloeKit's design system makes building consistent UIs so much easier. Highly recommend! 💯", likes: 67, timeAgo: "6h", isVerified: true, isOnline: true)
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
                                        showToastMessage("New post created! 📝", style: .success)
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
                                    style: toastStyle
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
                                    FloeTabBar.Tab(id: "profile", title: "Profile", icon: Image(systemName: "person.fill"), badge: notificationCount > 0 ? FloeTabBar.Tab.Badge(text: "\(notificationCount)") : nil),
                                    FloeTabBar.Tab(id: "settings", title: "Settings", icon: Image(systemName: "gearshape.fill"))
                                ],
                                selectedTabId: selectedTabId,
                                onTabSelected: { tabId in
                                    selectedTabId = tabId
                                    if tabId == "profile" {
                                        notificationCount = 0 // Clear notifications when visiting profile
                                    }
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
                // Header with refresh button
                VStack(spacing: FloeSpacing.Size.lg.value) {
                    HStack {
                        Text("Social Feed")
                            .font(FloeFont.font(.title))
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Spacer()
                        Button {
                            refreshFeed()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .font(.title3)
                                .foregroundColor(FloeColors.primary)
                        }
                    }
                    .padding(.horizontal, FloeSpacing.Size.lg.value)
                    .padding(.top, FloeSpacing.Size.md.value)
                }
                
                // Loading state
                if isLoadingFeed {
                    VStack(spacing: FloeSpacing.Size.lg.value) {
                        // Traditional skeleton approach
                        FloeSkeletonLoading(count: 1, spacing: FloeSpacing.Size.lg.value) {
                            FloeSkeleton.post()
                        }
                        .padding(.horizontal, FloeSpacing.Size.lg.value)
                        
                        // NEW: Modifier approach - skeleton applied to actual content
                        Text("This demonstrates the new .floeSkeleton() modifier approach")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, FloeSpacing.Size.lg.value)
                    }
                } else {
                    // Posts
                    ForEach(posts) { post in
                        FloeCard {
                            VStack(alignment: .leading, spacing: FloeSpacing.Size.lg.value) {
                                // Post header
                                HStack(spacing: FloeSpacing.Size.md.value) {
                                    FloeAvatar(
                                        initials: String(post.author.prefix(2)),
                                        size: .medium,
                                        statusIndicator: post.isOnline ? .online : .offline
                                    ) {
                                        showToastMessage("View \(post.author)'s profile", style: .info)
                                    }
                                    .floeSkeleton($isLoadingFeed, cornerRadius: 24)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 4) {
                                            Text(post.author)
                                                .font(FloeFont.font(.headline))
                                                .foregroundColor(.primary)
                                                .floeTextSkeleton($isLoadingFeed)
                                            if post.isVerified {
                                                Image(systemName: "checkmark.seal.fill")
                                                    .font(.caption)
                                                    .foregroundColor(FloeColors.primary)
                                            }
                                        }
                                        Text(post.timeAgo)
                                            .font(FloeFont.font(.caption))
                                            .foregroundColor(.secondary)
                                            .floeTextSkeleton($isLoadingFeed, lastLineWidth: 0.4)
                                    }
                                    
                                    Spacer()
                                    
                                    Button {
                                        showToastMessage("Post options coming soon!", style: .info)
                                    } label: {
                                        Image(systemName: "ellipsis")
                                            .foregroundColor(.secondary)
                                    }
                                    .floeSkeleton($isLoadingFeed, cornerRadius: 12)
                                }
                                
                                // Post content
                                Text(post.content)
                                    .font(FloeFont.font(.body))
                                    .foregroundColor(.primary)
                                    .lineSpacing(4)
                                    .floeTextSkeleton($isLoadingFeed, lines: 3, lastLineWidth: 0.7)
                                
                                // Post actions
                                HStack(spacing: FloeSpacing.Size.md.value) {
                                    FloeButton("❤️ \(post.likes)", size: .small, backgroundColor: FloeColors.secondary, textColor: .white) {
                                        showToastMessage("Liked post by \(post.author)!", style: .success)
                                    }
                                    .floeSkeleton($isLoadingFeed, cornerRadius: 16)
                                    
                                    FloeButton("💬 Reply", size: .small, backgroundColor: FloeColors.surface, borderColor: FloeColors.primary, textColor: FloeColors.primary) {
                                        showToastMessage("Reply feature coming soon!", style: .info)
                                    }
                                    .floeSkeleton($isLoadingFeed, cornerRadius: 16)
                                    
                                    FloeButton("📤 Share", size: .small, backgroundColor: FloeColors.surface, borderColor: FloeColors.neutral30, textColor: .secondary) {
                                        showToastMessage("Post shared!", style: .success)
                                    }
                                    .floeSkeleton($isLoadingFeed, cornerRadius: 16)
                                    
                                    Spacer()
                                }
                            }
                            .padding(FloeSpacing.Size.lg.value)
                        }
                        .padding(.horizontal, FloeSpacing.Size.lg.value)
                    }
                }
            }
            .padding(.bottom, 140) // Space for floating tab bar
        }
        .refreshable {
            await refreshFeedAsync()
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
                
                FloeSearchBar.withFilter(
                    text: $searchText,
                    placeholder: "Search users, posts, topics...",
                    onFilter: {
                        showToastMessage("Filter options coming soon!", style: .info)
                    },
                    onSearchSubmit: { query in
                        performSearch(query)
                    }
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
                                            showToastMessage("Searching for \(topic)...", style: .info)
                                        }
                                    }
                                }
                                .padding(.horizontal, FloeSpacing.Size.lg.value)
                            }
                            
                            // Recent searches
                            VStack(alignment: .leading, spacing: FloeSpacing.Size.md.value) {
                                HStack {
                                    Text("Recent Searches")
                                        .font(FloeFont.font(.headline))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Button("Clear") {
                                        showToastMessage("Recent searches cleared", style: .success)
                                    }
                                    .font(FloeFont.font(.caption))
                                    .foregroundColor(FloeColors.primary)
                                }
                                .padding(.horizontal, FloeSpacing.Size.lg.value)
                                
                                ForEach(["Design Systems", "SwiftUI Animation", "UI Components"], id: \.self) { search in
                                    FloeCard {
                                        HStack {
                                            Image(systemName: "clock")
                                                .foregroundColor(.secondary)
                                            Text(search)
                                                .font(FloeFont.font(.body))
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Button {
                                                searchText = search
                                            } label: {
                                                Image(systemName: "arrow.up.left")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .padding(FloeSpacing.Size.md.value)
                                    }
                                    .padding(.horizontal, FloeSpacing.Size.lg.value)
                                }
                            }
                        }
                    } else {
                        // Mock search results
                        if isLoadingSearch {
                            VStack(spacing: FloeSpacing.Size.md.value) {
                                FloeProgressIndicator.indeterminate(style: .circular, size: .medium)
                                Text("Searching...")
                                    .font(FloeFont.font(.caption))
                                    .foregroundColor(.secondary)
                            }
                            .padding(FloeSpacing.Size.xl.value)
                        } else {
                            ForEach(posts.filter { $0.content.localizedCaseInsensitiveContains(searchText) || $0.author.localizedCaseInsensitiveContains(searchText) }) { post in
                                FloeCard {
                                    HStack(spacing: FloeSpacing.Size.md.value) {
                                        FloeAvatar(
                                            initials: String(post.author.prefix(2)),
                                            size: .small,
                                            statusIndicator: post.isOnline ? .online : .offline
                                        )
                                        
                                        VStack(alignment: .leading, spacing: 6) {
                                            HStack(spacing: 4) {
                                                Text(post.author)
                                                    .font(FloeFont.font(.headline))
                                                    .foregroundColor(.primary)
                                                if post.isVerified {
                                                    Image(systemName: "checkmark.seal.fill")
                                                        .font(.caption2)
                                                        .foregroundColor(FloeColors.primary)
                                                }
                                            }
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
                }
                .padding(.top, FloeSpacing.Size.lg.value)
                .padding(.bottom, 140) // Space for floating tab bar
            }
            .onChange(of: searchText) { newValue in
                if !newValue.isEmpty {
                    performSearch(newValue)
                }
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
                        size: .extraLarge,
                        statusIndicator: .online,
                        shadowStyle: .elevated
                    ) {
                        showToastMessage("Edit profile photo", style: .info)
                    }
                    
                    VStack(spacing: FloeSpacing.Size.sm.value) {
                        HStack(spacing: 8) {
                            Text("Your Profile")
                                .font(FloeFont.font(.title))
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .floeTextSkeleton(false)
                            Image(systemName: "checkmark.seal.fill")
                                .font(.title3)
                                .foregroundColor(FloeColors.primary)
                        }
                        
                        Text("FloeKit Enthusiast")
                            .font(FloeFont.font(.subheadline))
                            .foregroundColor(.secondary)
                            .floeTextSkeleton(false, lastLineWidth: 0.8)
                    }
                }
                .padding(.top, FloeSpacing.Size.lg.value)
                
                // Bio section with expandable text
                FloeCard {
                    VStack(alignment: .leading, spacing: FloeSpacing.Size.lg.value) {
                        Text("Bio")
                            .font(FloeFont.font(.headline))
                            .foregroundColor(.primary)
                        
                        FloeTextView(
                            text: $profileText,
                            placeholder: "Tell us about yourself...",
                            size: .medium,
                            expansionStyle: .readMore(previewLines: 3),
                            showCharacterCount: true
                        )
                        
                        FloeButton("Save Bio", size: .medium, backgroundColor: FloeColors.primary, textColor: .white) {
                            showToastMessage("Bio updated successfully! ✨", style: .success)
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
                            .onTapGesture {
                                showToastMessage("View all posts", style: .info)
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
                            .onTapGesture {
                                showToastMessage("View followers", style: .info)
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
                            .onTapGesture {
                                showToastMessage("View following", style: .info)
                            }
                        }
                        
                        // Profile completion
                        VStack(spacing: FloeSpacing.Size.md.value) {
                            HStack {
                                Text("Profile Completion")
                                    .font(FloeFont.font(.subheadline))
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("85%")
                                    .font(FloeFont.font(.caption))
                                    .fontWeight(.semibold)
                                    .foregroundColor(FloeColors.accent)
                            }
                            
                            FloeProgressIndicator(
                                progress: 0.85,
                                style: .linear,
                                size: .medium,
                                primaryColor: FloeColors.accent
                            )
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
                
                // Theme Settings
                FloeCard {
                    VStack(alignment: .leading, spacing: FloeSpacing.Size.lg.value) {
                        Text("Appearance")
                            .font(FloeFont.font(.headline))
                            .foregroundColor(.primary)
                        
                        HStack {
                            Text("Dark Mode")
                                .font(FloeFont.font(.body))
                                .foregroundColor(.primary)
                            Spacer()
                            Toggle("", isOn: $isDarkMode)
                                .toggleStyle(SwitchToggleStyle(tint: FloeColors.primary))
                        }
                        
                        if isDarkMode {
                            Text("Dark mode is enabled system-wide")
                                .font(FloeFont.font(.caption))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(FloeSpacing.Size.lg.value)
                }
                .padding(.horizontal, FloeSpacing.Size.lg.value)
                
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
                            step: 1,
                            showLabels: .percentage,
                            enableHaptics: true
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
                                showToastMessage("Profile editor coming soon!", style: .info)
                            }
                            
                            FloeButton("Privacy Settings", size: .medium, backgroundColor: FloeColors.secondary, textColor: .white) {
                                showToastMessage("Privacy settings updated!", style: .success)
                            }
                            
                            FloeButton("Export Data", size: .medium, backgroundColor: FloeColors.accent, textColor: .white) {
                                showToastMessage("Data export started...", style: .info)
                            }
                            
                            FloeButton("Sign Out", size: .medium, backgroundColor: FloeColors.error, textColor: .white) {
                                showToastMessage("Signed out successfully! 👋", style: .warning)
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
    private func showToastMessage(_ message: String, style: FloeToast.Style = .success) {
        toastMessage = message
        toastStyle = style
        showToast = true
        
        // Auto-dismiss after varying durations based on style
//        let duration: Double = style == .error ? 5.0 : 3.0
//        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
//            showToast = false
//        }
    }
    
    private func refreshFeed() {
        isLoadingFeed = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoadingFeed = false
            showToastMessage("Feed refreshed! 🔄", style: .success)
        }
    }
    
    private func refreshFeedAsync() async {
        isLoadingFeed = true
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        isLoadingFeed = false
        showToastMessage("Feed refreshed! 🔄", style: .success)
    }
    
    private func performSearch(_ query: String) {
        isLoadingSearch = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isLoadingSearch = false
            showToastMessage("Found results for '\(query)'", style: .info)
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
                        showToastMessage("Progress completed! 🎉", style: .success)
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
    let isVerified: Bool
    let isOnline: Bool
}

#Preview {
    ContentView()
}

import SwiftUI

public struct FloeTabBar: View {
    public struct Tab: Hashable, Identifiable {
        public let id: String
        public let title: String
        public let icon: String
        public let selectedIcon: String?
        public let badge: String?
        
        public init(
            id: String,
            title: String,
            icon: String,
            selectedIcon: String? = nil,
            badge: String? = nil
        ) {
            self.id = id
            self.title = title
            self.icon = icon
            self.selectedIcon = selectedIcon
            self.badge = badge
        }
    }
    
    private let tabs: [Tab]
    @Binding private var selectedTabId: String
    private let onTabSelected: ((String) -> Void)?
    
    public init(
        tabs: [Tab],
        selectedTabId: Binding<String>,
        onTabSelected: ((String) -> Void)? = nil
    ) {
        self.tabs = tabs
        self._selectedTabId = selectedTabId
        self.onTabSelected = onTabSelected
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs) { tab in
                TabButton(
                    tab: tab,
                    isSelected: selectedTabId == tab.id,
                    action: {
                        selectedTabId = tab.id
                        onTabSelected?(tab.id)
                    }
                )
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(FloeColors.surface)
                .shadow(color: .black.opacity(0.1), radius: 8, y: 2)
        )
    }
}

private struct TabButton: View {
    let tab: FloeTabBar.Tab
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    Image(systemName: iconName)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(isSelected ? FloeColors.primary : FloeColors.neutral40)
                    
                    if let badge = tab.badge {
                        VStack {
                            HStack {
                                Spacer()
                                Text(badge)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule()
                                            .fill(Color.red)
                                    )
                                    .offset(x: 8, y: -8)
                            }
                            Spacer()
                        }
                    }
                }
                .frame(height: 24)
                
                Text(tab.title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? FloeColors.primary : FloeColors.neutral40)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? FloeColors.primary.opacity(0.1) : Color.clear)
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    private var iconName: String {
        if isSelected, let selectedIcon = tab.selectedIcon {
            return selectedIcon
        }
        return tab.icon
    }
}

// MARK: - Convenience Initializers

public extension FloeTabBar {
    static func home(selectedTabId: Binding<String>) -> FloeTabBar {
        FloeTabBar(
            tabs: [
                Tab(id: "home", title: "Home", icon: "house", selectedIcon: "house.fill"),
                Tab(id: "search", title: "Search", icon: "magnifyingglass"),
                Tab(id: "favorites", title: "Favorites", icon: "heart", selectedIcon: "heart.fill"),
                Tab(id: "profile", title: "Profile", icon: "person", selectedIcon: "person.fill")
            ],
            selectedTabId: selectedTabId
        )
    }
}

// MARK: - Tab Bar Controller

public struct FloeTabBarController<Content: View>: View {
    private let tabs: [FloeTabBar.Tab]
    @State private var selectedTabId: String
    private let content: (String) -> Content
    
    public init(
        tabs: [FloeTabBar.Tab],
        initialSelection: String,
        @ViewBuilder content: @escaping (String) -> Content
    ) {
        self.tabs = tabs
        self._selectedTabId = State(initialValue: initialSelection)
        self.content = content
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            content(selectedTabId)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            FloeTabBar(
                tabs: tabs,
                selectedTabId: $selectedTabId
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }
}

// MARK: - Previews

#Preview("Basic Tab Bar") {
    VStack(spacing: FloeSpacing.Size.lg.value) {
        Spacer()
        
        FloeTabBar(
            tabs: [
                FloeTabBar.Tab(id: "home", title: "Home", icon: "house", selectedIcon: "house.fill"),
                FloeTabBar.Tab(id: "search", title: "Search", icon: "magnifyingglass"),
                FloeTabBar.Tab(id: "profile", title: "Profile", icon: "person", selectedIcon: "person.fill")
            ],
            selectedTabId: .constant("home")
        )
        .padding()
    }
}

#Preview("Tab Bar with Badges") {
    VStack(spacing: FloeSpacing.Size.lg.value) {
        Spacer()
        
        FloeTabBar(
            tabs: [
                FloeTabBar.Tab(id: "home", title: "Home", icon: "house", selectedIcon: "house.fill"),
                FloeTabBar.Tab(id: "messages", title: "Messages", icon: "message", selectedIcon: "message.fill", badge: "3"),
                FloeTabBar.Tab(id: "notifications", title: "Alerts", icon: "bell", selectedIcon: "bell.fill", badge: "12"),
                FloeTabBar.Tab(id: "profile", title: "Profile", icon: "person", selectedIcon: "person.fill")
            ],
            selectedTabId: .constant("messages")
        )
        .padding()
    }
}

#Preview("Five Tab Layout") {
    VStack(spacing: FloeSpacing.Size.lg.value) {
        Spacer()
        
        FloeTabBar(
            tabs: [
                FloeTabBar.Tab(id: "home", title: "Home", icon: "house", selectedIcon: "house.fill"),
                FloeTabBar.Tab(id: "explore", title: "Explore", icon: "safari", selectedIcon: "safari.fill"),
                FloeTabBar.Tab(id: "create", title: "Create", icon: "plus.circle", selectedIcon: "plus.circle.fill"),
                FloeTabBar.Tab(id: "favorites", title: "Saved", icon: "bookmark", selectedIcon: "bookmark.fill", badge: "5"),
                FloeTabBar.Tab(id: "profile", title: "Profile", icon: "person", selectedIcon: "person.fill")
            ],
            selectedTabId: .constant("create")
        )
        .padding()
    }
}

#Preview("E-commerce Tab Bar") {
    VStack(spacing: FloeSpacing.Size.lg.value) {
        Spacer()
        
        FloeTabBar(
            tabs: [
                FloeTabBar.Tab(id: "shop", title: "Shop", icon: "bag", selectedIcon: "bag.fill"),
                FloeTabBar.Tab(id: "categories", title: "Browse", icon: "square.grid.2x2", selectedIcon: "square.grid.2x2.fill"),
                FloeTabBar.Tab(id: "cart", title: "Cart", icon: "cart", selectedIcon: "cart.fill", badge: "2"),
                FloeTabBar.Tab(id: "orders", title: "Orders", icon: "doc.text", selectedIcon: "doc.text.fill"),
                FloeTabBar.Tab(id: "account", title: "Account", icon: "person.circle", selectedIcon: "person.circle.fill")
            ],
            selectedTabId: .constant("cart")
        )
        .padding()
    }
}

#Preview("Social Media Tab Bar") {
    VStack(spacing: FloeSpacing.Size.lg.value) {
        Spacer()
        
        FloeTabBar(
            tabs: [
                FloeTabBar.Tab(id: "feed", title: "Feed", icon: "house", selectedIcon: "house.fill"),
                FloeTabBar.Tab(id: "discover", title: "Discover", icon: "magnifyingglass", selectedIcon: "magnifyingglass"),
                FloeTabBar.Tab(id: "camera", title: "Camera", icon: "camera", selectedIcon: "camera.fill"),
                FloeTabBar.Tab(id: "activity", title: "Activity", icon: "heart", selectedIcon: "heart.fill", badge: "7"),
                FloeTabBar.Tab(id: "profile", title: "Profile", icon: "person", selectedIcon: "person.fill")
            ],
            selectedTabId: .constant("activity")
        )
        .padding()
    }
}

#Preview("Tab Bar Controller") {
    FloeTabBarController(
        tabs: [
            FloeTabBar.Tab(id: "home", title: "Home", icon: "house", selectedIcon: "house.fill"),
            FloeTabBar.Tab(id: "search", title: "Search", icon: "magnifyingglass"),
            FloeTabBar.Tab(id: "favorites", title: "Favorites", icon: "heart", selectedIcon: "heart.fill", badge: "3"),
            FloeTabBar.Tab(id: "profile", title: "Profile", icon: "person", selectedIcon: "person.fill")
        ],
        initialSelection: "home"
    ) { tabId in
        ZStack {
            switch tabId {
            case "home":
                Color.blue.opacity(0.1)
                VStack {
                    Image(systemName: "house.fill")
                        .font(.system(size: 40))
                    Text("Home Content")
                        .font(.title)
                }
            case "search":
                Color.green.opacity(0.1)
                VStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                    Text("Search Content")
                        .font(.title)
                }
            case "favorites":
                Color.red.opacity(0.1)
                VStack {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 40))
                    Text("Favorites Content")
                        .font(.title)
                }
            case "profile":
                Color.purple.opacity(0.1)
                VStack {
                    Image(systemName: "person.fill")
                        .font(.system(size: 40))
                    Text("Profile Content")
                        .font(.title)
                }
            default:
                Color.gray.opacity(0.1)
                Text("Unknown Tab")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Convenience Home Tab Bar") {
    VStack(spacing: FloeSpacing.Size.lg.value) {
        Spacer()
        
        FloeTabBar.home(selectedTabId: .constant("search"))
            .padding()
    }
}

#Preview("Interactive Tab Selection") {
    struct InteractiveTabBarPreview: View {
        @State private var selectedTab = "home"
        
        var body: some View {
            VStack(spacing: FloeSpacing.Size.lg.value) {
                Text("Selected: \(selectedTab)")
                    .font(.headline)
                    .padding()
                
                Spacer()
                
                FloeTabBar(
                    tabs: [
                        FloeTabBar.Tab(id: "home", title: "Home", icon: "house", selectedIcon: "house.fill"),
                        FloeTabBar.Tab(id: "search", title: "Search", icon: "magnifyingglass"),
                        FloeTabBar.Tab(id: "notifications", title: "Alerts", icon: "bell", selectedIcon: "bell.fill", badge: "5"),
                        FloeTabBar.Tab(id: "profile", title: "Profile", icon: "person", selectedIcon: "person.fill")
                    ],
                    selectedTabId: $selectedTab,
                    onTabSelected: { tabId in
                        print("Tab selected: \(tabId)")
                    }
                )
                .padding()
            }
        }
    }
    
    return InteractiveTabBarPreview()
}

#Preview("Dark Mode") {
    VStack(spacing: FloeSpacing.Size.lg.value) {
        Spacer()
        
        FloeTabBar(
            tabs: [
                FloeTabBar.Tab(id: "home", title: "Home", icon: "house", selectedIcon: "house.fill"),
                FloeTabBar.Tab(id: "explore", title: "Explore", icon: "compass", selectedIcon: "compass.fill"),
                FloeTabBar.Tab(id: "notifications", title: "Alerts", icon: "bell", selectedIcon: "bell.fill", badge: "9"),
                FloeTabBar.Tab(id: "profile", title: "Profile", icon: "person", selectedIcon: "person.fill")
            ],
            selectedTabId: .constant("notifications")
        )
        .padding()
    }
    .preferredColorScheme(.dark)
}


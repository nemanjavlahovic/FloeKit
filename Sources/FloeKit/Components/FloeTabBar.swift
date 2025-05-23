import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public struct FloeTabBar: View {
    public struct Tab {
        public let id: String
        public let title: String
        public let icon: Image
        public let selectedIcon: Image?
        public let badge: String?
        
        public init(id: String, 
                   title: String, 
                   icon: Image, 
                   selectedIcon: Image? = nil, 
                   badge: String? = nil) {
            self.id = id
            self.title = title
            self.icon = icon
            self.selectedIcon = selectedIcon
            self.badge = badge
        }
    }
    
    public enum Style {
        case floating
        case attached
        case minimal
        
        var backgroundColor: Color {
            switch self {
            #if canImport(UIKit)
            case .floating: return Color(UIColor.systemBackground).opacity(0.95)
            case .attached: return Color(UIColor.systemBackground)
            #else
            case .floating: return Color.floePreviewBackground.opacity(0.95)
            case .attached: return Color.floePreviewBackground
            #endif
            case .minimal: return Color.clear
            }
        }
        
        var shadowStyle: FloeShadow.Style {
            switch self {
            case .floating: return .elevated
            case .attached: return .soft
            case .minimal: return .none
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .floating: return 25
            case .attached: return 0
            case .minimal: return 20
            }
        }
    }
    
    public enum IndicatorStyle {
        case pill
        case underline
        case background
        case none
    }
    
    private let tabs: [Tab]
    private let selectedTabId: String
    private let onTabSelected: (String) -> Void
    private let style: Style
    private let indicatorStyle: IndicatorStyle
    private let isScrollable: Bool
    private let centralAction: (() -> Void)?
    private let centralActionIcon: Image?
    
    @Environment(\.colorScheme) private var colorScheme
    @Namespace private var tabSelection
    
    public init(tabs: [Tab],
                selectedTabId: String,
                onTabSelected: @escaping (String) -> Void,
                style: Style = .floating,
                indicatorStyle: IndicatorStyle = .pill,
                isScrollable: Bool = false,
                centralAction: (() -> Void)? = nil,
                centralActionIcon: Image? = nil) {
        self.tabs = tabs
        self.selectedTabId = selectedTabId
        self.onTabSelected = onTabSelected
        self.style = style
        self.indicatorStyle = indicatorStyle
        self.isScrollable = isScrollable
        self.centralAction = centralAction
        self.centralActionIcon = centralActionIcon
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            if isScrollable {
                scrollableTabContent
            } else {
                regularTabContent
            }
        }
        .background(
            RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)
                .fill(style.backgroundColor)
                .floeShadow(style.shadowStyle)
        )
        .floePadding(.horizontal, style == .floating ? .md : .xs)
        .floePadding(.vertical, style == .floating ? .sm : .xs)
    }
    
    @ViewBuilder
    private var scrollableTabContent: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: FloeSpacing.Size.xs.value) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                    if centralAction != nil && index == tabs.count / 2 {
                        centralActionButton
                    }
                    
                    tabButton(for: tab)
                }
                
                if centralAction != nil && tabs.count % 2 == 0 {
                    centralActionButton
                }
            }
            .floePadding(.horizontal, .sm)
        }
    }
    
    @ViewBuilder
    private var regularTabContent: some View {
        ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
            if centralAction != nil && index == tabs.count / 2 {
                centralActionButton
            }
            
            tabButton(for: tab)
        }
        
        if centralAction != nil && tabs.count % 2 == 0 {
            centralActionButton
        }
    }
    
    @ViewBuilder
    private var centralActionButton: some View {
        Button(action: centralAction ?? {}) {
            (centralActionIcon ?? Image(systemName: "plus"))
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(Color.floePreviewPrimary)
                        .floeShadow(.medium)
                )
        }
        .buttonStyle(.plain)
        .scaleEffect(1.1)
        .floePadding(.horizontal, .sm)
    }
    
    @ViewBuilder
    private func tabButton(for tab: Tab) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                onTabSelected(tab.id)
            }
        }) {
            VStack(spacing: FloeSpacing.Size.xs.value) {
                ZStack {
                    // Tab icon
                    Group {
                        if selectedTabId == tab.id, let selectedIcon = tab.selectedIcon {
                            selectedIcon
                        } else {
                            tab.icon
                        }
                    }
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(selectedTabId == tab.id ? Color.floePreviewPrimary : Color.floePreviewNeutral)
                    .scaleEffect(selectedTabId == tab.id ? 1.1 : 1.0)
                    
                    // Badge
                    if let badge = tab.badge {
                        Text(badge)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(minWidth: 16, minHeight: 16)
                            .background(
                                Circle()
                                    .fill(Color.floePreviewError)
                            )
                            .offset(x: 12, y: -8)
                    }
                }
                
                // Tab title
                Text(tab.title)
                    .font(FloeFont.font(.caption))
                    .fontWeight(selectedTabId == tab.id ? .semibold : .medium)
                    .foregroundColor(selectedTabId == tab.id ? Color.floePreviewPrimary : Color.floePreviewNeutral)
                    .opacity(selectedTabId == tab.id ? 1.0 : 0.7)
            }
            .frame(maxWidth: .infinity)
            .floePadding(.vertical, .sm)
            .floePadding(.horizontal, .xs)
            .background(
                Group {
                    if selectedTabId == tab.id {
                        tabIndicator
                    }
                }
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTabId)
    }
    
    @ViewBuilder
    private var tabIndicator: some View {
        switch indicatorStyle {
        case .pill:
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.floePreviewPrimary.opacity(0.1))
                .matchedGeometryEffect(id: "tab_indicator", in: tabSelection)
                
        case .underline:
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.floePreviewPrimary)
                    .frame(height: 3)
                    .cornerRadius(1.5)
                    .matchedGeometryEffect(id: "tab_indicator", in: tabSelection)
            }
            
        case .background:
            Rectangle()
                .fill(Color.floePreviewPrimary.opacity(0.1))
                .matchedGeometryEffect(id: "tab_indicator", in: tabSelection)
                
        case .none:
            EmptyView()
        }
    }
}

// MARK: - Convenience Initializers

public extension FloeTabBar.Tab {
    static func systemIcon(id: String, title: String, systemName: String, selectedSystemName: String? = nil, badge: String? = nil) -> Self {
        FloeTabBar.Tab(
            id: id,
            title: title,
            icon: Image(systemName: systemName),
            selectedIcon: selectedSystemName.map { Image(systemName: $0) },
            badge: badge
        )
    }
}

// MARK: - Tab Bar Controller

public struct FloeTabBarController<Content: View>: View {
    private let tabs: [FloeTabBar.Tab]
    private let content: (String) -> Content
    private let style: FloeTabBar.Style
    private let indicatorStyle: FloeTabBar.IndicatorStyle
    private let isScrollable: Bool
    private let centralAction: (() -> Void)?
    private let centralActionIcon: Image?
    
    @State private var selectedTabId: String
    
    public init(tabs: [FloeTabBar.Tab],
                initialSelection: String? = nil,
                style: FloeTabBar.Style = .floating,
                indicatorStyle: FloeTabBar.IndicatorStyle = .pill,
                isScrollable: Bool = false,
                centralAction: (() -> Void)? = nil,
                centralActionIcon: Image? = nil,
                @ViewBuilder content: @escaping (String) -> Content) {
        self.tabs = tabs
        self.selectedTabId = initialSelection ?? tabs.first?.id ?? ""
        self.style = style
        self.indicatorStyle = indicatorStyle
        self.isScrollable = isScrollable
        self.centralAction = centralAction
        self.centralActionIcon = centralActionIcon
        self.content = content
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Content
            content(selectedTabId)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Tab Bar
            FloeTabBar(
                tabs: tabs,
                selectedTabId: selectedTabId,
                onTabSelected: { selectedTabId = $0 },
                style: style,
                indicatorStyle: indicatorStyle,
                isScrollable: isScrollable,
                centralAction: centralAction,
                centralActionIcon: centralActionIcon
            )
        }
    }
}

// MARK: - Previews

struct FloeTabBar_Previews: PreviewProvider {
    static let sampleTabs = [
        FloeTabBar.Tab.systemIcon(id: "home", title: "Home", systemName: "house", selectedSystemName: "house.fill"),
        FloeTabBar.Tab.systemIcon(id: "search", title: "Search", systemName: "magnifyingglass", selectedSystemName: "magnifyingglass", badge: "3"),
        FloeTabBar.Tab.systemIcon(id: "favorites", title: "Favorites", systemName: "heart", selectedSystemName: "heart.fill"),
        FloeTabBar.Tab.systemIcon(id: "profile", title: "Profile", systemName: "person", selectedSystemName: "person.fill")
    ]
    
    static var previews: some View {
        VStack {
            Spacer()
            FloeTabBar(
                tabs: sampleTabs,
                selectedTabId: "home",
                onTabSelected: { _ in },
                style: .floating,
                indicatorStyle: .pill
            )
        }
        .padding()
        .previewDisplayName("Floating Style")
        .previewLayout(.sizeThatFits)
        .frame(height: 120)
    }
} 
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Advanced Tab Configuration

/// A result builder for creating tab configurations declaratively
@resultBuilder
public struct TabBuilder {
    public static func buildBlock(_ tabs: FloeTabBar.Tab...) -> [FloeTabBar.Tab] {
        tabs
    }
    
    public static func buildArray(_ components: [[FloeTabBar.Tab]]) -> [FloeTabBar.Tab] {
        components.flatMap { $0 }
    }
    
    public static func buildOptional(_ component: [FloeTabBar.Tab]?) -> [FloeTabBar.Tab] {
        component ?? []
    }
    
    public static func buildEither(first component: [FloeTabBar.Tab]) -> [FloeTabBar.Tab] {
        component
    }
    
    public static func buildEither(second component: [FloeTabBar.Tab]) -> [FloeTabBar.Tab] {
        component
    }
}

// MARK: - Preference Keys for Advanced Layout

private struct TabBarHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct TabSelectionPreferenceKey: PreferenceKey {
    static let defaultValue: String? = nil
    static func reduce(value: inout String?, nextValue: () -> String?) {
        value = nextValue() ?? value
    }
}

// MARK: - Advanced Animation Configuration

public struct TabBarAnimationConfiguration: Hashable, Sendable {
    let selectionSpring: Animation
    let pressSpring: Animation
    let indicatorSpring: Animation
    let scaleEffect: (pressed: CGFloat, selected: CGFloat, normal: CGFloat)
    
    public static let `default` = TabBarAnimationConfiguration(
        selectionSpring: .spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0),
        pressSpring: .spring(response: 0.25, dampingFraction: 0.8, blendDuration: 0),
        indicatorSpring: .spring(response: 0.3, dampingFraction: 0.7),
        scaleEffect: (pressed: 0.85, selected: 1.08, normal: 1.0)
    )
    
    public static let subtle = TabBarAnimationConfiguration(
        selectionSpring: .spring(response: 0.5, dampingFraction: 0.8),
        pressSpring: .spring(response: 0.3, dampingFraction: 0.9),
        indicatorSpring: .spring(response: 0.4, dampingFraction: 0.8),
        scaleEffect: (pressed: 0.95, selected: 1.03, normal: 1.0)
    )
    
    public static let energetic = TabBarAnimationConfiguration(
        selectionSpring: .spring(response: 0.25, dampingFraction: 0.6),
        pressSpring: .spring(response: 0.15, dampingFraction: 0.7),
        indicatorSpring: .spring(response: 0.2, dampingFraction: 0.6),
        scaleEffect: (pressed: 0.8, selected: 1.15, normal: 1.0)
    )
    
    // MARK: - Hashable Conformance
    public func hash(into hasher: inout Hasher) {
        hasher.combine(scaleEffect.pressed)
        hasher.combine(scaleEffect.selected)
        hasher.combine(scaleEffect.normal)
    }
    
    public static func == (lhs: TabBarAnimationConfiguration, rhs: TabBarAnimationConfiguration) -> Bool {
        lhs.scaleEffect.pressed == rhs.scaleEffect.pressed &&
        lhs.scaleEffect.selected == rhs.scaleEffect.selected &&
        lhs.scaleEffect.normal == rhs.scaleEffect.normal
    }
}

// MARK: - Tab Bar Style Protocol

public protocol TabBarStyleProtocol {
    var backgroundColor: Color { get }
    var shadowStyle: FloeShadow.Style { get }
    var cornerRadius: CGFloat { get }
    var padding: (horizontal: FloeSpacing.PaddingStyle, vertical: FloeSpacing.PaddingStyle) { get }
}

// MARK: - Main Tab Bar Component

public struct FloeTabBar: View {
    
    // MARK: - Tab Model with Advanced Features
    
    public struct Tab: Identifiable, Hashable {
        public let id: String
        public let title: String
        public let icon: Image
        public let selectedIcon: Image?
        public let badge: Badge?
        public let isEnabled: Bool
        public let accessibilityLabel: String?
        
        public struct Badge: Hashable {
            public let text: String
            public let color: Color
            public let textColor: Color
            
            public init(text: String, color: Color = .floePreviewError, textColor: Color = .white) {
                self.text = text
                self.color = color
                self.textColor = textColor
            }
        }
        
        public init(
            id: String,
            title: String,
            icon: Image,
            selectedIcon: Image? = nil,
            badge: Badge? = nil,
            isEnabled: Bool = true,
            accessibilityLabel: String? = nil
        ) {
            self.id = id
            self.title = title
            self.icon = icon
            self.selectedIcon = selectedIcon
            self.badge = badge
            self.isEnabled = isEnabled
            self.accessibilityLabel = accessibilityLabel
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        public static func == (lhs: Tab, rhs: Tab) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    // MARK: - Style Definitions
    
    public enum Style: TabBarStyleProtocol, CaseIterable {
        case floating
        case attached
        case minimal
        case glassmorphism
        
        public var backgroundColor: Color {
            switch self {
            #if canImport(UIKit)
            case .floating: return Color(UIColor.systemBackground).opacity(0.95)
            case .attached: return Color(UIColor.systemBackground)
            case .glassmorphism: return Color(UIColor.systemBackground).opacity(0.7)
            #else
            case .floating: return Color.floePreviewBackground.opacity(0.95)
            case .attached: return Color.floePreviewBackground
            case .glassmorphism: return Color.floePreviewBackground.opacity(0.7)
            #endif
            case .minimal: return Color.clear
            }
        }
        
        public var shadowStyle: FloeShadow.Style {
            switch self {
            case .floating: return .elevated
            case .attached: return .soft
            case .minimal: return .none
            case .glassmorphism: return .medium
            }
        }
        
        public var cornerRadius: CGFloat {
            switch self {
            case .floating: return 25
            case .attached: return 0
            case .minimal: return 20
            case .glassmorphism: return 30
            }
        }
        
        public var padding: (horizontal: FloeSpacing.PaddingStyle, vertical: FloeSpacing.PaddingStyle) {
            switch self {
            case .floating, .glassmorphism: return (.comfortable, .cozy)
            case .attached, .minimal: return (.compact, .compact)
            }
        }
    }
    
    public enum IndicatorStyle: CaseIterable {
        case pill
        case underline
        case background
        case floating
        case none
    }
    
    // MARK: - Properties
    
    private let tabs: [Tab]
    private let selectedTabId: String
    private let onTabSelected: (String) -> Void
    private let style: Style
    private let indicatorStyle: IndicatorStyle
    private let isScrollable: Bool
    private let centralAction: CentralAction?
    private let animationConfig: TabBarAnimationConfiguration
    private let hapticFeedback: Bool
    
    public struct CentralAction {
        let action: () -> Void
        let icon: Image
        let backgroundColor: Color
        let foregroundColor: Color
        
        public init(
            action: @escaping () -> Void,
            icon: Image = Image(systemName: "plus"),
            backgroundColor: Color = .floePreviewPrimary,
            foregroundColor: Color = .white
        ) {
            self.action = action
            self.icon = icon
            self.backgroundColor = backgroundColor
            self.foregroundColor = foregroundColor
        }
    }
    
    // MARK: - State
    
    @Environment(\.colorScheme) private var colorScheme
    @Namespace private var tabSelection
    @State private var pressedTabId: String?
    @State private var tabBarHeight: CGFloat = 0
    @GestureState private var dragOffset: CGSize = .zero
    
    // MARK: - Initializers
    
    public init(
        tabs: [Tab],
        selectedTabId: String,
        onTabSelected: @escaping (String) -> Void,
        style: Style = .floating,
        indicatorStyle: IndicatorStyle = .pill,
        isScrollable: Bool = false,
        centralAction: CentralAction? = nil,
        animationConfig: TabBarAnimationConfiguration = .default,
        hapticFeedback: Bool = true
    ) {
        self.tabs = tabs
        self.selectedTabId = selectedTabId
        self.onTabSelected = onTabSelected
        self.style = style
        self.indicatorStyle = indicatorStyle
        self.isScrollable = isScrollable
        self.centralAction = centralAction
        self.animationConfig = animationConfig
        self.hapticFeedback = hapticFeedback
    }
    
    // Result builder initializer
    public init(
        selectedTabId: String,
        onTabSelected: @escaping (String) -> Void,
        style: Style = .floating,
        indicatorStyle: IndicatorStyle = .pill,
        isScrollable: Bool = false,
        centralAction: CentralAction? = nil,
        animationConfig: TabBarAnimationConfiguration = .default,
        hapticFeedback: Bool = true,
        @TabBuilder tabs: () -> [Tab]
    ) {
        self.init(
            tabs: tabs(),
            selectedTabId: selectedTabId,
            onTabSelected: onTabSelected,
            style: style,
            indicatorStyle: indicatorStyle,
            isScrollable: isScrollable,
            centralAction: centralAction,
            animationConfig: animationConfig,
            hapticFeedback: hapticFeedback
        )
    }
    
    // MARK: - Body
    
    public var body: some View {
        tabContent
            .floePadding(style.padding.horizontal)
            .floePadding(style.padding.vertical)
            .background(backgroundView)
            .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous))
            .floeShadow(style.shadowStyle)
            .overlay(glassmorphismOverlay)
            .background(
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: TabBarHeightPreferenceKey.self,
                        value: geometry.size.height
                    )
                }
            )
            .onPreferenceChange(TabBarHeightPreferenceKey.self) { height in
                tabBarHeight = height
            }
    }
    
    // MARK: - Content Views
    
    @ViewBuilder
    private var tabContent: some View {
        if isScrollable {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: FloeSpacing.Size.xs.value) {
                        tabItems
                    }
                    .floePadding(.horizontal, .sm)
                }
                .onChange(of: selectedTabId) { newValue in
                    withAnimation(animationConfig.indicatorSpring) {
                        proxy.scrollTo(newValue, anchor: .center)
                    }
                }
            }
        } else {
            HStack(spacing: 0) {
                tabItems
            }
        }
    }
    
    @ViewBuilder
    private var tabItems: some View {
        ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
            if let centralAction = centralAction, index == tabs.count / 2 {
                centralActionButton(centralAction)
            }
            
            TabButtonView(
                tab: tab,
                isSelected: selectedTabId == tab.id,
                isPressed: pressedTabId == tab.id,
                indicatorStyle: indicatorStyle,
                animationConfig: animationConfig,
                namespace: tabSelection,
                onTap: { handleTabSelection(tab) },
                onPressChanged: { isPressed in
                    withAnimation(animationConfig.pressSpring) {
                        pressedTabId = isPressed ? tab.id : nil
                    }
                }
            )
            .id(tab.id)
        }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)
            .fill(style.backgroundColor)
    }
    
    @ViewBuilder
    private var glassmorphismOverlay: some View {
        if case .glassmorphism = style {
            RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.2), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
    }
    
    @ViewBuilder
    private func centralActionButton(_ centralAction: CentralAction) -> some View {
        Button(action: centralAction.action) {
            centralAction.icon
                .font(.title2)
                .foregroundColor(centralAction.foregroundColor)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(centralAction.backgroundColor)
                        .floeShadow(.medium)
                )
        }
        .buttonStyle(ScaleButtonStyle())
        .floePadding(.horizontal, .sm)
        .accessibilityLabel("Central Action")
    }
    
    // MARK: - Helper Methods
    
    private func handleTabSelection(_ tab: Tab) {
        guard tab.isEnabled else { return }
        
        if hapticFeedback {
            triggerHapticFeedback()
        }
        
        withAnimation(animationConfig.selectionSpring) {
            onTabSelected(tab.id)
        }
    }
    
    private func triggerHapticFeedback() {
        #if canImport(UIKit) && !os(macOS)
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        #endif
    }
}

// MARK: - Tab Button Component

private struct TabButtonView: View {
    let tab: FloeTabBar.Tab
    let isSelected: Bool
    let isPressed: Bool
    let indicatorStyle: FloeTabBar.IndicatorStyle
    let animationConfig: TabBarAnimationConfiguration
    let namespace: Namespace.ID
    let onTap: () -> Void
    let onPressChanged: (Bool) -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: FloeSpacing.Size.xs.value) {
                iconWithBadge
                titleText
            }
            .frame(maxWidth: .infinity)
            .floePadding(.vertical, .sm)
            .floePadding(.horizontal, .sm)
            .background(indicatorBackground)
            .scaleEffect(scaleValue)
            .opacity(tab.isEnabled ? 1.0 : 0.5)
        }
        .buttonStyle(.plain)
        .disabled(!tab.isEnabled)
        .animation(animationConfig.selectionSpring, value: isSelected)
        .animation(animationConfig.pressSpring, value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in onPressChanged(true) }
                .onEnded { _ in onPressChanged(false) }
        )
        .accessibilityLabel(tab.accessibilityLabel ?? tab.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
    
    @ViewBuilder
    private var iconWithBadge: some View {
        ZStack {
            iconView
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(isSelected ? Color.floePreviewPrimary : Color.floePreviewNeutral)
            
            if let badge = tab.badge {
                BadgeView(badge: badge)
                    .offset(x: 12, y: -8)
            }
        }
    }
    
    @ViewBuilder
    private var iconView: some View {
        Group {
            if isSelected, let selectedIcon = tab.selectedIcon {
                selectedIcon
            } else {
                tab.icon
            }
        }
    }
    
    @ViewBuilder
    private var titleText: some View {
        Text(tab.title)
            .font(FloeFont.font(.caption))
            .fontWeight(isSelected ? .semibold : .medium)
            .foregroundColor(isSelected ? Color.floePreviewPrimary : Color.floePreviewNeutral)
            .opacity(isSelected ? 1.0 : 0.7)
            .lineLimit(1)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.8)
    }
    
    @ViewBuilder
    private var indicatorBackground: some View {
        Group {
            if isSelected {
                TabIndicatorView(style: indicatorStyle, namespace: namespace)
            }
        }
    }
    
    private var scaleValue: CGFloat {
        if isPressed {
            return animationConfig.scaleEffect.pressed
        } else if isSelected {
            return animationConfig.scaleEffect.selected
        } else {
            return animationConfig.scaleEffect.normal
        }
    }
}

// MARK: - Badge Component

private struct BadgeView: View {
    let badge: FloeTabBar.Tab.Badge
    
    private var isLongText: Bool {
        badge.text.count > 2
    }
    
    var body: some View {
        Text(badge.text)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(badge.textColor)
            .padding(.horizontal, isLongText ? 6 : 4)
            .padding(.vertical, 2)
            .frame(minWidth: 16, minHeight: 16)
            .background(
                Group {
                    if isLongText {
                        Capsule()
                            .fill(badge.color)
                    } else {
                        Circle()
                            .fill(badge.color)
                    }
                }
            )
            .scaleEffect(0.9)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: badge.text)
    }
}

// MARK: - Tab Indicator Component

private struct TabIndicatorView: View {
    let style: FloeTabBar.IndicatorStyle
    let namespace: Namespace.ID
    
    var body: some View {
        switch style {
        case .pill:
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.floePreviewPrimary.opacity(0.12))
                .matchedGeometryEffect(id: "tab_indicator", in: namespace)
                .padding(.horizontal, -4)
                .padding(.vertical, -2)
                
        case .underline:
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.floePreviewPrimary)
                    .frame(height: 3)
                    .cornerRadius(1.5)
                    .matchedGeometryEffect(id: "tab_indicator", in: namespace)
                    .padding(.horizontal, 8)
            }
            
        case .background:
            Rectangle()
                .fill(Color.floePreviewPrimary.opacity(0.08))
                .matchedGeometryEffect(id: "tab_indicator", in: namespace)
                .padding(.horizontal, -6)
                .padding(.vertical, -4)
                
        case .floating:
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.floePreviewPrimary.opacity(0.18))
                .floeShadow(.subtle)
                .matchedGeometryEffect(id: "tab_indicator", in: namespace)
                .padding(.horizontal, -6)
                .padding(.vertical, -3)
                .scaleEffect(1.02)
                
        case .none:
            EmptyView()
        }
    }
}

// MARK: - Custom Button Style

private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Convenience Initializers and Extensions

public extension FloeTabBar.Tab {
    static func systemIcon(
        id: String,
        title: String,
        systemName: String,
        selectedSystemName: String? = nil,
        badge: Badge? = nil,
        isEnabled: Bool = true,
        accessibilityLabel: String? = nil
    ) -> Self {
        FloeTabBar.Tab(
            id: id,
            title: title,
            icon: Image(systemName: systemName),
            selectedIcon: selectedSystemName.map { Image(systemName: $0) },
            badge: badge,
            isEnabled: isEnabled,
            accessibilityLabel: accessibilityLabel
        )
    }
    
    static func customIcon(
        id: String,
        title: String,
        iconName: String,
        selectedIconName: String? = nil,
        badge: Badge? = nil,
        isEnabled: Bool = true,
        accessibilityLabel: String? = nil
    ) -> Self {
        FloeTabBar.Tab(
            id: id,
            title: title,
            icon: Image(iconName),
            selectedIcon: selectedIconName.map { Image($0) },
            badge: badge,
            isEnabled: isEnabled,
            accessibilityLabel: accessibilityLabel
        )
    }
}

// MARK: - Tab Bar Controller with Generic Content

public struct FloeTabBarController<Content: View>: View {
    private let tabs: [FloeTabBar.Tab]
    private let content: (String) -> Content
    private let style: FloeTabBar.Style
    private let indicatorStyle: FloeTabBar.IndicatorStyle
    private let isScrollable: Bool
    private let centralAction: FloeTabBar.CentralAction?
    private let animationConfig: TabBarAnimationConfiguration
    
    @State private var selectedTabId: String
    @State private var previousTabId: String = ""
    
    public init(
        tabs: [FloeTabBar.Tab],
        initialSelection: String? = nil,
        style: FloeTabBar.Style = .floating,
        indicatorStyle: FloeTabBar.IndicatorStyle = .pill,
        isScrollable: Bool = false,
        centralAction: FloeTabBar.CentralAction? = nil,
        animationConfig: TabBarAnimationConfiguration = .default,
        @ViewBuilder content: @escaping (String) -> Content
    ) {
        self.tabs = tabs
        self.selectedTabId = initialSelection ?? tabs.first?.id ?? ""
        self.style = style
        self.indicatorStyle = indicatorStyle
        self.isScrollable = isScrollable
        self.centralAction = centralAction
        self.animationConfig = animationConfig
        self.content = content
    }
    
    // Result builder initializer
    public init(
        initialSelection: String? = nil,
        style: FloeTabBar.Style = .floating,
        indicatorStyle: FloeTabBar.IndicatorStyle = .pill,
        isScrollable: Bool = false,
        centralAction: FloeTabBar.CentralAction? = nil,
        animationConfig: TabBarAnimationConfiguration = .default,
        @TabBuilder tabs: () -> [FloeTabBar.Tab],
        @ViewBuilder content: @escaping (String) -> Content
    ) {
        self.init(
            tabs: tabs(),
            initialSelection: initialSelection,
            style: style,
            indicatorStyle: indicatorStyle,
            isScrollable: isScrollable,
            centralAction: centralAction,
            animationConfig: animationConfig,
            content: content
        )
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Content with transition
            content(selectedTabId)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .id(selectedTabId)
            
            // Tab Bar
            FloeTabBar(
                tabs: tabs,
                selectedTabId: selectedTabId,
                onTabSelected: handleTabSelection,
                style: style,
                indicatorStyle: indicatorStyle,
                isScrollable: isScrollable,
                centralAction: centralAction,
                animationConfig: animationConfig
            )
        }
        .onAppear {
            previousTabId = selectedTabId
        }
    }
    
    private func handleTabSelection(_ newTabId: String) {
        guard newTabId != selectedTabId else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            previousTabId = selectedTabId
            selectedTabId = newTabId
        }
    }
}

// MARK: - Previews

struct FloeTabBar_Previews: PreviewProvider {
    static let sampleTabs = [
        FloeTabBar.Tab.systemIcon(id: "home", title: "Home", systemName: "house", selectedSystemName: "house.fill"),
        FloeTabBar.Tab.systemIcon(id: "search", title: "Search", systemName: "magnifyingglass", selectedSystemName: "magnifyingglass", badge: .init(text: "3")),
        FloeTabBar.Tab.systemIcon(id: "favorites", title: "Favorites", systemName: "heart", selectedSystemName: "heart.fill"),
        FloeTabBar.Tab.systemIcon(id: "profile", title: "Profile", systemName: "person", selectedSystemName: "person.fill")
    ]
    
    static let extendedTabs = [
        FloeTabBar.Tab.systemIcon(id: "home", title: "Home", systemName: "house", selectedSystemName: "house.fill"),
        FloeTabBar.Tab.systemIcon(id: "search", title: "Search", systemName: "magnifyingglass", badge: .init(text: "12")),
        FloeTabBar.Tab.systemIcon(id: "notifications", title: "Alerts", systemName: "bell", selectedSystemName: "bell.fill", badge: .init(text: "99+", color: .orange)),
        FloeTabBar.Tab.systemIcon(id: "messages", title: "Messages", systemName: "message", selectedSystemName: "message.fill", badge: .init(text: "5", color: .blue)),
        FloeTabBar.Tab.systemIcon(id: "favorites", title: "Favorites", systemName: "heart", selectedSystemName: "heart.fill"),
        FloeTabBar.Tab.systemIcon(id: "profile", title: "Profile", systemName: "person", selectedSystemName: "person.fill", isEnabled: false)
    ]
    
    static var previews: some View {
        Group {
            // Result Builder Demo
            ResultBuilderPreview()
                .previewDisplayName("Result Builder")
            
            // Advanced Styles
            AdvancedStylesPreview()
                .previewDisplayName("Advanced Styles")
            
            // Animation Configurations
            AnimationConfigPreview()
                .previewDisplayName("Animation Configs")
            
            // Enhanced Badge System
            EnhancedBadgePreview()
                .previewDisplayName("Enhanced Badges")
            
            // Accessibility Features
            AccessibilityPreview()
                .previewDisplayName("Accessibility")
            
            // Interactive Features
            InteractiveFeaturesPreview()
                .previewDisplayName("Interactive Features")
            
            // Scrollable Tab Bar
            ScrollableTabBarPreview()
                .previewDisplayName("Scrollable Tab Bar")
            
            // Central Action Button
            CentralActionPreview()
                .previewDisplayName("Central Action")
            
            // Tab Bar Controller
            TabBarControllerPreview()
                .previewDisplayName("Full Controller")
            
            // Dark Mode Comparison
            DarkModeComparisonPreview()
                .previewDisplayName("Dark Mode")
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Preview Components

private struct ResultBuilderPreview: View {
    @State private var selectedTabId = "home"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Result Builder Syntax")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            Text("Declarative tab creation with @TabBuilder")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Using result builder syntax
            FloeTabBar(
                selectedTabId: selectedTabId,
                onTabSelected: { selectedTabId = $0 },
                style: .floating,
                indicatorStyle: .pill
            ) {
                FloeTabBar.Tab.systemIcon(id: "home", title: "Home", systemName: "house", selectedSystemName: "house.fill")
                FloeTabBar.Tab.systemIcon(id: "search", title: "Search", systemName: "magnifyingglass")
                FloeTabBar.Tab.systemIcon(id: "favorites", title: "Favorites", systemName: "heart", selectedSystemName: "heart.fill")
                FloeTabBar.Tab.systemIcon(id: "profile", title: "Profile", systemName: "person", selectedSystemName: "person.fill")
            }
            
            Spacer()
        }
        .padding()
        .background(Color.systemGroupedBackground)
    }
}

private struct AdvancedStylesPreview: View {
    @State private var selectedTabId = "home"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Advanced Styles")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            VStack(spacing: 16) {
                // Glassmorphism Style
                VStack(alignment: .leading, spacing: 8) {
                    Text("Glassmorphism Style")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    FloeTabBar(
                        tabs: FloeTabBar_Previews.sampleTabs,
                        selectedTabId: selectedTabId,
                        onTabSelected: { selectedTabId = $0 },
                        style: .glassmorphism,
                        indicatorStyle: .pill
                    )
                }
                
                // Floating with floating indicator
                VStack(alignment: .leading, spacing: 8) {
                    Text("Floating Indicator Style")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    FloeTabBar(
                        tabs: FloeTabBar_Previews.sampleTabs,
                        selectedTabId: selectedTabId,
                        onTabSelected: { selectedTabId = $0 },
                        style: .floating,
                        indicatorStyle: .floating
                    )
                }
                
                // Standard floating with pill
                VStack(alignment: .leading, spacing: 8) {
                    Text("Standard Floating")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    FloeTabBar(
                        tabs: FloeTabBar_Previews.sampleTabs,
                        selectedTabId: selectedTabId,
                        onTabSelected: { selectedTabId = $0 },
                        style: .floating,
                        indicatorStyle: .pill
                    )
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

private struct AnimationConfigPreview: View {
    @State private var selectedTabId = "search"
    @State private var selectedConfigType: AnimationConfigType = .default
    
    enum AnimationConfigType: String, CaseIterable {
        case `default` = "Default"
        case subtle = "Subtle"
        case energetic = "Energetic"
        
        var config: TabBarAnimationConfiguration {
            switch self {
            case .default: return .default
            case .subtle: return .subtle
            case .energetic: return .energetic
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Animation Configurations")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            Picker("Animation Style", selection: $selectedConfigType) {
                ForEach(AnimationConfigType.allCases, id: \.self) { configType in
                    Text(configType.rawValue).tag(configType)
                }
            }
            .pickerStyle(.segmented)
            
            FloeTabBar(
                tabs: FloeTabBar_Previews.sampleTabs,
                selectedTabId: selectedTabId,
                onTabSelected: { selectedTabId = $0 },
                style: .floating,
                indicatorStyle: .pill,
                animationConfig: selectedConfigType.config
            )
            
            Spacer()
        }
        .padding()
        .background(Color.systemGroupedBackground)
    }
}

private struct EnhancedBadgePreview: View {
    @State private var selectedTabId = "home"
    
    private let badgeTabs = [
        FloeTabBar.Tab.systemIcon(
            id: "home", 
            title: "Home", 
            systemName: "house", 
            selectedSystemName: "house.fill"
        ),
        FloeTabBar.Tab.systemIcon(
            id: "messages", 
            title: "Messages", 
            systemName: "message", 
            selectedSystemName: "message.fill",
            badge: .init(text: "5", color: .blue)
        ),
        FloeTabBar.Tab.systemIcon(
            id: "notifications", 
            title: "Alerts", 
            systemName: "bell", 
            selectedSystemName: "bell.fill",
            badge: .init(text: "99+", color: .orange)
        ),
        FloeTabBar.Tab.systemIcon(
            id: "urgent", 
            title: "Urgent", 
            systemName: "exclamationmark.triangle", 
            selectedSystemName: "exclamationmark.triangle.fill",
            badge: .init(text: "!", color: .red, textColor: .white)
        )
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Enhanced Badge System")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            Text("Custom colors and styling")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            FloeTabBar(
                tabs: badgeTabs,
                selectedTabId: selectedTabId,
                onTabSelected: { selectedTabId = $0 },
                style: .floating,
                indicatorStyle: .pill
            )
            
            Spacer()
        }
        .padding()
        .background(Color.systemGroupedBackground)
    }
}

private struct AccessibilityPreview: View {
    @State private var selectedTabId = "home"
    
    private let accessibilityTabs = [
        FloeTabBar.Tab.systemIcon(
            id: "home", 
            title: "Home", 
            systemName: "house", 
            selectedSystemName: "house.fill",
            accessibilityLabel: "Home screen with dashboard"
        ),
        FloeTabBar.Tab.systemIcon(
            id: "search", 
            title: "Search", 
            systemName: "magnifyingglass",
            accessibilityLabel: "Search for content"
        ),
        FloeTabBar.Tab.systemIcon(
            id: "disabled", 
            title: "Disabled", 
            systemName: "lock", 
            selectedSystemName: "lock.fill",
            isEnabled: false,
            accessibilityLabel: "Feature currently unavailable"
        ),
        FloeTabBar.Tab.systemIcon(
            id: "profile", 
            title: "Profile", 
            systemName: "person", 
            selectedSystemName: "person.fill",
            accessibilityLabel: "User profile and settings"
        )
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Accessibility Features")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            Text("Custom labels, disabled states, and VoiceOver support")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            FloeTabBar(
                tabs: accessibilityTabs,
                selectedTabId: selectedTabId,
                onTabSelected: { selectedTabId = $0 },
                style: .floating,
                indicatorStyle: .pill
            )
            
            Spacer()
        }
        .padding()
        .background(Color.systemGroupedBackground)
    }
}

private struct InteractiveFeaturesPreview: View {
    @State private var selectedTabId = "favorites"
    @State private var interactionCount = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Interactive Features")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            VStack(spacing: 12) {
                Text("Selected: \(selectedTabId)")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Interactions: \(interactionCount)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Advanced animations, haptic feedback, and gesture recognition")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(Color.secondarySystemGroupedBackground)
            .cornerRadius(12)
            
            FloeTabBar(
                tabs: FloeTabBar_Previews.sampleTabs,
                selectedTabId: selectedTabId,
                onTabSelected: { 
                    selectedTabId = $0
                    interactionCount += 1
                },
                style: .floating,
                indicatorStyle: .pill,
                animationConfig: .energetic
            )
            
            Spacer()
        }
        .padding()
        .background(Color.systemGroupedBackground)
    }
}

private struct ScrollableTabBarPreview: View {
    @State private var selectedTabId = "home"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Scrollable Tab Bar")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            Text("Auto-scroll to selection with enhanced badges")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            FloeTabBar(
                tabs: FloeTabBar_Previews.extendedTabs,
                selectedTabId: selectedTabId,
                onTabSelected: { selectedTabId = $0 },
                style: .floating,
                indicatorStyle: .pill,
                isScrollable: true
            )
            
            Spacer()
        }
        .padding()
        .background(Color.systemGroupedBackground)
    }
}

private struct CentralActionPreview: View {
    @State private var selectedTabId = "home"
    @State private var centralActionTapped = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Central Action Button")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            if centralActionTapped {
                Text("Central action tapped! ✨")
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
            }
            
            FloeTabBar(
                tabs: FloeTabBar_Previews.sampleTabs,
                selectedTabId: selectedTabId,
                onTabSelected: { selectedTabId = $0 },
                style: .floating,
                indicatorStyle: .pill,
                centralAction: .init(
                    action: {
                        centralActionTapped = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            centralActionTapped = false
                        }
                    },
                    icon: Image(systemName: "plus.circle.fill"),
                    backgroundColor: .purple,
                    foregroundColor: .white
                )
            )
            
            Spacer()
        }
        .padding()
        .background(Color.systemGroupedBackground)
    }
}

private struct DarkModeComparisonPreview: View {
    @State private var selectedTabId = "profile"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Dark Mode Appearance")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.top)
            
            VStack(spacing: 16) {
                FloeTabBar(
                    tabs: FloeTabBar_Previews.sampleTabs,
                    selectedTabId: selectedTabId,
                    onTabSelected: { selectedTabId = $0 },
                    style: .glassmorphism,
                    indicatorStyle: .floating
                )
                
                FloeTabBar(
                    tabs: FloeTabBar_Previews.sampleTabs,
                    selectedTabId: selectedTabId,
                    onTabSelected: { selectedTabId = $0 },
                    style: .floating,
                    indicatorStyle: .pill
                )
            }
            
            Spacer()
        }
        .padding()
        .background(Color.systemGroupedBackground)
    }
}

private struct TabBarControllerPreview: View {
    var body: some View {
        // Using result builder syntax for the controller
        FloeTabBarController(
            initialSelection: "home",
            style: .floating,
            indicatorStyle: .pill,
            animationConfig: .default
        ) {
            FloeTabBar.Tab.systemIcon(id: "home", title: "Home", systemName: "house", selectedSystemName: "house.fill")
            FloeTabBar.Tab.systemIcon(id: "search", title: "Search", systemName: "magnifyingglass", badge: .init(text: "3"))
            FloeTabBar.Tab.systemIcon(id: "favorites", title: "Favorites", systemName: "heart", selectedSystemName: "heart.fill")
            FloeTabBar.Tab.systemIcon(id: "profile", title: "Profile", systemName: "person", selectedSystemName: "person.fill")
        } content: { selectedTab in
            VStack(spacing: 20) {
                Image(systemName: getContentIcon(for: selectedTab))
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text(getContentTitle(for: selectedTab))
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(getContentDescription(for: selectedTab))
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.systemGroupedBackground)
        }
    }
    
    private func getContentIcon(for tabId: String) -> String {
        switch tabId {
        case "home": return "house.fill"
        case "search": return "magnifyingglass"
        case "favorites": return "heart.fill"
        case "profile": return "person.fill"
        default: return "questionmark"
        }
    }
    
    private func getContentTitle(for tabId: String) -> String {
        switch tabId {
        case "home": return "Welcome Home"
        case "search": return "Discover"
        case "favorites": return "Your Favorites"
        case "profile": return "Your Profile"
        default: return "Unknown"
        }
    }
    
    private func getContentDescription(for tabId: String) -> String {
        switch tabId {
        case "home": return "Your personalized dashboard with recent activity and recommendations."
        case "search": return "Find exactly what you're looking for with our powerful search."
        case "favorites": return "All your saved items and bookmarks in one place."
        case "profile": return "Manage your account settings and personal information."
        default: return "Content not available"
        }
    }
}

// MARK: - Helper Extensions

private extension Color {
    static var systemGroupedBackground: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemGroupedBackground)
        #else
        return Color.gray.opacity(0.1)
        #endif
    }
    
    static var secondarySystemGroupedBackground: Color {
        #if canImport(UIKit)
        return Color(UIColor.secondarySystemGroupedBackground)
        #else
        return Color.gray.opacity(0.05)
        #endif
    }
} 
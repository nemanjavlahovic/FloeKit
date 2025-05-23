import SwiftUI

public struct FloeSectionHeader: View {
    public enum Style {
        case plain
        case background
        case divider
        case card
    }
    
    public enum Size {
        case small, medium, large
        
        var titleFont: Font {
            switch self {
            case .small: return FloeFont.font(.subheadline)
            case .medium: return FloeFont.font(.headline)
            case .large: return FloeFont.font(.title)
            }
        }
        
        var subtitleFont: Font {
            switch self {
            case .small: return FloeFont.font(.caption)
            case .medium: return FloeFont.font(.body)
            case .large: return FloeFont.font(.subheadline)
            }
        }
        
        var padding: EdgeInsets {
            switch self {
            case .small: return FloeSpacing.PaddingStyle.cozy.edgeInsets
            case .medium: return FloeSpacing.PaddingStyle.comfortable.edgeInsets
            case .large: return FloeSpacing.PaddingStyle.spacious.edgeInsets
            }
        }
        
        var actionIconSize: CGFloat {
            switch self {
            case .small: return 16
            case .medium: return 20
            case .large: return 24
            }
        }
    }
    
    private let title: String
    private let subtitle: String?
    private let style: Style
    private let size: Size
    private let backgroundColor: Color
    private let titleColor: Color
    private let subtitleColor: Color
    private let actionTitle: String?
    private let actionIcon: Image?
    private let isCollapsible: Bool
    private let cornerRadius: CGFloat
    private let onAction: (() -> Void)?
    private let onToggle: ((Bool) -> Void)?
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var isExpanded: Bool = true
    
    // MARK: - Initializers
    
    /// Initialize with basic title and subtitle
    public init(
        _ title: String,
        subtitle: String? = nil,
        style: Style = .plain,
        size: Size = .medium,
        backgroundColor: Color = Color.floePreviewSurface,
        titleColor: Color = Color.primary,
        subtitleColor: Color = Color.secondary,
        cornerRadius: CGFloat = 12,
        isCollapsible: Bool = false,
        isExpanded: Bool = true,
        onToggle: ((Bool) -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.style = style
        self.size = size
        self.backgroundColor = backgroundColor
        self.titleColor = titleColor
        self.subtitleColor = subtitleColor
        self.actionTitle = nil
        self.actionIcon = nil
        self.isCollapsible = isCollapsible
        self.cornerRadius = cornerRadius
        self.onAction = nil
        self.onToggle = onToggle
        self._isExpanded = State(initialValue: isExpanded)
    }
    
    /// Initialize with action button
    public init(
        _ title: String,
        subtitle: String? = nil,
        actionTitle: String,
        style: Style = .plain,
        size: Size = .medium,
        backgroundColor: Color = Color.floePreviewSurface,
        titleColor: Color = Color.primary,
        subtitleColor: Color = Color.secondary,
        cornerRadius: CGFloat = 12,
        isCollapsible: Bool = false,
        isExpanded: Bool = true,
        onAction: (() -> Void)? = nil,
        onToggle: ((Bool) -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.style = style
        self.size = size
        self.backgroundColor = backgroundColor
        self.titleColor = titleColor
        self.subtitleColor = subtitleColor
        self.actionTitle = actionTitle
        self.actionIcon = nil
        self.isCollapsible = isCollapsible
        self.cornerRadius = cornerRadius
        self.onAction = onAction
        self.onToggle = onToggle
        self._isExpanded = State(initialValue: isExpanded)
    }
    
    /// Initialize with action icon
    public init(
        _ title: String,
        subtitle: String? = nil,
        actionIcon: Image,
        style: Style = .plain,
        size: Size = .medium,
        backgroundColor: Color = Color.floePreviewSurface,
        titleColor: Color = Color.primary,
        subtitleColor: Color = Color.secondary,
        cornerRadius: CGFloat = 12,
        isCollapsible: Bool = false,
        isExpanded: Bool = true,
        onAction: (() -> Void)? = nil,
        onToggle: ((Bool) -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.style = style
        self.size = size
        self.backgroundColor = backgroundColor
        self.titleColor = titleColor
        self.subtitleColor = subtitleColor
        self.actionTitle = nil
        self.actionIcon = actionIcon
        self.isCollapsible = isCollapsible
        self.cornerRadius = cornerRadius
        self.onAction = onAction
        self.onToggle = onToggle
        self._isExpanded = State(initialValue: isExpanded)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            headerContent
            
            if style == .divider {
                Divider()
                    .padding(.top, FloeSpacing.Size.sm.value)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isExpanded)
    }
    
    // MARK: - Header Content
    
    @ViewBuilder
    private var headerContent: some View {
        switch style {
        case .plain:
            plainHeader
        case .background:
            backgroundHeader
        case .divider:
            plainHeader
        case .card:
            cardHeader
        }
    }
    
    private var plainHeader: some View {
        HStack(alignment: .center, spacing: FloeSpacing.Size.md.value) {
            titleSubtitleStack
            
            Spacer()
            
            trailingContent
        }
        .padding(size.padding)
    }
    
    private var backgroundHeader: some View {
        HStack(alignment: .center, spacing: FloeSpacing.Size.md.value) {
            titleSubtitleStack
            
            Spacer()
            
            trailingContent
        }
        .padding(size.padding)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(backgroundColor)
        )
    }
    
    private var cardHeader: some View {
        HStack(alignment: .center, spacing: FloeSpacing.Size.md.value) {
            titleSubtitleStack
            
            Spacer()
            
            trailingContent
        }
        .padding(size.padding)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(backgroundColor)
                .floeShadow(.soft)
        )
    }
    
    @ViewBuilder
    private var titleSubtitleStack: some View {
        VStack(alignment: .leading, spacing: FloeSpacing.Size.xs.value) {
            Text(title)
                .font(size.titleFont)
                .foregroundColor(titleColor)
                .multilineTextAlignment(.leading)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(size.subtitleFont)
                    .foregroundColor(subtitleColor)
                    .multilineTextAlignment(.leading)
            }
        }
    }
    
    @ViewBuilder
    private var trailingContent: some View {
        HStack(spacing: FloeSpacing.Size.sm.value) {
            // Action button/icon
            if let actionTitle = actionTitle {
                actionButton(title: actionTitle)
            } else if let actionIcon = actionIcon {
                actionButton(icon: actionIcon)
            }
            
            // Collapsible chevron
            if isCollapsible {
                collapsibleChevron
            }
        }
    }
    
    private func actionButton(title: String) -> some View {
        Button(action: { onAction?() }) {
            Text(title)
                .font(size.subtitleFont)
                .foregroundColor(.accentColor)
        }
        .buttonStyle(.plain)
    }
    
    private func actionButton(icon: Image) -> some View {
        Button(action: { onAction?() }) {
            icon
                .resizable()
                .scaledToFit()
                .frame(width: size.actionIconSize, height: size.actionIconSize)
                .foregroundColor(.accentColor)
        }
        .buttonStyle(.plain)
    }
    
    private var collapsibleChevron: some View {
        Button(action: toggleExpansion) {
            Image(systemName: "chevron.down")
                .font(.system(size: size.actionIconSize - 4, weight: .medium))
                .foregroundColor(.secondary)
                .rotationEffect(.degrees(isExpanded ? 0 : -90))
                .animation(.easeInOut(duration: 0.25), value: isExpanded)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Actions
    
    private func toggleExpansion() {
        isExpanded.toggle()
        onToggle?(isExpanded)
    }
}

// MARK: - Convenience Initializers

public extension FloeSectionHeader {
    /// Create a simple section header with just title
    static func title(
        _ title: String,
        style: Style = .plain,
        size: Size = .medium
    ) -> FloeSectionHeader {
        return FloeSectionHeader(
            title,
            style: style,
            size: size
        )
    }
    
    /// Create a section header with "See All" action
    static func seeAll(
        _ title: String,
        subtitle: String? = nil,
        style: Style = .plain,
        size: Size = .medium,
        onSeeAll: @escaping () -> Void
    ) -> FloeSectionHeader {
        return FloeSectionHeader(
            title,
            subtitle: subtitle,
            actionTitle: "See All",
            style: style,
            size: size,
            onAction: onSeeAll
        )
    }
    
    /// Create a collapsible section header
    static func collapsible(
        _ title: String,
        subtitle: String? = nil,
        style: Style = .background,
        size: Size = .medium,
        isExpanded: Bool = true,
        onToggle: @escaping (Bool) -> Void
    ) -> FloeSectionHeader {
        return FloeSectionHeader(
            title,
            subtitle: subtitle,
            style: style,
            size: size,
            isCollapsible: true,
            isExpanded: isExpanded,
            onToggle: onToggle
        )
    }
}

// MARK: - Previews

struct FloeSectionHeader_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ScrollView {
                VStack(spacing: FloeSpacing.Size.lg.value) {
                    PreviewWrapper()
                }
                .floePadding(.spacious)
            }
            .previewDisplayName("Light Mode")
            .environment(\.colorScheme, .light)
            
            ScrollView {
                VStack(spacing: FloeSpacing.Size.lg.value) {
                    PreviewWrapper()
                }
                .floePadding(.spacious)
            }
            .previewDisplayName("Dark Mode")
            .environment(\.colorScheme, .dark)
        }
        .previewLayout(.sizeThatFits)
    }
    
    struct PreviewWrapper: View {
        @State private var isSettingsExpanded = true
        @State private var isNotificationsExpanded = false
        
        var body: some View {
            VStack(spacing: FloeSpacing.Size.xl.value) {
                // Basic Headers
                VStack(alignment: .leading, spacing: FloeSpacing.Size.md.value) {
                    Text("Basic Headers")
                        .floeFont(.headline)
                        .padding(.horizontal)
                    
                    FloeSectionHeader.title("Simple Title", style: .plain)
                    
                    FloeSectionHeader(
                        "Featured Items",
                        subtitle: "Handpicked for you",
                        style: .background
                    )
                    
                    FloeSectionHeader(
                        "Recent Activity",
                        subtitle: "Last 7 days",
                        style: .divider
                    )
                }
                
                // Headers with Actions
                VStack(alignment: .leading, spacing: FloeSpacing.Size.md.value) {
                    Text("With Actions")
                        .floeFont(.headline)
                        .padding(.horizontal)
                    
                    FloeSectionHeader.seeAll(
                        "Popular Categories",
                        subtitle: "Trending now",
                        style: .card
                    ) {
                        print("See All tapped")
                    }
                    
                    FloeSectionHeader(
                        "Downloads",
                        actionIcon: Image(systemName: "plus.circle"),
                        style: .background,
                        onAction: {
                            print("Add download tapped")
                        }
                    )
                }
                
                // Collapsible Headers
                VStack(alignment: .leading, spacing: FloeSpacing.Size.md.value) {
                    Text("Collapsible")
                        .floeFont(.headline)
                        .padding(.horizontal)
                    
                    FloeSectionHeader.collapsible(
                        "Settings",
                        subtitle: "App preferences",
                        style: .card,
                        isExpanded: isSettingsExpanded
                    ) { expanded in
                        isSettingsExpanded = expanded
                    }
                    
                    if isSettingsExpanded {
                        VStack(spacing: FloeSpacing.Size.sm.value) {
                            ForEach(["Notifications", "Privacy", "Account"], id: \.self) { item in
                                HStack {
                                    Text(item)
                                        .floeFont(.body)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                                .floePadding(.comfortable)
                                .background(Color.floePreviewBackground)
                                .cornerRadius(8)
                            }
                        }
                        .floePadding(.horizontal, FloeSpacing.Size.lg)
                    }
                    
                    FloeSectionHeader.collapsible(
                        "Notifications",
                        style: .background,
                        isExpanded: isNotificationsExpanded
                    ) { expanded in
                        isNotificationsExpanded = expanded
                    }
                    
                    if isNotificationsExpanded {
                        Text("Notification settings would appear here...")
                            .floeFont(.body)
                            .foregroundColor(.secondary)
                            .floePadding(.comfortable)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.floePreviewBackground)
                            .cornerRadius(8)
                            .floePadding(.horizontal, FloeSpacing.Size.lg)
                    }
                }
                
                // Size Variations
                VStack(alignment: .leading, spacing: FloeSpacing.Size.md.value) {
                    Text("Size Variations")
                        .floeFont(.headline)
                        .padding(.horizontal)
                    
                    FloeSectionHeader("Small Header", style: .background, size: .small)
                    FloeSectionHeader("Medium Header", subtitle: "Default size", style: .card, size: .medium)
                    FloeSectionHeader("Large Header", subtitle: "Prominent display", style: .background, size: .large)
                }
            }
        }
    }
} 
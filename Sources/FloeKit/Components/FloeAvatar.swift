import SwiftUI

public struct FloeAvatar: View {
    public enum Size {
        case small, medium, large, extraLarge
        
        var diameter: CGFloat {
            switch self {
            case .small: return 32
            case .medium: return 48
            case .large: return 64
            case .extraLarge: return 96
            }
        }
        
        var font: Font {
            switch self {
            case .small: return FloeFont.font(.caption)
            case .medium: return FloeFont.font(.body)
            case .large: return FloeFont.font(.headline)
            case .extraLarge: return FloeFont.font(.title)
            }
        }
        
        var indicatorSize: CGFloat {
            switch self {
            case .small: return 8
            case .medium: return 12
            case .large: return 16
            case .extraLarge: return 20
            }
        }
    }
    
    public enum Content {
        case image(Image)
        case systemImage(String)
        case initials(String)
        case placeholder
    }
    
    public enum StatusIndicator: Equatable {
        case none
        case online
        case offline
        case away
        case busy
        case custom(Color)
        
        var color: Color {
            switch self {
            case .none: return .clear
            case .online: return FloeColors.success
            case .offline: return FloeColors.neutral40
            case .away: return FloeColors.warning
            case .busy: return FloeColors.error
            case .custom(let color): return color
            }
        }
    }
    
    private let content: Content
    private let size: Size
    private let backgroundColor: Color
    private let foregroundColor: Color
    private let borderColor: Color?
    private let borderWidth: CGFloat
    private let statusIndicator: StatusIndicator
    private let shadowStyle: FloeShadow.Style
    private let onTap: (() -> Void)?
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var isPressed = false
    
    // MARK: - Initializers
    
    /// Initialize with image
    public init(
        image: Image,
        size: Size = .medium,
        backgroundColor: Color = FloeColors.surface,
        foregroundColor: Color = Color.primary,
        borderColor: Color? = nil,
        borderWidth: CGFloat = 0,
        statusIndicator: StatusIndicator = .none,
        shadowStyle: FloeShadow.Style = .soft,
        onTap: (() -> Void)? = nil
    ) {
        self.content = .image(image)
        self.size = size
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.statusIndicator = statusIndicator
        self.shadowStyle = shadowStyle
        self.onTap = onTap
    }
    
    /// Initialize with system image
    public init(
        systemImage: String,
        size: Size = .medium,
        backgroundColor: Color = FloeColors.surface,
        foregroundColor: Color = Color.primary,
        borderColor: Color? = nil,
        borderWidth: CGFloat = 0,
        statusIndicator: StatusIndicator = .none,
        shadowStyle: FloeShadow.Style = .soft,
        onTap: (() -> Void)? = nil
    ) {
        self.content = .systemImage(systemImage)
        self.size = size
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.statusIndicator = statusIndicator
        self.shadowStyle = shadowStyle
        self.onTap = onTap
    }
    
    /// Initialize with initials
    public init(
        initials: String,
        size: Size = .medium,
        backgroundColor: Color = FloeColors.primary,
        foregroundColor: Color = Color.white,
        borderColor: Color? = nil,
        borderWidth: CGFloat = 0,
        statusIndicator: StatusIndicator = .none,
        shadowStyle: FloeShadow.Style = .soft,
        onTap: (() -> Void)? = nil
    ) {
        self.content = .initials(initials)
        self.size = size
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.statusIndicator = statusIndicator
        self.shadowStyle = shadowStyle
        self.onTap = onTap
    }
    
    /// Initialize with placeholder
    public init(
        size: Size = .medium,
        backgroundColor: Color = FloeColors.surface,
        foregroundColor: Color = Color.secondary,
        borderColor: Color? = nil,
        borderWidth: CGFloat = 0,
        statusIndicator: StatusIndicator = .none,
        shadowStyle: FloeShadow.Style = .soft,
        onTap: (() -> Void)? = nil
    ) {
        self.content = .placeholder
        self.size = size
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.statusIndicator = statusIndicator
        self.shadowStyle = shadowStyle
        self.onTap = onTap
    }
    
    public var body: some View {
        ZStack {
            // Main avatar content
            avatarContent
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: isPressed)
            
            // Status indicator
            if statusIndicator != .none {
                statusIndicatorView
            }
        }
        .onTapGesture {
            onTap?()
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if onTap != nil {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
    
    // MARK: - Avatar Content
    
    private var avatarContent: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(backgroundColor)
                .frame(width: size.diameter, height: size.diameter)
                .floeShadow(shadowStyle)
            
            // Border if specified
            if let borderColor = borderColor, borderWidth > 0 {
                Circle()
                    .strokeBorder(borderColor, lineWidth: borderWidth)
                    .frame(width: size.diameter, height: size.diameter)
            }
            
            // Content
            contentView
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch content {
        case .image(let image):
            image
                .resizable()
                .scaledToFill()
                .frame(width: size.diameter - borderWidth * 2, height: size.diameter - borderWidth * 2)
                .clipShape(Circle())
            
        case .systemImage(let systemName):
            Image(systemName: systemName)
                .font(.system(size: size.diameter * 0.4, weight: .medium))
                .foregroundColor(foregroundColor)
            
        case .initials(let initials):
            Text(initials.prefix(2).uppercased())
                .font(size.font)
                .fontWeight(.semibold)
                .foregroundColor(foregroundColor)
            
        case .placeholder:
            Image(systemName: "person.fill")
                .font(.system(size: size.diameter * 0.4, weight: .medium))
                .foregroundColor(foregroundColor)
        }
    }
    
    private var statusIndicatorView: some View {
        Circle()
            .fill(statusIndicator.color)
            .frame(width: size.indicatorSize, height: size.indicatorSize)
            .overlay(
                Circle()
                    .strokeBorder(FloeColors.background, lineWidth: 2)
            )
            .offset(x: size.diameter * 0.3, y: size.diameter * 0.3)
    }
}

// MARK: - Grouped Avatars

public struct FloeAvatarGroup: View {
    public enum Style {
        case stacked
        case grid(columns: Int)
    }
    
    private let avatars: [FloeAvatar]
    private let style: Style
    private let maxVisible: Int
    private let size: FloeAvatar.Size
    private let spacing: CGFloat
    
    public init(
        avatars: [FloeAvatar],
        style: Style = .stacked,
        maxVisible: Int = 4,
        size: FloeAvatar.Size = .medium,
        spacing: CGFloat? = nil
    ) {
        self.avatars = avatars
        self.style = style
        self.maxVisible = maxVisible
        self.size = size
        self.spacing = spacing ?? size.diameter * -0.25 // Default overlap for stacked
    }
    
    public var body: some View {
        switch style {
        case .stacked:
            stackedAvatars
        case .grid(let columns):
            gridAvatars(columns: columns)
        }
    }
    
    private var stackedAvatars: some View {
        HStack(spacing: spacing) {
            ForEach(Array(avatars.prefix(maxVisible).enumerated()), id: \.offset) { index, avatar in
                avatar
                    .zIndex(Double(maxVisible - index))
            }
            
            if avatars.count > maxVisible {
                FloeAvatar(
                    initials: "+\(avatars.count - maxVisible)",
                    size: size,
                    backgroundColor: FloeColors.neutral30,
                    foregroundColor: Color.white
                )
                .zIndex(0)
            }
        }
    }
    
    private func gridAvatars(columns: Int) -> some View {
        let rows = (avatars.count + columns - 1) / columns
        
        return VStack(spacing: FloeSpacing.Size.xs.value) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: FloeSpacing.Size.xs.value) {
                    ForEach(0..<columns, id: \.self) { column in
                        let index = row * columns + column
                        if index < avatars.count {
                            avatars[index]
                        } else {
                            Color.clear
                                .frame(width: size.diameter, height: size.diameter)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Convenience Initializers

public extension FloeAvatar {
    /// Create avatar with user initials
    static func initials(
        _ text: String,
        size: Size = .medium,
        backgroundColor: Color = FloeColors.primary,
        foregroundColor: Color = Color.white
    ) -> FloeAvatar {
        return FloeAvatar(
            initials: text,
            size: size,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor
        )
    }
    
    /// Create avatar with system icon
    static func icon(
        _ systemName: String,
        size: Size = .medium,
        backgroundColor: Color = FloeColors.surface,
        foregroundColor: Color = Color.primary
    ) -> FloeAvatar {
        return FloeAvatar(
            systemImage: systemName,
            size: size,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor
        )
    }
    
    /// Create avatar with online status
    static func online(
        initials: String,
        size: Size = .medium
    ) -> FloeAvatar {
        return FloeAvatar(
            initials: initials,
            size: size,
            statusIndicator: .online
        )
    }
    
    /// Create placeholder avatar
    static func placeholder(
        size: Size = .medium
    ) -> FloeAvatar {
        return FloeAvatar(size: size)
    }
}

// MARK: - Previews

struct FloeAvatar_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Dark mode preview (default)
            ScrollView {
                VStack(spacing: FloeSpacing.Size.lg.value) {
                    PreviewWrapper()
                }
                .floePadding(.spacious)
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
            
            // Light mode preview
            ScrollView {
                VStack(spacing: FloeSpacing.Size.lg.value) {
                    PreviewWrapper()
                }
                .floePadding(.spacious)
            }
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")
        }
        .previewLayout(.sizeThatFits)
    }
    
    struct PreviewWrapper: View {
        var body: some View {
            VStack(spacing: FloeSpacing.Size.xl.value) {
                // Basic Avatars
                VStack(alignment: .leading, spacing: FloeSpacing.Size.md.value) {
                    Text("Basic Avatars")
                        .floeFont(.headline)
                        .padding(.horizontal)
                    
                    HStack(spacing: FloeSpacing.Size.lg.value) {
                        FloeAvatar.initials("JD")
                        FloeAvatar.icon("person.fill")
                        FloeAvatar.placeholder()
                        FloeAvatar(
                            systemImage: "star.fill",
                            backgroundColor: FloeColors.accent,
                            foregroundColor: .white
                        )
                    }
                }
                
                // Size Variations
                VStack(alignment: .leading, spacing: FloeSpacing.Size.md.value) {
                    Text("Size Variations")
                        .floeFont(.headline)
                        .padding(.horizontal)
                    
                    HStack(spacing: FloeSpacing.Size.lg.value) {
                        FloeAvatar.initials("S", size: .small)
                        FloeAvatar.initials("M", size: .medium)
                        FloeAvatar.initials("L", size: .large)
                        FloeAvatar.initials("XL", size: .extraLarge)
                    }
                }
                
                // Status Indicators
                VStack(alignment: .leading, spacing: FloeSpacing.Size.md.value) {
                    Text("Status Indicators")
                        .floeFont(.headline)
                        .padding(.horizontal)
                    
                    HStack(spacing: FloeSpacing.Size.lg.value) {
                        FloeAvatar.online(initials: "ON")
                        
                        FloeAvatar(
                            initials: "OF",
                            statusIndicator: .offline
                        )
                        
                        FloeAvatar(
                            initials: "AW",
                            statusIndicator: .away
                        )
                        
                        FloeAvatar(
                            initials: "BY",
                            statusIndicator: .busy
                        )
                        
                        FloeAvatar(
                            initials: "CT",
                            statusIndicator: .custom(.purple)
                        )
                    }
                }
                
                // Custom Styling
                VStack(alignment: .leading, spacing: FloeSpacing.Size.md.value) {
                    Text("Custom Styling")
                        .floeFont(.headline)
                        .padding(.horizontal)
                    
                    HStack(spacing: FloeSpacing.Size.lg.value) {
                        FloeAvatar(
                            initials: "BR",
                            backgroundColor: .clear,
                            foregroundColor: FloeColors.primary,
                            borderColor: FloeColors.primary,
                            borderWidth: 2
                        )
                        
                        FloeAvatar(
                            systemImage: "crown.fill",
                            backgroundColor: Color.orange,
                            foregroundColor: .white,
                            shadowStyle: .elevated
                        )
                        
                        FloeAvatar(
                            initials: "VIP",
                            backgroundColor: Color.black,
                            foregroundColor: FloeColors.accent,
                            borderColor: FloeColors.accent,
                            borderWidth: 2
                        )
                    }
                }
                
                // Grouped Avatars
                VStack(alignment: .leading, spacing: FloeSpacing.Size.md.value) {
                    Text("Grouped Avatars")
                        .floeFont(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: FloeSpacing.Size.lg.value) {
                        // Stacked avatars
                        FloeAvatarGroup(
                            avatars: [
                                FloeAvatar.initials("A", backgroundColor: FloeColors.error),
                                FloeAvatar.initials("B", backgroundColor: FloeColors.primary),
                                FloeAvatar.initials("C", backgroundColor: FloeColors.success),
                                FloeAvatar.initials("D", backgroundColor: .purple),
                                FloeAvatar.initials("E", backgroundColor: .orange),
                                FloeAvatar.initials("F", backgroundColor: .pink)
                            ],
                            style: .stacked,
                            maxVisible: 4
                        )
                        
                        // Grid avatars
                        FloeAvatarGroup(
                            avatars: [
                                FloeAvatar.initials("1"),
                                FloeAvatar.initials("2"),
                                FloeAvatar.initials("3"),
                                FloeAvatar.initials("4"),
                                FloeAvatar.initials("5"),
                                FloeAvatar.initials("6")
                            ],
                            style: .grid(columns: 3),
                            size: .small
                        )
                    }
                }
                
                // Interactive Avatars
                VStack(alignment: .leading, spacing: FloeSpacing.Size.md.value) {
                    Text("Interactive")
                        .floeFont(.headline)
                        .padding(.horizontal)
                    
                    HStack(spacing: FloeSpacing.Size.lg.value) {
                        FloeAvatar(
                            initials: "TAP",
                            backgroundColor: FloeColors.secondary,
                            foregroundColor: .white
                        ) {
                            print("Avatar tapped!")
                        }
                        
                        FloeAvatar(
                            systemImage: "plus",
                            backgroundColor: FloeColors.surface,
                            foregroundColor: FloeColors.primary,
                            borderColor: FloeColors.primary,
                            borderWidth: 2
                        ) {
                            print("Add avatar tapped!")
                        }
                    }
                }
            }
        }
    }
} 
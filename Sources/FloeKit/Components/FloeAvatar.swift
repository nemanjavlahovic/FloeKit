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
                .font(.system(size: fontSizeForAvatarSize(size), weight: .semibold))
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

// MARK: - Helper Functions

private func fontSizeForAvatarSize(_ size: FloeAvatar.Size) -> CGFloat {
    switch size {
    case .small: return 12
    case .medium: return 16
    case .large: return 18
    case .extraLarge: return 24
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

#Preview("Avatar Sizes") {
    HStack(spacing: FloeSpacing.Size.md.value) {
        FloeAvatar.initials("JS", size: .small)
        FloeAvatar.initials("MD", size: .medium)
        FloeAvatar.initials("AB", size: .large)
        FloeAvatar.initials("KL", size: .extraLarge)
    }
    .padding()
}

#Preview("Avatar with Initials") {
    HStack(spacing: FloeSpacing.Size.md.value) {
        FloeAvatar.initials("JS")
        FloeAvatar.initials("MD", backgroundColor: .blue)
        FloeAvatar.initials("AB", backgroundColor: .green)
        FloeAvatar.initials("KL", backgroundColor: .purple)
    }
    .padding()
}

#Preview("Avatar with System Icons") {
    HStack(spacing: FloeSpacing.Size.md.value) {
        FloeAvatar.icon("person.fill")
        FloeAvatar.icon("star.fill", backgroundColor: .orange)
        FloeAvatar.icon("heart.fill", backgroundColor: .pink)
        FloeAvatar.icon("bolt.fill", backgroundColor: .yellow)
    }
    .padding()
}

#Preview("Avatar with Status Indicators") {
    HStack(spacing: FloeSpacing.Size.md.value) {
        FloeAvatar(initials: "ON", statusIndicator: .online)
        FloeAvatar(initials: "OFF", statusIndicator: .offline)
        FloeAvatar(initials: "AW", statusIndicator: .away)
        FloeAvatar(initials: "BS", statusIndicator: .busy)
    }
    .padding()
}

#Preview("Placeholder Avatars") {
    HStack(spacing: FloeSpacing.Size.md.value) {
        FloeAvatar.placeholder(size: .small)
        FloeAvatar.placeholder(size: .medium)
        FloeAvatar.placeholder(size: .large)
        FloeAvatar.placeholder(size: .extraLarge)
    }
    .padding()
}

#Preview("Custom Styled Avatars") {
    HStack(spacing: FloeSpacing.Size.md.value) {
        FloeAvatar(
            initials: "BP",
            backgroundColor: Color.blue.opacity(0.2),
            foregroundColor: .blue,
            borderColor: .blue,
            borderWidth: 2
        )
        
        FloeAvatar(
            systemImage: "crown.fill",
            backgroundColor: Color.yellow.opacity(0.2),
            foregroundColor: .orange,
            borderColor: .orange,
            borderWidth: 3
        )
        
        FloeAvatar(
            initials: "VIP",
            backgroundColor: .black,
            foregroundColor: .white,
            borderColor: .yellow,
            borderWidth: 2
        )
    }
    .padding()
}

#Preview("Interactive Avatars") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        Text("Tap avatars to see interaction")
            .font(.caption)
            .foregroundColor(.gray)
        
        HStack(spacing: FloeSpacing.Size.md.value) {
            FloeAvatar(initials: "TM", onTap: { print("Profile tapped") })
            FloeAvatar(systemImage: "message.fill", backgroundColor: .blue, onTap: { print("Message tapped") })
            FloeAvatar(systemImage: "phone.fill", backgroundColor: .green, onTap: { print("Call tapped") })
        }
    }
    .padding()
}

#Preview("Avatar Groups - Stacked") {
    VStack(spacing: FloeSpacing.Size.lg.value) {
        Text("Stacked Avatar Groups")
            .font(.headline)
        
        FloeAvatarGroup(
            avatars: [
                FloeAvatar.initials("AB"),
                FloeAvatar.initials("CD"),
                FloeAvatar.initials("EF")
            ],
            style: .stacked
        )
        
        FloeAvatarGroup(
            avatars: [
                FloeAvatar.initials("AB"),
                FloeAvatar.initials("CD"),
                FloeAvatar.initials("EF"),
                FloeAvatar.initials("GH"),
                FloeAvatar.initials("IJ"),
                FloeAvatar.initials("KL")
            ],
            style: .stacked,
            maxVisible: 3
        )
    }
    .padding()
}

#Preview("Avatar Groups - Grid") {
    VStack(spacing: FloeSpacing.Size.lg.value) {
        Text("Grid Avatar Groups")
            .font(.headline)
        
        FloeAvatarGroup(
            avatars: [
                FloeAvatar.initials("AB", size: .small),
                FloeAvatar.initials("CD", size: .small),
                FloeAvatar.initials("EF", size: .small),
                FloeAvatar.initials("GH", size: .small)
            ],
            style: .grid(columns: 2),
            size: .small
        )
        
        FloeAvatarGroup(
            avatars: [
                FloeAvatar.initials("AB", size: .small),
                FloeAvatar.initials("CD", size: .small),
                FloeAvatar.initials("EF", size: .small),
                FloeAvatar.initials("GH", size: .small),
                FloeAvatar.initials("IJ", size: .small),
                FloeAvatar.initials("KL", size: .small)
            ],
            style: .grid(columns: 3),
            size: .small
        )
    }
    .padding()
}

#Preview("Team Avatar Examples") {
    VStack(spacing: FloeSpacing.Size.lg.value) {
        Text("Team Collaboration")
            .font(.system(size: 28, weight: .bold))
        
        VStack(spacing: FloeSpacing.Size.md.value) {
            HStack {
                Text("Online Team Members:")
                    .font(.subheadline)
                Spacer()
            }
            
            FloeAvatarGroup(
                avatars: [
                    FloeAvatar.online(initials: "JD", size: .medium),
                    FloeAvatar.online(initials: "SM", size: .medium),
                    FloeAvatar(initials: "MK", size: .medium, statusIndicator: .away),
                    FloeAvatar(initials: "LR", size: .medium, statusIndicator: .busy),
                    FloeAvatar(initials: "TW", size: .medium, statusIndicator: .offline)
                ],
                style: .stacked,
                maxVisible: 4,
                size: .medium
            )
        }
        
        VStack(spacing: FloeSpacing.Size.md.value) {
            HStack {
                Text("Project Contributors:")
                    .font(.subheadline)
                Spacer()
            }
            
            FloeAvatarGroup(
                avatars: [
                    FloeAvatar.initials("AD", size: .small),
                    FloeAvatar.initials("BC", size: .small),
                    FloeAvatar.initials("DE", size: .small),
                    FloeAvatar.initials("FG", size: .small),
                    FloeAvatar.initials("HI", size: .small),
                    FloeAvatar.initials("JK", size: .small),
                    FloeAvatar.initials("LM", size: .small)
                ],
                style: .stacked,
                maxVisible: 5,
                size: .small
            )
        }
    }
    .padding()
}

#Preview("Special Avatars") {
    HStack(spacing: FloeSpacing.Size.md.value) {
        FloeAvatar(
            initials: "PRO",
            backgroundColor: Color.gold,
            foregroundColor: .white,
            borderColor: .yellow,
            borderWidth: 2
        )
        
        FloeAvatar(
            initials: "AI",
            backgroundColor: Color.purple.opacity(0.2),
            foregroundColor: .purple,
            borderColor: .purple,
            borderWidth: 2,
            statusIndicator: .custom(.purple)
        )
        
        FloeAvatar(
            systemImage: "sparkles",
            backgroundColor: Color.yellow.opacity(0.2),
            foregroundColor: .orange,
            shadowStyle: .elevated
        )
    }
    .padding()
}

#Preview("Dark Mode") {
    HStack(spacing: FloeSpacing.Size.md.value) {
        FloeAvatar.initials("DM")
        FloeAvatar.icon("moon.fill", backgroundColor: .indigo)
        FloeAvatar.online(initials: "ON")
        FloeAvatar.placeholder()
    }
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("Avatar Sizes Comparison") {
    VStack(spacing: FloeSpacing.Size.lg.value) {
        VStack {
            Text("Small (32pt)")
                .font(.caption)
                .foregroundColor(.gray)
            FloeAvatar.initials("S", size: .small)
        }
        
        VStack {
            Text("Medium (48pt)")
                .font(.caption)
                .foregroundColor(.gray)
            FloeAvatar.initials("M", size: .medium)
        }
        
        VStack {
            Text("Large (64pt)")
                .font(.caption)
                .foregroundColor(.gray)
            FloeAvatar.initials("L", size: .large)
        }
        
        VStack {
            Text("Extra Large (96pt)")
                .font(.caption)
                .foregroundColor(.gray)
            FloeAvatar.initials("XL", size: .extraLarge)
        }
    }
    .padding()
}


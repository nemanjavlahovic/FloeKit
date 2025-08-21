import SwiftUI

public struct FloeBadge: View {
    public enum Style {
        case number
        case dot
        case icon
        case text
    }
    
    public enum Position {
        case topTrailing
        case topLeading
        case bottomTrailing
        case bottomLeading
        case center
        
        var alignment: Alignment {
            switch self {
            case .topTrailing: return .topTrailing
            case .topLeading: return .topLeading
            case .bottomTrailing: return .bottomTrailing
            case .bottomLeading: return .bottomLeading
            case .center: return .center
            }
        }
        
        func offset(for size: CGSize) -> CGSize {
            switch self {
            case .topTrailing: return CGSize(width: size.width / 3, height: -size.height / 3)
            case .topLeading: return CGSize(width: -size.width / 3, height: -size.height / 3)
            case .bottomTrailing: return CGSize(width: size.width / 3, height: size.height / 3)
            case .bottomLeading: return CGSize(width: -size.width / 3, height: size.height / 3)
            case .center: return .zero
            }
        }
    }
    
    private let value: String?
    private let icon: String?
    private let style: Style
    private let color: Color
    private let textColor: Color
    private let position: Position
    private let animate: Bool
    private let size: CGFloat
    
    @State private var isAnimating = false
    
    public init(
        value: String? = nil,
        style: Style = .number,
        color: Color = FloeColors.error,
        textColor: Color = .white,
        position: Position = .topTrailing,
        animate: Bool = false,
        size: CGFloat = 20
    ) {
        self.value = value
        self.icon = nil
        self.style = style
        self.color = color
        self.textColor = textColor
        self.position = position
        self.animate = animate
        self.size = size
    }
    
    public init(
        icon: String,
        style: Style = .icon,
        color: Color = FloeColors.primary,
        textColor: Color = .white,
        position: Position = .topTrailing,
        animate: Bool = false,
        size: CGFloat = 20
    ) {
        self.value = nil
        self.icon = icon
        self.style = style
        self.color = color
        self.textColor = textColor
        self.position = position
        self.animate = animate
        self.size = size
    }
    
    public var body: some View {
        Group {
            switch style {
            case .dot:
                dotBadge
            case .number, .text:
                textBadge
            case .icon:
                iconBadge
            }
        }
        .scaleEffect(isAnimating ? 1.0 : 0.8)
        .opacity(isAnimating ? 1.0 : 0.0)
        .animation(animate ? .spring(response: 0.3, dampingFraction: 0.6) : nil, value: isAnimating)
        .onAppear {
            if animate {
                isAnimating = true
            } else {
                isAnimating = true
            }
        }
        .onChange(of: value) { _ in
            if animate {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                    isAnimating = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isAnimating = true
                    }
                }
            }
        }
    }
    
    private var dotBadge: some View {
        Circle()
            .fill(color)
            .frame(width: size / 2, height: size / 2)
            .overlay(
                Circle()
                    .strokeBorder(Color.white, lineWidth: 1.5)
            )
    }
    
    private var textBadge: some View {
        Group {
            if let value = value {
                Text(value)
                    .font(.system(size: size * 0.5, weight: .bold))
                    .foregroundColor(textColor)
                    .padding(.horizontal, size * 0.3)
                    .padding(.vertical, size * 0.15)
                    .background(
                        Capsule()
                            .fill(color)
                    )
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.white, lineWidth: 1.5)
                    )
                    .fixedSize()
            }
        }
    }
    
    private var iconBadge: some View {
        Group {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: size * 0.6, weight: .medium))
                    .foregroundColor(textColor)
                    .frame(width: size, height: size)
                    .background(
                        Circle()
                            .fill(color)
                    )
                    .overlay(
                        Circle()
                            .strokeBorder(Color.white, lineWidth: 1.5)
                    )
            }
        }
    }
}

// MARK: - Badge Modifier

public struct BadgeModifier<Badge: View>: ViewModifier {
    let badge: Badge
    let position: FloeBadge.Position
    
    public func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    badge
                        .offset(
                            x: position.offset(for: geometry.size).width,
                            y: position.offset(for: geometry.size).height
                        )
                        .frame(width: geometry.size.width, height: geometry.size.height, alignment: position.alignment)
                }
            )
    }
}

extension View {
    public func floeBadge<Badge: View>(
        _ badge: Badge,
        position: FloeBadge.Position = .topTrailing
    ) -> some View {
        modifier(BadgeModifier(badge: badge, position: position))
    }
    
    public func floeBadge(
        _ value: String,
        style: FloeBadge.Style = .number,
        color: Color = FloeColors.error,
        position: FloeBadge.Position = .topTrailing
    ) -> some View {
        modifier(BadgeModifier(
            badge: FloeBadge(value: value, style: style, color: color, position: position),
            position: position
        ))
    }
    
    public func floeBadge(
        count: Int,
        max: Int = 99,
        color: Color = FloeColors.error,
        position: FloeBadge.Position = .topTrailing
    ) -> some View {
        let displayValue = count > max ? "\(max)+" : "\(count)"
        return modifier(BadgeModifier(
            badge: count > 0 ? FloeBadge(value: displayValue, style: .number, color: color, position: position) : nil,
            position: position
        ))
    }
    
    public func floeDotBadge(
        isVisible: Bool = true,
        color: Color = FloeColors.error,
        position: FloeBadge.Position = .topTrailing
    ) -> some View {
        modifier(BadgeModifier(
            badge: isVisible ? FloeBadge(style: .dot, color: color, position: position) : nil,
            position: position
        ))
    }
}

// MARK: - Convenience Initializers

extension FloeBadge {
    public static func notification(count: Int, max: Int = 99) -> FloeBadge {
        let displayValue = count > max ? "\(max)+" : "\(count)"
        return FloeBadge(value: displayValue, style: .number, color: FloeColors.error)
    }
    
    public static func status(online: Bool) -> FloeBadge {
        FloeBadge(style: .dot, color: online ? FloeColors.success : FloeColors.neutral40)
    }
    
    public static func streak(_ count: Int) -> FloeBadge {
        FloeBadge(value: "\(count)🔥", style: .text, color: FloeColors.accent)
    }
    
    public static func new() -> FloeBadge {
        FloeBadge(value: "NEW", style: .text, color: FloeColors.primary, animate: true)
    }
    
    public static func pro() -> FloeBadge {
        FloeBadge(icon: "crown.fill", style: .icon, color: FloeColors.accent)
    }
}

// MARK: - Previews

struct FloeBadge_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Dark mode
            ScrollView {
                VStack(spacing: 40) {
                    // Basic badges
                    HStack(spacing: 30) {
                        VStack(spacing: 20) {
                            Text("Number")
                                .font(.caption)
                            
                            Image(systemName: "bell.fill")
                                .font(.system(size: 30))
                                .foregroundColor(FloeColors.neutral40)
                                .floeBadge("3", position: .topTrailing)
                                .frame(width: 50, height: 50)
                        }
                        
                        VStack(spacing: 20) {
                            Text("Dot")
                                .font(.caption)
                            
                            Image(systemName: "message.fill")
                                .font(.system(size: 30))
                                .foregroundColor(FloeColors.neutral40)
                                .floeDotBadge(position: .topTrailing)
                                .frame(width: 50, height: 50)
                        }
                        
                        VStack(spacing: 20) {
                            Text("Icon")
                                .font(.caption)
                            
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(FloeColors.neutral40)
                                .floeBadge(
                                    FloeBadge(icon: "star.fill", color: FloeColors.accent),
                                    position: .bottomTrailing
                                )
                                .frame(width: 50, height: 50)
                        }
                    }
                    
                    Divider()
                    
                    // Position examples
                    VStack(spacing: 20) {
                        Text("Badge Positions")
                            .font(.headline)
                        
                        HStack(spacing: 30) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(FloeColors.surface)
                                .frame(width: 60, height: 60)
                                .floeBadge("TL", position: .topLeading)
                            
                            RoundedRectangle(cornerRadius: 12)
                                .fill(FloeColors.surface)
                                .frame(width: 60, height: 60)
                                .floeBadge("TR", position: .topTrailing)
                            
                            RoundedRectangle(cornerRadius: 12)
                                .fill(FloeColors.surface)
                                .frame(width: 60, height: 60)
                                .floeBadge("BL", position: .bottomLeading)
                            
                            RoundedRectangle(cornerRadius: 12)
                                .fill(FloeColors.surface)
                                .frame(width: 60, height: 60)
                                .floeBadge("BR", position: .bottomTrailing)
                        }
                    }
                    
                    Divider()
                    
                    // Preset badges
                    VStack(spacing: 20) {
                        Text("Preset Badges")
                            .font(.headline)
                        
                        HStack(spacing: 30) {
                            VStack {
                                FloeCard {
                                    Text("Notifications")
                                }
                                .floeBadge(FloeBadge.notification(count: 150))
                            }
                            
                            VStack {
                                FloeAvatar.initials("JD")
                                    .floeBadge(FloeBadge.status(online: true), position: .bottomTrailing)
                            }
                            
                            VStack {
                                FloeButton.primary("Streak") {}
                                    .floeBadge(FloeBadge.streak(7), position: .topTrailing)
                            }
                        }
                        
                        HStack(spacing: 30) {
                            FloeCard {
                                Text("New Feature")
                            }
                            .floeBadge(FloeBadge.new())
                            
                            FloeButton.secondary("Premium") {}
                                .floeBadge(FloeBadge.pro(), position: .topTrailing)
                        }
                    }
                    
                    Divider()
                    
                    // Count badges with max
                    VStack(spacing: 20) {
                        Text("Count Badges")
                            .font(.headline)
                        
                        HStack(spacing: 30) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 30))
                                .floeBadge(count: 5)
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 30))
                                .floeBadge(count: 99)
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 30))
                                .floeBadge(count: 150)
                                .frame(width: 50, height: 50)
                        }
                    }
                }
                .padding()
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
            
            // Light mode
            ScrollView {
                VStack(spacing: 40) {
                    HStack(spacing: 30) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 30))
                            .foregroundColor(FloeColors.neutral40)
                            .floeBadge("3", position: .topTrailing)
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "message.fill")
                            .font(.system(size: 30))
                            .foregroundColor(FloeColors.neutral40)
                            .floeDotBadge(position: .topTrailing)
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(FloeColors.neutral40)
                            .floeBadge(
                                FloeBadge(icon: "star.fill", color: FloeColors.accent),
                                position: .bottomTrailing
                            )
                            .frame(width: 50, height: 50)
                    }
                }
                .padding()
            }
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")
        }
    }
}
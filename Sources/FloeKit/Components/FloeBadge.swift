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

#Preview("Badge Styles") {
    VStack(spacing: FloeSpacing.Size.lg.value) {
        HStack(spacing: FloeSpacing.Size.xl.value) {
            FloeBadge(value: "5", style: .number)
            FloeBadge(style: .dot)
            FloeBadge(icon: "star.fill", style: .icon)
            FloeBadge(value: "NEW", style: .text)
        }
    }
    .padding()
}

#Preview("Number Badges") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        HStack(spacing: FloeSpacing.Size.lg.value) {
            FloeBadge(value: "1")
            FloeBadge(value: "9")
            FloeBadge(value: "99")
            FloeBadge(value: "99+")
        }
        
        HStack(spacing: FloeSpacing.Size.lg.value) {
            FloeBadge(value: "3", color: .blue)
            FloeBadge(value: "12", color: .green)
            FloeBadge(value: "999", color: .orange)
        }
    }
    .padding()
}

#Preview("Icon Badges") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        HStack(spacing: FloeSpacing.Size.lg.value) {
            FloeBadge.pro()
            FloeBadge(icon: "star.fill", color: .yellow)
            FloeBadge(icon: "heart.fill", color: .pink)
            FloeBadge(icon: "checkmark", color: .green)
        }
        
        HStack(spacing: FloeSpacing.Size.lg.value) {
            FloeBadge(icon: "bolt.fill", color: .orange)
            FloeBadge(icon: "flame.fill", color: .red)
            FloeBadge(icon: "shield.fill", color: .blue)
        }
    }
    .padding()
}

#Preview("Text Badges") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        HStack(spacing: FloeSpacing.Size.lg.value) {
            FloeBadge.new()
            FloeBadge(value: "BETA", style: .text, color: .blue)
            FloeBadge(value: "HOT", style: .text, color: .red)
            FloeBadge(value: "SALE", style: .text, color: .green)
        }
        
        HStack(spacing: FloeSpacing.Size.lg.value) {
            FloeBadge.streak(7)
            FloeBadge(value: "VIP", style: .text, color: .purple)
            FloeBadge(value: "PREMIUM", style: .text, color: .orange)
        }
    }
    .padding()
}

#Preview("Dot Badges") {
    HStack(spacing: FloeSpacing.Size.lg.value) {
        FloeBadge.status(online: true)
        FloeBadge.status(online: false)
        FloeBadge(style: .dot, color: .blue)
        FloeBadge(style: .dot, color: .green)
        FloeBadge(style: .dot, color: .orange)
    }
    .padding()
}

#Preview("Badge Sizes") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        Text("Different Sizes")
            .font(.headline)
        
        HStack(spacing: FloeSpacing.Size.lg.value) {
            FloeBadge(value: "5", size: 16)
            FloeBadge(value: "10", size: 20)
            FloeBadge(value: "25", size: 24)
            FloeBadge(value: "50", size: 28)
        }
        
        HStack(spacing: FloeSpacing.Size.lg.value) {
            FloeBadge(style: .dot, size: 16)
            FloeBadge(style: .dot, size: 20)
            FloeBadge(style: .dot, size: 24)
            FloeBadge(style: .dot, size: 28)
        }
    }
    .padding()
}

#Preview("Badges on Views") {
    VStack(spacing: FloeSpacing.Size.xl.value) {
        Text("Badge Modifiers")
            .font(.system(size: 28, weight: .bold))
        
        HStack(spacing: FloeSpacing.Size.xl.value) {
            // Button with number badge
            Button("Messages") {}
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                .floeBadge("3")
            
            // Icon with dot badge
            Image(systemName: "bell.fill")
                .font(.system(size: 30))
                .floeDotBadge()
            
            // Custom badge
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 60)
                .cornerRadius(10)
                .floeBadge("NEW", style: .text, color: .green, position: .topLeading)
        }
        
        HStack(spacing: FloeSpacing.Size.xl.value) {
            // Avatar with status
            Circle()
                .fill(Color.blue)
                .frame(width: 50, height: 50)
                .floeBadge(FloeBadge.status(online: true), position: .bottomTrailing)
            
            // Shopping cart with count
            Image(systemName: "cart.fill")
                .font(.system(size: 30))
                .floeBadge(count: 7)
            
            // Notification with high count
            Image(systemName: "envelope.fill")
                .font(.system(size: 30))
                .floeBadge(count: 127, max: 99)
        }
    }
    .padding()
}

#Preview("Badge Positions") {
    VStack(spacing: FloeSpacing.Size.lg.value) {
        Text("Badge Positions")
            .font(.headline)
        
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: FloeSpacing.Size.lg.value) {
            
            Rectangle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: 60, height: 60)
                .cornerRadius(10)
                .floeBadge("TL", position: .topLeading)
                .overlay(Text("Top\nLeading").font(.caption2))
            
            Rectangle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: 60, height: 60)
                .cornerRadius(10)
                .floeBadge("TR", position: .topTrailing)
                .overlay(Text("Top\nTrailing").font(.caption2))
            
            Rectangle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: 60, height: 60)
                .cornerRadius(10)
                .floeBadge("C", position: .center)
                .overlay(Text("Center").font(.caption2))
            
            Rectangle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: 60, height: 60)
                .cornerRadius(10)
                .floeBadge("BL", position: .bottomLeading)
                .overlay(Text("Bottom\nLeading").font(.caption2))
            
            Rectangle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: 60, height: 60)
                .cornerRadius(10)
                .floeBadge("BR", position: .bottomTrailing)
                .overlay(Text("Bottom\nTrailing").font(.caption2))
        }
    }
    .padding()
}

#Preview("Animated Badges") {
    VStack(spacing: FloeSpacing.Size.lg.value) {
        Text("Animated Badges")
            .font(.headline)
        
        HStack(spacing: FloeSpacing.Size.lg.value) {
            FloeBadge(value: "LIVE", style: .text, color: .red, animate: true)
            FloeBadge.new()
            FloeBadge(value: "🔥", style: .text, animate: true)
        }
        
        Text("These badges animate on appearance and value changes")
            .font(.caption)
            .foregroundColor(.gray)
    }
    .padding()
}

#Preview("E-commerce Badge Examples") {
    VStack(spacing: FloeSpacing.Size.lg.value) {
        Text("E-commerce Badges")
            .font(.system(size: 28, weight: .bold))
        
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: FloeSpacing.Size.lg.value) {
            
            // Product with sale badge
            VStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 120)
                    .cornerRadius(10)
                    .floeBadge("SALE", style: .text, color: .red, position: .topLeading)
                
                Text("Product Name")
                    .font(.subheadline)
            }
            
            // Product with new badge
            VStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 120)
                    .cornerRadius(10)
                    .floeBadge(FloeBadge.new(), position: .topTrailing)
                
                Text("New Product")
                    .font(.subheadline)
            }
            
            // Shopping cart icon
            VStack {
                Image(systemName: "cart.fill")
                    .font(.system(size: 40))
                    .floeBadge(count: 3)
                
                Text("Shopping Cart")
                    .font(.subheadline)
            }
            
            // Wishlist icon
            VStack {
                Image(systemName: "heart.fill")
                    .font(.system(size: 40))
                    .floeBadge(count: 12)
                
                Text("Wishlist")
                    .font(.subheadline)
            }
        }
    }
    .padding()
}

#Preview("Dark Mode") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        HStack(spacing: FloeSpacing.Size.lg.value) {
            FloeBadge(value: "5")
            FloeBadge.new()
            FloeBadge.pro()
            FloeBadge.status(online: true)
        }
        
        HStack(spacing: FloeSpacing.Size.lg.value) {
            Image(systemName: "bell.fill")
                .font(.system(size: 30))
                .floeBadge("99+")
            
            Image(systemName: "message.fill")
                .font(.system(size: 30))
                .floeDotBadge(color: .green)
        }
    }
    .padding()
    .preferredColorScheme(.dark)
}


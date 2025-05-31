import SwiftUI

public struct FloeSkeleton: View {
    public enum Style {
        case text(lines: Int = 3, lastLineWidth: CGFloat? = nil)
        case circle(size: CGFloat = 40)
        case rectangle(width: CGFloat? = nil, height: CGFloat = 16)
        case card(height: CGFloat = 200)
        case custom(content: () -> AnyView)
        
        var animationDelay: Double {
            switch self {
            case .text: return 0.1
            case .circle: return 0.0
            case .rectangle: return 0.05
            case .card: return 0.2
            case .custom: return 0.1
            }
        }
    }
    
    public enum AnimationType {
        case shimmer
        case pulse
        case wave
        case none
        
        var duration: Double {
            switch self {
            case .shimmer: return 1.5
            case .pulse: return 1.0
            case .wave: return 2.0
            case .none: return 0.0
            }
        }
    }
    
    private let style: Style
    private let animationType: AnimationType
    private let cornerRadius: CGFloat
    private let backgroundColor: Color
    private let highlightColor: Color
    private let isAnimated: Bool
    
    @State private var animationOffset: CGFloat = -1
    @State private var animationPhase: Double = 0
    
    public init(
        style: Style,
        animationType: AnimationType = .shimmer,
        cornerRadius: CGFloat = 8,
        backgroundColor: Color = FloeColors.neutral20,
        highlightColor: Color = FloeColors.neutral10,
        isAnimated: Bool = true
    ) {
        self.style = style
        self.animationType = animationType
        self.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
        self.highlightColor = highlightColor
        self.isAnimated = isAnimated
    }
    
    public var body: some View {
        Group {
            switch style {
            case .text(let lines, let lastLineWidth):
                textSkeleton(lines: lines, lastLineWidth: lastLineWidth)
                
            case .circle(let size):
                circleSkeleton(size: size)
                
            case .rectangle(let width, let height):
                rectangleSkeleton(width: width, height: height)
                
            case .card(let height):
                cardSkeleton(height: height)
                
            case .custom(let content):
                content()
                    .modifier(SkeletonAnimationModifier(
                        animationType: animationType,
                        backgroundColor: backgroundColor,
                        highlightColor: highlightColor,
                        isAnimated: isAnimated
                    ))
            }
        }
        .onAppear {
            if isAnimated {
                startAnimation()
            }
        }
    }
    
    // MARK: - Skeleton Components
    
    private func textSkeleton(lines: Int, lastLineWidth: CGFloat?) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(0..<lines, id: \.self) { index in
                let isLastLine = index == lines - 1
                let width = isLastLine ? (lastLineWidth ?? 0.6) : 1.0
                
                RoundedRectangle(cornerRadius: cornerRadius / 2)
                    .fill(backgroundColor)
                    .frame(height: 16)
                    .frame(maxWidth: .infinity)
                    .scaleEffect(x: width, anchor: .leading)
                    .modifier(SkeletonAnimationModifier(
                        animationType: animationType,
                        backgroundColor: backgroundColor,
                        highlightColor: highlightColor,
                        isAnimated: isAnimated
                    ))
                    .animation(.easeInOut.delay(Double(index) * 0.1), value: animationPhase)
            }
        }
    }
    
    private func circleSkeleton(size: CGFloat) -> some View {
        Circle()
            .fill(backgroundColor)
            .frame(width: size, height: size)
            .modifier(SkeletonAnimationModifier(
                animationType: animationType,
                backgroundColor: backgroundColor,
                highlightColor: highlightColor,
                isAnimated: isAnimated
            ))
    }
    
    private func rectangleSkeleton(width: CGFloat?, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(backgroundColor)
            .frame(width: width, height: height)
            .modifier(SkeletonAnimationModifier(
                animationType: animationType,
                backgroundColor: backgroundColor,
                highlightColor: highlightColor,
                isAnimated: isAnimated
            ))
    }
    
    private func cardSkeleton(height: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: FloeSpacing.Size.md.value) {
            // Header
            HStack(spacing: FloeSpacing.Size.md.value) {
                FloeSkeleton(
                    style: .circle(size: 40),
                    animationType: animationType,
                    backgroundColor: backgroundColor,
                    highlightColor: highlightColor,
                    isAnimated: isAnimated
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    FloeSkeleton(
                        style: .rectangle(width: 120, height: 16),
                        animationType: animationType,
                        backgroundColor: backgroundColor,
                        highlightColor: highlightColor,
                        isAnimated: isAnimated
                    )
                    FloeSkeleton(
                        style: .rectangle(width: 80, height: 12),
                        animationType: animationType,
                        backgroundColor: backgroundColor,
                        highlightColor: highlightColor,
                        isAnimated: isAnimated
                    )
                }
                
                Spacer()
            }
            
            // Content
            FloeSkeleton(
                style: .text(lines: 3, lastLineWidth: 0.7),
                animationType: animationType,
                backgroundColor: backgroundColor,
                highlightColor: highlightColor,
                isAnimated: isAnimated
            )
            
            // Actions
            HStack(spacing: FloeSpacing.Size.md.value) {
                FloeSkeleton(
                    style: .rectangle(width: 80, height: 32),
                    cornerRadius: 16,
                    backgroundColor: backgroundColor,
                    highlightColor: highlightColor,
                    isAnimated: isAnimated
                )
                FloeSkeleton(
                    style: .rectangle(width: 80, height: 32),
                    cornerRadius: 16,
                    backgroundColor: backgroundColor,
                    highlightColor: highlightColor,
                    isAnimated: isAnimated
                )
                Spacer()
            }
            
            Spacer()
        }
        .padding(FloeSpacing.Size.lg.value)
        .frame(height: height)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(FloeColors.surface)
        )
    }
    
    private func startAnimation() {
        withAnimation(
            .easeInOut(duration: animationType.duration)
            .repeatForever(autoreverses: true)
            .delay(style.animationDelay)
        ) {
            animationPhase = 1.0
        }
    }
}

// MARK: - Animation Modifier

struct SkeletonAnimationModifier: ViewModifier {
    let animationType: FloeSkeleton.AnimationType
    let backgroundColor: Color
    let highlightColor: Color
    let isAnimated: Bool
    
    @State private var animationPhase: Double = 0
    @State private var shimmerOffset: CGFloat = -1
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if isAnimated {
                        switch animationType {
                        case .shimmer:
                            shimmerOverlay
                        case .pulse:
                            pulseOverlay
                        case .wave:
                            waveOverlay
                        case .none:
                            EmptyView()
                        }
                    }
                }
            )
            .onAppear {
                if isAnimated {
                    startAnimation()
                }
            }
    }
    
    private var shimmerOverlay: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: backgroundColor.opacity(0), location: 0),
                            .init(color: highlightColor.opacity(0.6), location: 0.5),
                            .init(color: backgroundColor.opacity(0), location: 1)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: geometry.size.width)
                .offset(x: shimmerOffset * geometry.size.width * 2)
                .clipped()
        }
        .clipped()
    }
    
    private var pulseOverlay: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(highlightColor)
            .opacity(0.3 + 0.3 * sin(animationPhase * .pi * 2))
    }
    
    private var waveOverlay: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            backgroundColor,
                            highlightColor,
                            backgroundColor
                        ]),
                        startPoint: UnitPoint(x: animationPhase - 0.3, y: 0),
                        endPoint: UnitPoint(x: animationPhase + 0.3, y: 1)
                    )
                )
        }
    }
    
    private func startAnimation() {
        switch animationType {
        case .shimmer:
            withAnimation(
                .linear(duration: animationType.duration)
                .repeatForever(autoreverses: false)
            ) {
                shimmerOffset = 1
            }
        case .pulse, .wave:
            withAnimation(
                .easeInOut(duration: animationType.duration)
                .repeatForever(autoreverses: true)
            ) {
                animationPhase = 1.0
            }
        case .none:
            break
        }
    }
}

// MARK: - Convenience Extensions

public extension FloeSkeleton {
    /// Create a skeleton for a social media post
    static func post() -> FloeSkeleton {
        FloeSkeleton(style: .card(height: 200))
    }
    
    /// Create a skeleton for user avatar
    static func avatar(size: CGFloat = 40) -> FloeSkeleton {
        FloeSkeleton(style: .circle(size: size))
    }
    
    /// Create a skeleton for text content
    static func text(lines: Int = 3, lastLineWidth: CGFloat = 0.6) -> FloeSkeleton {
        FloeSkeleton(style: .text(lines: lines, lastLineWidth: lastLineWidth))
    }
    
    /// Create a skeleton for a list item
    static func listItem() -> FloeSkeleton {
        FloeSkeleton(style: .card(height: 80))
    }
    
    /// Create a skeleton for button
    static func button(width: CGFloat = 100, height: CGFloat = 40) -> FloeSkeleton {
        FloeSkeleton(
            style: .rectangle(width: width, height: height),
            cornerRadius: 20
        )
    }
}

// MARK: - Skeleton Loading View

public struct FloeSkeletonLoading: View {
    private let count: Int
    private let spacing: CGFloat
    private let skeletonBuilder: () -> FloeSkeleton
    
    public init(
        count: Int = 3,
        spacing: CGFloat = 16,
        @ViewBuilder skeleton: @escaping () -> FloeSkeleton = { FloeSkeleton.post() }
    ) {
        self.count = count
        self.spacing = spacing
        self.skeletonBuilder = skeleton
    }
    
    public var body: some View {
        VStack(spacing: spacing) {
            ForEach(0..<count, id: \.self) { index in
                skeletonBuilder()
                    .animation(.easeInOut.delay(Double(index) * 0.1), value: index)
            }
        }
    }
}

// MARK: - Previews

struct FloeSkeleton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Dark mode preview
            ScrollView {
                VStack(spacing: 24) {
                    PreviewContent()
                }
                .padding()
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
            
            // Light mode preview
            ScrollView {
                VStack(spacing: 24) {
                    PreviewContent()
                }
                .padding()
            }
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")
        }
    }
    
    struct PreviewContent: View {
        var body: some View {
            VStack(spacing: 24) {
                // Text skeletons
                VStack(alignment: .leading, spacing: 12) {
                    Text("Text Skeletons")
                        .font(.headline)
                    
                    FloeSkeleton.text(lines: 3)
                    FloeSkeleton.text(lines: 2, lastLineWidth: 0.4)
                }
                
                Divider()
                
                // Shape skeletons
                VStack(alignment: .leading, spacing: 12) {
                    Text("Shape Skeletons")
                        .font(.headline)
                    
                    HStack(spacing: 16) {
                        FloeSkeleton.avatar(size: 60)
                        FloeSkeleton.avatar(size: 40)
                        FloeSkeleton.avatar(size: 30)
                        
                        Spacer()
                        
                        FloeSkeleton.button(width: 80, height: 36)
                        FloeSkeleton.button(width: 60, height: 28)
                    }
                }
                
                Divider()
                
                // Card skeleton
                VStack(alignment: .leading, spacing: 12) {
                    Text("Post Skeleton")
                        .font(.headline)
                    
                    FloeSkeleton.post()
                }
                
                Divider()
                
                // Animation types
                VStack(alignment: .leading, spacing: 12) {
                    Text("Animation Types")
                        .font(.headline)
                    
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            VStack(spacing: 8) {
                                Text("Shimmer")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                                FloeSkeleton(
                                    style: .rectangle(width: 80, height: 40),
                                    animationType: .shimmer
                                )
                            }
                            .frame(maxWidth: .infinity)
                            
                            VStack(spacing: 8) {
                                Text("Pulse")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                                FloeSkeleton(
                                    style: .rectangle(width: 80, height: 40),
                                    animationType: .pulse
                                )
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        HStack(spacing: 16) {
                            VStack(spacing: 8) {
                                Text("Wave")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                                FloeSkeleton(
                                    style: .rectangle(width: 80, height: 40),
                                    animationType: .wave
                                )
                            }
                            .frame(maxWidth: .infinity)
                            
                            VStack(spacing: 8) {
                                Text("Static")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                                FloeSkeleton(
                                    style: .rectangle(width: 80, height: 40),
                                    animationType: .none
                                )
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                
                Divider()
                
                // Multiple skeletons
                VStack(alignment: .leading, spacing: 12) {
                    Text("Multiple Loading Items")
                        .font(.headline)
                    
                    FloeSkeletonLoading(count: 3) {
                        FloeSkeleton.listItem()
                    }
                }
            }
        }
    }
} 

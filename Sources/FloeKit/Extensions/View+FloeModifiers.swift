import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - FloeKit View Modifiers
public extension View {
    
    // MARK: - Corner Radius
    /// Applies FloeKit's standard corner radius
    /// - Parameter radius: The corner radius value. Defaults to FloeSpacing.cornerRadius
    /// - Returns: A view with rounded corners
    func floeCornerRadius(_ radius: CGFloat = FloeSpacing.cornerRadius) -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: radius))
    }
    
    // MARK: - Border
    /// Applies FloeKit's standard border styling
    /// - Parameters:
    ///   - color: The border color. Defaults to FloeColors.neutral20
    ///   - width: The border width. Defaults to 1
    ///   - cornerRadius: The corner radius. Defaults to FloeSpacing.cornerRadius
    /// - Returns: A view with a border
    func floeBorder(
        _ color: Color = FloeColors.neutral20,
        width: CGFloat = 1,
        cornerRadius: CGFloat = FloeSpacing.cornerRadius
    ) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(color, lineWidth: width)
        )
    }
    
    // MARK: - Background
    /// Applies FloeKit's standard background styling
    /// - Parameters:
    ///   - color: The background color. Defaults to FloeColors.surface
    ///   - cornerRadius: The corner radius. Defaults to FloeSpacing.cornerRadius
    /// - Returns: A view with a background
    func floeBackground(
        _ color: Color = FloeColors.surface,
        cornerRadius: CGFloat = FloeSpacing.cornerRadius
    ) -> some View {
        self.background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(color)
        )
    }
    
    // MARK: - Conditional Modifiers
    /// Conditionally applies a modifier
    /// - Parameters:
    ///   - condition: The condition to check
    ///   - modifier: The modifier to apply if condition is true
    /// - Returns: A view with the modifier applied conditionally
    @ViewBuilder
    func floeIf<Content: View>(_ condition: Bool, modifier: (Self) -> Content) -> some View {
        if condition {
            modifier(self)
        } else {
            self
        }
    }
    
    // MARK: - Loading State
    /// Applies a loading state overlay
    /// - Parameter isLoading: Whether the loading state should be shown
    /// - Returns: A view with an optional loading overlay
    func floeLoading(_ isLoading: Bool) -> some View {
        self.overlay(
            Group {
                if isLoading {
                    RoundedRectangle(cornerRadius: FloeSpacing.cornerRadius)
                        .fill(FloeColors.surface.opacity(0.8))
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: FloeColors.primary))
                        )
                }
            }
        )
    }
    
    // MARK: - Disabled State
    /// Applies FloeKit's standard disabled state styling
    /// - Parameter isDisabled: Whether the view should appear disabled
    /// - Returns: A view with disabled styling
    func floeDisabled(_ isDisabled: Bool) -> some View {
        self
            .opacity(isDisabled ? 0.6 : 1.0)
            .allowsHitTesting(!isDisabled)
    }
}

// MARK: - Animation Extensions
public extension View {
    /// Applies FloeKit's standard spring animation
    func floeSpringAnimation() -> some View {
        self.animation(.spring(response: 0.3, dampingFraction: 0.7), value: UUID())
    }
    
    /// Applies FloeKit's standard easing animation
    /// - Parameter duration: The animation duration. Defaults to 0.25
    func floeEaseAnimation(duration: Double = 0.25) -> some View {
        self.animation(.easeInOut(duration: duration), value: UUID())
    }
    
    // MARK: - Skeleton Loading
    /// Applies skeleton loading overlay to any view
    /// - Parameters:
    ///   - isLoading: Whether skeleton loading should be shown
    ///   - animationType: The type of skeleton animation
    ///   - cornerRadius: Corner radius for skeleton shapes
    ///   - backgroundColor: Background color for skeleton elements
    ///   - highlightColor: Highlight color for animations
    /// - Returns: A view with conditional skeleton loading overlay
    func floeSkeleton(
        _ isLoading: Bool,
        animationType: FloeSkeleton.AnimationType = .shimmer,
        cornerRadius: CGFloat = 8,
        backgroundColor: Color = FloeColors.neutral20,
        highlightColor: Color = FloeColors.neutral10
    ) -> some View {
        self.overlay(
            Group {
                if isLoading {
                    FloeSkeletonOverlay(
                        animationType: animationType,
                        cornerRadius: cornerRadius,
                        backgroundColor: backgroundColor,
                        highlightColor: highlightColor
                    )
                }
            }
        )
        .disabled(isLoading)
    }
    
    /// Applies skeleton loading with binding
    /// - Parameters:
    ///   - isLoading: Binding to loading state
    ///   - animationType: The type of skeleton animation
    ///   - cornerRadius: Corner radius for skeleton shapes
    ///   - backgroundColor: Background color for skeleton elements
    ///   - highlightColor: Highlight color for animations
    /// - Returns: A view with conditional skeleton loading overlay
    func floeSkeleton(
        _ isLoading: Binding<Bool>,
        animationType: FloeSkeleton.AnimationType = .shimmer,
        cornerRadius: CGFloat = 8,
        backgroundColor: Color = FloeColors.neutral20,
        highlightColor: Color = FloeColors.neutral10
    ) -> some View {
        self.floeSkeleton(
            isLoading.wrappedValue,
            animationType: animationType,
            cornerRadius: cornerRadius,
            backgroundColor: backgroundColor,
            highlightColor: highlightColor
        )
    }
}

// MARK: - Skeleton Overlay Component

private struct FloeSkeletonOverlay: View {
    let animationType: FloeSkeleton.AnimationType
    let cornerRadius: CGFloat
    let backgroundColor: Color
    let highlightColor: Color
    
    @State private var shimmerOffset: CGFloat = -1
    @State private var animationPhase: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(backgroundColor)
                .overlay(
                    Group {
                        switch animationType {
                        case .shimmer:
                            shimmerOverlay(in: geometry)
                        case .pulse:
                            pulseOverlay
                        case .wave:
                            waveOverlay
                        case .none:
                            EmptyView()
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func shimmerOverlay(in geometry: GeometryProxy) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius)
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
    }
    
    private var pulseOverlay: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(highlightColor)
            .opacity(0.3 + 0.3 * sin(animationPhase * .pi * 2))
    }
    
    private var waveOverlay: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
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
    
    private func startAnimation() {
        switch animationType {
        case .shimmer:
            withAnimation(
                .linear(duration: 1.5)
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

// MARK: - Text Skeleton Modifier

public extension View {
    /// Applies skeleton loading specifically designed for text content
    /// - Parameters:
    ///   - isLoading: Whether skeleton loading should be shown
    ///   - lines: Number of text lines to simulate
    ///   - lastLineWidth: Width of the last line as a fraction (0.0 - 1.0)
    ///   - animationType: The type of skeleton animation
    /// - Returns: A view with conditional text skeleton loading
    func floeTextSkeleton(
        _ isLoading: Bool,
        lines: Int = 1,
        lastLineWidth: CGFloat = 0.6,
        animationType: FloeSkeleton.AnimationType = .shimmer
    ) -> some View {
        self.overlay(
            Group {
                if isLoading {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(0..<lines, id: \.self) { index in
                            let isLastLine = index == lines - 1
                            let width = isLastLine ? lastLineWidth : 1.0
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(FloeColors.neutral20)
                                .frame(height: 16)
                                .frame(maxWidth: .infinity)
                                .scaleEffect(x: width, anchor: .leading)
                                .modifier(SkeletonAnimationModifier(
                                    animationType: animationType,
                                    backgroundColor: FloeColors.neutral20,
                                    highlightColor: FloeColors.neutral10,
                                    isAnimated: true
                                ))
                        }
                    }
                }
            }
        )
        .disabled(isLoading)
    }
    
    /// Applies skeleton loading specifically designed for text content with binding
    /// - Parameters:
    ///   - isLoading: Binding to loading state
    ///   - lines: Number of text lines to simulate
    ///   - lastLineWidth: Width of the last line as a fraction (0.0 - 1.0)
    ///   - animationType: The type of skeleton animation
    /// - Returns: A view with conditional text skeleton loading
    func floeTextSkeleton(
        _ isLoading: Binding<Bool>,
        lines: Int = 1,
        lastLineWidth: CGFloat = 0.6,
        animationType: FloeSkeleton.AnimationType = .shimmer
    ) -> some View {
        self.floeTextSkeleton(
            isLoading.wrappedValue,
            lines: lines,
            lastLineWidth: lastLineWidth,
            animationType: animationType
        )
    }
} 
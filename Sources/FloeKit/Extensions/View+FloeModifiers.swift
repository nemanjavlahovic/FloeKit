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
} 
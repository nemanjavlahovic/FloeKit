import SwiftUI

public struct FloeButton: View {
    public enum Size {
        case small, medium, large
        
        var padding: EdgeInsets {
            switch self {
            case .small: return FloeSpacing.ButtonPadding.small.edgeInsets
            case .medium: return FloeSpacing.ButtonPadding.medium.edgeInsets
            case .large: return FloeSpacing.ButtonPadding.large.edgeInsets
            }
        }
        
        var font: Font {
            switch self {
            case .small: return FloeFont.font(.caption)
            case .medium: return FloeFont.font(.button)
            case .large: return FloeFont.font(.headline)
            }
        }
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 16
            case .medium: return 20
            case .large: return 24
            }
        }
    }
    
    private let title: String
    private let action: () -> Void
    private let size: Size
    private let isEnabled: Bool
    private let backgroundColor: Color
    private let borderColor: Color?
    private let borderWidth: CGFloat
    private let textColor: Color
    private let cornerRadius: CGFloat
    private let icon: Image?
    private let isLoading: Bool
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var isPressed = false
    
    public init(_ title: String, 
                size: Size = .medium, 
                isEnabled: Bool = true,
                backgroundColor: Color = FloeColors.primary,
                borderColor: Color? = nil,
                borderWidth: CGFloat = 1.0,
                textColor: Color = Color.white,
                cornerRadius: CGFloat = 14,
                icon: Image? = nil,
                isLoading: Bool = false,
                action: @escaping () -> Void) {
        self.title = title
        self.size = size
        self.isEnabled = isEnabled
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.textColor = textColor
        self.cornerRadius = cornerRadius
        self.icon = icon
        self.isLoading = isLoading
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            if isEnabled && !isLoading { action() }
        }) {
            HStack(spacing: FloeSpacing.Size.sm.value) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: textColor))
                        .scaleEffect(0.8)
                } else if let icon = icon {
                    icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: size.iconSize, height: size.iconSize)
                }
                
                Text(title)
                    .font(size.font)
            }
            .foregroundColor(isEnabled ? textColor : FloeColors.neutral40)
            .padding(size.padding)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(backgroundColor)
                    .floeShadow(.medium)
            )
            .overlay(
                Group {
                    if let borderColor = borderColor {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(borderColor, lineWidth: borderWidth)
                    }
                }
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .opacity(isEnabled ? 1.0 : 0.6)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title))
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(isEnabled ? "Activates the button" : "Button is disabled")
        .accessibilityRespondsToUserInteraction(isEnabled)
        .highPriorityGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .disabled(!isEnabled || isLoading)
    }
}

// MARK: - Previews

struct FloeButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Dark mode preview (default)
            VStack(spacing: 20) {
                FloeButton("Default Button", 
                          size: .small, 
                          backgroundColor: FloeColors.primary, 
                          textColor: .white) {}
                
                FloeButton("With Icon", 
                          size: .medium,
                          backgroundColor: FloeColors.secondary,
                          textColor: .white,
                          icon: Image(systemName: "star.fill")) {}
                
                FloeButton("Loading State",
                          size: .large,
                          backgroundColor: FloeColors.surface,
                          borderColor: FloeColors.primary,
                          textColor: FloeColors.primary,
                          isLoading: true) {}
                
                FloeButton("Custom Style",
                          size: .medium,
                          backgroundColor: FloeColors.accent,
                          textColor: .white,
                          cornerRadius: 12,
                          icon: Image(systemName: "plus.circle.fill")) {}
            }
            .padding()
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
            
            // Light mode preview
            VStack(spacing: 20) {
                FloeButton("Default Button", 
                          size: .small, 
                          backgroundColor: FloeColors.primary, 
                          textColor: .white) {}
                
                FloeButton("With Icon", 
                          size: .medium,
                          backgroundColor: FloeColors.secondary,
                          textColor: .white,
                          icon: Image(systemName: "star.fill")) {}
                
                FloeButton("Loading State",
                          size: .large,
                          backgroundColor: FloeColors.surface,
                          borderColor: FloeColors.primary,
                          textColor: FloeColors.primary,
                          isLoading: true) {}
                
                FloeButton("Custom Style",
                          size: .medium,
                          backgroundColor: FloeColors.accent,
                          textColor: .white,
                          cornerRadius: 12,
                          icon: Image(systemName: "plus.circle.fill")) {}
            }
            .padding()
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")
        }
        .previewLayout(.sizeThatFits)
    }
} 

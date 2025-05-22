import SwiftUI

public struct FloeButton: View {
    public enum Size {
        case small, medium, large
        
        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
            case .medium: return EdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
            case .large: return EdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32)
            }
        }
        
        var font: Font {
            switch self {
            case .small: return .body
            case .medium: return .headline
            case .large: return .title3
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
                backgroundColor: Color = Color(.systemGray),
                borderColor: Color? = nil,
                borderWidth: CGFloat = 1.0,
                textColor: Color = .primary,
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
            HStack(spacing: 8) {
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
            .foregroundColor(isEnabled ? textColor : .gray)
            .padding(size.padding)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(backgroundColor)
                    .shadow(color: .black.opacity(colorScheme == .dark ? 0.2 : 0.08), radius: 10, x: 0, y: 4)
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
            VStack(spacing: 20) {
                FloeButton("Default Button", size: .small, backgroundColor: .blue) {}
                
                FloeButton("With Icon", 
                          size: .medium,
                          backgroundColor: .green,
                          borderColor: .black,
                          borderWidth: 2,
                          icon: Image(systemName: "star.fill")) {}
                
                FloeButton("Loading State",
                          size: .large,
                          backgroundColor: .purple,
                          textColor: .white,
                          isLoading: true) {}
                
                FloeButton("Custom Style",
                          size: .medium,
                          backgroundColor: .orange,
                          borderColor: .black,
                          textColor: .white,
                          cornerRadius: 8,
                          icon: Image(systemName: "plus.circle.fill")) {}
            }
            .padding()
            .previewDisplayName("Light Mode")
            .environment(\.colorScheme, .light)
            
            VStack(spacing: 20) {
                FloeButton("Default Button", size: .small, backgroundColor: .blue) {}
                
                FloeButton("With Icon", 
                          size: .medium,
                          backgroundColor: .green,
                          borderColor: .black,
                          borderWidth: 2,
                          icon: Image(systemName: "star.fill")) {}
                
                FloeButton("Loading State",
                          size: .large,
                          backgroundColor: .purple,
                          textColor: .white,
                          isLoading: true) {}
                
                FloeButton("Custom Style",
                          size: .medium,
                          backgroundColor: .orange,
                          borderColor: .black,
                          textColor: .white,
                          cornerRadius: 8,
                          icon: Image(systemName: "plus.circle.fill")) {}
            }
            .padding()
            .previewDisplayName("Dark Mode")
            .environment(\.colorScheme, .dark)
        }
        .previewLayout(.sizeThatFits)
    }
} 

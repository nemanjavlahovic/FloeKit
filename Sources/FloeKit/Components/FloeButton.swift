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
    }
    
    private let title: String
    private let action: () -> Void
    private let size: Size
    private let isEnabled: Bool
    private let backgroundColor: Color
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var isPressed = false
    
    public init(_ title: String, 
                size: Size = .medium, 
                isEnabled: Bool = true,
                backgroundColor: Color = Color(.systemGray),
                action: @escaping () -> Void) {
        self.title = title
        self.size = size
        self.isEnabled = isEnabled
        self.backgroundColor = backgroundColor
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            if isEnabled { action() }
        }) {
            Text(title)
                .font(size.font)
                .foregroundColor(isEnabled ? .primary : .gray)
                .padding(size.padding)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(backgroundColor)
                        .shadow(color: .black.opacity(colorScheme == .dark ? 0.2 : 0.08), radius: 10, x: 0, y: 4)
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
        .disabled(!isEnabled)
    }
}

// MARK: - Previews

struct FloeButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack(spacing: 20) {
                FloeButton("Small Enabled", size: .small, backgroundColor: .blue) {}
                FloeButton("Medium Enabled", size: .medium, backgroundColor: .green) {}
                FloeButton("Large Enabled", size: .large, backgroundColor: .purple) {}
                FloeButton("Small Disabled", size: .small, isEnabled: false, backgroundColor: .blue) {}
                FloeButton("Medium Disabled", size: .medium, isEnabled: false, backgroundColor: .green) {}
                FloeButton("Large Disabled", size: .large, isEnabled: false, backgroundColor: .purple) {}
            }
            .padding()
            .previewDisplayName("Light Mode")
            .environment(\.colorScheme, .light)
            
            VStack(spacing: 20) {
                FloeButton("Small Enabled", size: .small, backgroundColor: .blue) {}
                FloeButton("Medium Enabled", size: .medium, backgroundColor: .green) {}
                FloeButton("Large Enabled", size: .large, backgroundColor: .purple) {}
                FloeButton("Small Disabled", size: .small, isEnabled: false, backgroundColor: .blue) {}
                FloeButton("Medium Disabled", size: .medium, isEnabled: false, backgroundColor: .green) {}
                FloeButton("Large Disabled", size: .large, isEnabled: false, backgroundColor: .purple) {}
            }
            .padding()
            .previewDisplayName("Dark Mode")
            .environment(\.colorScheme, .dark)
        }
        .previewLayout(.sizeThatFits)
    }
} 

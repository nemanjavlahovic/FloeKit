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
    
    public enum Style {
        case primary
        case secondary
        case ghost
        case danger
        case success
        case floating
        
        func backgroundColor(isEnabled: Bool) -> Color {
            guard isEnabled else { return FloeColors.neutral90 }
            
            switch self {
            case .primary: return FloeColors.primary
            case .secondary: return FloeColors.secondary
            case .ghost: return Color.clear
            case .danger: return FloeColors.error
            case .success: return FloeColors.success
            case .floating: return FloeColors.accent
            }
        }
        
        func textColor(isEnabled: Bool) -> Color {
            guard isEnabled else { return FloeColors.neutral40 }
            
            switch self {
            case .primary, .secondary, .danger, .success, .floating: 
                return .white
            case .ghost: 
                return FloeColors.primary
            }
        }
        
        func borderColor(isEnabled: Bool) -> Color? {
            guard isEnabled else { return nil }
            
            switch self {
            case .ghost: return FloeColors.primary
            default: return nil
            }
        }
        
        var shadow: FloeShadow.Style {
            switch self {
            case .floating: return .elevated
            case .ghost: return .none
            default: return .medium
            }
        }
    }
    
    public enum HapticStyle {
        case light
        case medium
        case heavy
        case selection
        case none
        
        #if os(iOS)
        var feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle? {
            switch self {
            case .light: return .light
            case .medium: return .medium
            case .heavy: return .heavy
            case .selection, .none: return nil
            }
        }
        #endif
    }
    
    private let title: String
    private let action: () -> Void
    private let size: Size
    private let style: Style
    private let isEnabled: Bool
    private let customBackgroundColor: Color?
    private let customBorderColor: Color?
    private let borderWidth: CGFloat
    private let customTextColor: Color?
    private let cornerRadius: CGFloat
    private let icon: Image?
    private let isLoading: Bool
    private let hapticStyle: HapticStyle
    private let soundEffect: String?
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var isPressed = false
    
    public init(
        _ title: String,
        size: Size = .medium,
        style: Style = .primary,
        isEnabled: Bool = true,
        backgroundColor: Color? = nil,
        borderColor: Color? = nil,
        borderWidth: CGFloat = 1.0,
        textColor: Color? = nil,
        cornerRadius: CGFloat = 14,
        icon: Image? = nil,
        isLoading: Bool = false,
        hapticStyle: HapticStyle = .light,
        soundEffect: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.size = size
        self.style = style
        self.isEnabled = isEnabled
        self.customBackgroundColor = backgroundColor
        self.customBorderColor = borderColor
        self.borderWidth = borderWidth
        self.customTextColor = textColor
        self.cornerRadius = cornerRadius
        self.icon = icon
        self.isLoading = isLoading
        self.hapticStyle = hapticStyle
        self.soundEffect = soundEffect
        self.action = action
    }
    
    private var effectiveBackgroundColor: Color {
        customBackgroundColor ?? style.backgroundColor(isEnabled: isEnabled)
    }
    
    private var effectiveTextColor: Color {
        customTextColor ?? style.textColor(isEnabled: isEnabled)
    }
    
    private var effectiveBorderColor: Color? {
        customBorderColor ?? style.borderColor(isEnabled: isEnabled)
    }
    
    public var body: some View {
        Button(action: {
            if isEnabled && !isLoading {
                triggerHaptics()
                playSound()
                action()
            }
        }) {
            HStack(spacing: FloeSpacing.Size.sm.value) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: effectiveTextColor))
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
            .foregroundColor(effectiveTextColor)
            .padding(size.padding)
            .frame(maxWidth: style == .floating ? nil : .infinity)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(effectiveBackgroundColor)
                    .floeShadow(style.shadow)
            )
            .overlay(
                Group {
                    if let borderColor = effectiveBorderColor {
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
    
    private func triggerHaptics() {
        #if os(iOS)
        switch hapticStyle {
        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        case .light, .medium, .heavy:
            if let feedbackStyle = hapticStyle.feedbackStyle {
                let generator = UIImpactFeedbackGenerator(style: feedbackStyle)
                generator.impactOccurred()
            }
        case .none:
            break
        }
        #endif
    }
    
    private func playSound() {
        #if os(iOS)
        if let soundEffect = soundEffect {
            // This could be extended with AVFoundation for custom sounds
            // For now, we'll use system sounds
            if soundEffect == "tap" {
                UIDevice.current.playInputClick()
            }
        }
        #endif
    }
}

// MARK: - Button Group

public struct FloeButtonGroup<Content: View>: View {
    public enum Orientation {
        case horizontal
        case vertical
    }
    
    let spacing: CGFloat
    let orientation: Orientation
    let content: Content
    
    public init(
        spacing: CGFloat = FloeSpacing.Size.sm.value,
        orientation: Orientation = .horizontal,
        @ViewBuilder content: () -> Content
    ) {
        self.spacing = spacing
        self.orientation = orientation
        self.content = content()
    }
    
    public var body: some View {
        switch orientation {
        case .horizontal:
            HStack(spacing: spacing) {
                content
            }
        case .vertical:
            VStack(spacing: spacing) {
                content
            }
        }
    }
}

// MARK: - Convenience Initializers

extension FloeButton {
    public static func primary(
        _ title: String,
        icon: Image? = nil,
        size: Size = .medium,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) -> FloeButton {
        FloeButton(
            title,
            size: size,
            style: .primary,
            icon: icon,
            isLoading: isLoading,
            action: action
        )
    }
    
    public static func secondary(
        _ title: String,
        icon: Image? = nil,
        size: Size = .medium,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) -> FloeButton {
        FloeButton(
            title,
            size: size,
            style: .secondary,
            icon: icon,
            isLoading: isLoading,
            action: action
        )
    }
    
    public static func ghost(
        _ title: String,
        icon: Image? = nil,
        size: Size = .medium,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) -> FloeButton {
        FloeButton(
            title,
            size: size,
            style: .ghost,
            icon: icon,
            isLoading: isLoading,
            action: action
        )
    }
    
    public static func danger(
        _ title: String,
        icon: Image? = nil,
        size: Size = .medium,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) -> FloeButton {
        FloeButton(
            title,
            size: size,
            style: .danger,
            icon: icon,
            isLoading: isLoading,
            action: action
        )
    }
    
    public static func success(
        _ title: String,
        icon: Image? = nil,
        size: Size = .medium,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) -> FloeButton {
        FloeButton(
            title,
            size: size,
            style: .success,
            icon: icon,
            isLoading: isLoading,
            action: action
        )
    }
    
    public static func floating(
        _ title: String,
        icon: Image? = nil,
        size: Size = .medium,
        action: @escaping () -> Void
    ) -> FloeButton {
        FloeButton(
            title,
            size: size,
            style: .floating,
            icon: icon,
            action: action
        )
    }
}

// MARK: - Previews

struct FloeButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Dark mode preview (default)
            ScrollView {
                VStack(spacing: 20) {
                    Text("Button Styles")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    FloeButton.primary("Primary Button") {}
                    
                    FloeButton.secondary("Secondary Button") {}
                    
                    FloeButton.ghost("Ghost Button") {}
                    
                    FloeButton.danger("Danger Button") {}
                    
                    FloeButton.success("Success Button") {}
                    
                    HStack {
                        Spacer()
                        FloeButton.floating("Floating Action", icon: Image(systemName: "plus")) {}
                    }
                    
                    Divider()
                    
                    Text("Button Sizes")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    FloeButton("Small Button", size: .small) {}
                    FloeButton("Medium Button", size: .medium) {}
                    FloeButton("Large Button", size: .large) {}
                    
                    Divider()
                    
                    Text("Button States")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    FloeButton("Loading State", isLoading: true) {}
                    FloeButton("Disabled State", isEnabled: false) {}
                    
                    Divider()
                    
                    Text("Button Group")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    FloeButtonGroup {
                        FloeButton.ghost("Cancel") {}
                        FloeButton.primary("Save") {}
                    }
                    
                    FloeButtonGroup(orientation: .vertical) {
                        FloeButton.primary("Option 1") {}
                        FloeButton.secondary("Option 2") {}
                        FloeButton.ghost("Option 3") {}
                    }
                }
                .padding()
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
            
            // Light mode preview
            ScrollView {
                VStack(spacing: 20) {
                    Text("Button Styles")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    FloeButton.primary("Primary Button") {}
                    
                    FloeButton.secondary("Secondary Button") {}
                    
                    FloeButton.ghost("Ghost Button") {}
                    
                    FloeButton.danger("Danger Button") {}
                    
                    FloeButton.success("Success Button") {}
                    
                    HStack {
                        Spacer()
                        FloeButton.floating("Floating Action", icon: Image(systemName: "plus")) {}
                    }
                }
                .padding()
            }
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")
        }
        .previewLayout(.sizeThatFits)
    }
}
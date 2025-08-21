import SwiftUI

public struct FloeEmptyState: View {
    public enum Style {
        case standard
        case compact
        case large
        
        var iconSize: CGFloat {
            switch self {
            case .compact: return 48
            case .standard: return 64
            case .large: return 80
            }
        }
        
        var spacing: CGFloat {
            switch self {
            case .compact: return 12
            case .standard: return 16
            case .large: return 24
            }
        }
        
        var titleFont: FloeFont.Style {
            switch self {
            case .compact: return .headline
            case .standard, .large: return .title
            }
        }
    }
    
    private let icon: String?
    private let customIcon: Image?
    private let title: String
    private let message: String?
    private let action: AnyView?
    private let style: Style
    private let iconColor: Color
    private let animation: Bool
    
    @State private var animationTrigger = false
    
    public init(
        icon: String? = nil,
        title: String,
        message: String? = nil,
        style: Style = .standard,
        iconColor: Color = FloeColors.primary,
        animation: Bool = true
    ) {
        self.icon = icon
        self.customIcon = nil
        self.title = title
        self.message = message
        self.action = nil
        self.style = style
        self.iconColor = iconColor
        self.animation = animation
    }
    
    public init(
        customIcon: Image,
        title: String,
        message: String? = nil,
        style: Style = .standard,
        iconColor: Color = FloeColors.primary,
        animation: Bool = true
    ) {
        self.icon = nil
        self.customIcon = customIcon
        self.title = title
        self.message = message
        self.action = nil
        self.style = style
        self.iconColor = iconColor
        self.animation = animation
    }
    
    public init<Action: View>(
        icon: String? = nil,
        title: String,
        message: String? = nil,
        style: Style = .standard,
        iconColor: Color = FloeColors.primary,
        animation: Bool = true,
        @ViewBuilder action: () -> Action
    ) {
        self.icon = icon
        self.customIcon = nil
        self.title = title
        self.message = message
        self.action = AnyView(action())
        self.style = style
        self.iconColor = iconColor
        self.animation = animation
    }
    
    public init<Action: View>(
        customIcon: Image,
        title: String,
        message: String? = nil,
        style: Style = .standard,
        iconColor: Color = FloeColors.primary,
        animation: Bool = true,
        @ViewBuilder action: () -> Action
    ) {
        self.icon = nil
        self.customIcon = customIcon
        self.title = title
        self.message = message
        self.action = AnyView(action())
        self.style = style
        self.iconColor = iconColor
        self.animation = animation
    }
    
    public var body: some View {
        VStack(spacing: style.spacing) {
            // Icon
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: style.iconSize, weight: .light))
                    .foregroundColor(iconColor)
                    .scaleEffect(animationTrigger ? 1.0 : 0.8)
                    .opacity(animationTrigger ? 1.0 : 0.0)
                    .animation(
                        animation ? .spring(response: 0.6, dampingFraction: 0.6).delay(0.1) : nil,
                        value: animationTrigger
                    )
            } else if let customIcon = customIcon {
                customIcon
                    .resizable()
                    .scaledToFit()
                    .frame(width: style.iconSize, height: style.iconSize)
                    .foregroundColor(iconColor)
                    .scaleEffect(animationTrigger ? 1.0 : 0.8)
                    .opacity(animationTrigger ? 1.0 : 0.0)
                    .animation(
                        animation ? .spring(response: 0.6, dampingFraction: 0.6).delay(0.1) : nil,
                        value: animationTrigger
                    )
            }
            
            // Title
            Text(title)
                .font(FloeFont.font(style.titleFont))
                .foregroundColor(FloeColors.neutral10)
                .multilineTextAlignment(.center)
                .opacity(animationTrigger ? 1.0 : 0.0)
                .offset(y: animationTrigger ? 0 : 10)
                .animation(
                    animation ? .easeOut(duration: 0.4).delay(0.2) : nil,
                    value: animationTrigger
                )
            
            // Message
            if let message = message {
                Text(message)
                    .font(FloeFont.font(.body))
                    .foregroundColor(FloeColors.neutral40)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(animationTrigger ? 1.0 : 0.0)
                    .offset(y: animationTrigger ? 0 : 10)
                    .animation(
                        animation ? .easeOut(duration: 0.4).delay(0.3) : nil,
                        value: animationTrigger
                    )
            }
            
            // Action
            if let action = action {
                action
                    .padding(.top, style.spacing / 2)
                    .opacity(animationTrigger ? 1.0 : 0.0)
                    .offset(y: animationTrigger ? 0 : 10)
                    .animation(
                        animation ? .easeOut(duration: 0.4).delay(0.4) : nil,
                        value: animationTrigger
                    )
            }
        }
        .padding(FloeSpacing.PaddingStyle.section.edgeInsets)
        .frame(maxWidth: 400) // Constrain width for better readability
        .onAppear {
            if animation {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animationTrigger = true
                }
            } else {
                animationTrigger = true
            }
        }
    }
}

// MARK: - Preset States

extension FloeEmptyState {
    public static func noData(
        title: String = "No Data",
        message: String? = "There's nothing to show here yet.",
        action: AnyView? = nil
    ) -> FloeEmptyState {
        if let action = action {
            return FloeEmptyState(
                icon: "tray",
                title: title,
                message: message,
                iconColor: FloeColors.neutral40
            ) {
                action
            }
        } else {
            return FloeEmptyState(
                icon: "tray",
                title: title,
                message: message,
                iconColor: FloeColors.neutral40
            )
        }
    }
    
    public static func error(
        title: String = "Something went wrong",
        message: String? = "We couldn't load your content. Please try again.",
        retryAction: (() -> Void)? = nil
    ) -> FloeEmptyState {
        if let retryAction = retryAction {
            return FloeEmptyState(
                icon: "exclamationmark.triangle",
                title: title,
                message: message,
                iconColor: FloeColors.error
            ) {
                FloeButton.primary("Try Again", icon: Image(systemName: "arrow.clockwise")) {
                    retryAction()
                }
            }
        } else {
            return FloeEmptyState(
                icon: "exclamationmark.triangle",
                title: title,
                message: message,
                iconColor: FloeColors.error
            )
        }
    }
    
    public static func success(
        title: String,
        message: String? = nil,
        action: AnyView? = nil
    ) -> FloeEmptyState {
        if let action = action {
            return FloeEmptyState(
                icon: "checkmark.circle",
                title: title,
                message: message,
                iconColor: FloeColors.success
            ) {
                action
            }
        } else {
            return FloeEmptyState(
                icon: "checkmark.circle",
                title: title,
                message: message,
                iconColor: FloeColors.success
            )
        }
    }
    
    public static func search(
        title: String = "No Results",
        message: String? = "Try adjusting your search or filters.",
        clearAction: (() -> Void)? = nil
    ) -> FloeEmptyState {
        if let clearAction = clearAction {
            return FloeEmptyState(
                icon: "magnifyingglass",
                title: title,
                message: message,
                iconColor: FloeColors.neutral40
            ) {
                FloeButton.ghost("Clear Search") {
                    clearAction()
                }
            }
        } else {
            return FloeEmptyState(
                icon: "magnifyingglass",
                title: title,
                message: message,
                iconColor: FloeColors.neutral40
            )
        }
    }
    
    public static func loading(
        title: String = "Loading...",
        message: String? = nil
    ) -> FloeEmptyState {
        FloeEmptyState(
            title: title,
            message: message,
            animation: false
        ) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: FloeColors.primary))
                .scaleEffect(1.2)
        }
    }
}

// MARK: - Previews

struct FloeEmptyState_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Dark mode
            ScrollView {
                VStack(spacing: 40) {
                    FloeEmptyState(
                        icon: "sparkles",
                        title: "Your day awaits",
                        message: "No activities scheduled for today. Start by creating your first habit."
                    ) {
                        FloeButton.primary("Create First Habit") {}
                    }
                    
                    Divider()
                    
                    FloeEmptyState.noData()
                    
                    Divider()
                    
                    FloeEmptyState.error(retryAction: {})
                    
                    Divider()
                    
                    FloeEmptyState.success(
                        title: "All Done!",
                        message: "You've completed all your tasks for today.",
                        action: AnyView(FloeButton.success("View Summary") {})
                    )
                    
                    Divider()
                    
                    FloeEmptyState.search(clearAction: {})
                    
                    Divider()
                    
                    FloeEmptyState.loading(message: "Fetching your data...")
                    
                    Divider()
                    
                    // Compact style
                    FloeEmptyState(
                        icon: "heart",
                        title: "No Favorites",
                        message: "Items you favorite will appear here.",
                        style: .compact
                    )
                    
                    // Large style
                    FloeEmptyState(
                        icon: "star.fill",
                        title: "Welcome!",
                        message: "This is a large empty state with prominent visuals.",
                        style: .large,
                        iconColor: FloeColors.accent
                    ) {
                        FloeButtonGroup {
                            FloeButton.ghost("Learn More") {}
                            FloeButton.primary("Get Started") {}
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
                    FloeEmptyState(
                        icon: "sparkles",
                        title: "Your day awaits",
                        message: "No activities scheduled for today. Start by creating your first habit."
                    ) {
                        FloeButton.primary("Create First Habit") {}
                    }
                    
                    Divider()
                    
                    FloeEmptyState.noData()
                    
                    Divider()
                    
                    FloeEmptyState.error(retryAction: {})
                }
                .padding()
            }
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")
        }
    }
}
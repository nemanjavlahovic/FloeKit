import SwiftUI

public struct FloeToast: View {
    public enum Style {
        case success
        case warning
        case error
        case info
        case custom(backgroundColor: Color, foregroundColor: Color, icon: Image?)
        
        var backgroundColor: Color {
            switch self {
            case .success: return Color.floePreviewSecondary
            case .warning: return Color.floePreviewAccent
            case .error: return Color.floePreviewError
            case .info: return Color.floePreviewPrimary
            case .custom(let backgroundColor, _, _): return backgroundColor
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .success, .warning, .error, .info: return .white
            case .custom(_, let foregroundColor, _): return foregroundColor
            }
        }
        
        var icon: Image? {
            switch self {
            case .success: return Image(systemName: "checkmark.circle.fill")
            case .warning: return Image(systemName: "exclamationmark.triangle.fill")
            case .error: return Image(systemName: "xmark.circle.fill")
            case .info: return Image(systemName: "info.circle.fill")
            case .custom(_, _, let icon): return icon
            }
        }
    }
    
    public enum Position {
        case top
        case bottom
        
        var alignment: Alignment {
            switch self {
            case .top: return .top
            case .bottom: return .bottom
            }
        }
    }
    
    private let title: String
    private let message: String?
    private let style: Style
    private let position: Position
    private let duration: Double
    private let actionTitle: String?
    private let action: (() -> Void)?
    private let onDismiss: (() -> Void)?
    
    @State private var isVisible = false
    @State private var dragOffset: CGFloat = 0
    @Environment(\.colorScheme) private var colorScheme
    
    public init(_ title: String,
                message: String? = nil,
                style: Style = .info,
                position: Position = .top,
                duration: Double = 3.0,
                actionTitle: String? = nil,
                action: (() -> Void)? = nil,
                onDismiss: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.style = style
        self.position = position
        self.duration = duration
        self.actionTitle = actionTitle
        self.action = action
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        if isVisible {
            VStack {
                if position == .bottom {
                    Spacer()
                }
                
                toastContent
                    .offset(y: dragOffset)
                    .offset(y: position == .top ? -100 + (isVisible ? 100 : 0) : 100 - (isVisible ? 100 : 0))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isVisible)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if position == .top && value.translation.height < 0 {
                                    dragOffset = value.translation.height
                                } else if position == .bottom && value.translation.height > 0 {
                                    dragOffset = value.translation.height
                                }
                            }
                            .onEnded { value in
                                let threshold: CGFloat = 50
                                if (position == .top && value.translation.height < -threshold) ||
                                   (position == .bottom && value.translation.height > threshold) {
                                    dismiss()
                                } else {
                                    dragOffset = 0
                                }
                            }
                    )
                
                if position == .top {
                    Spacer()
                }
            }
            .onAppear {
                withAnimation {
                    isVisible = true
                }
                
                // Auto-dismiss after duration
                if duration > 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var toastContent: some View {
        HStack(spacing: FloeSpacing.Size.md.value) {
            // Icon
            if let icon = style.icon {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(style.foregroundColor)
            }
            
            // Content
            VStack(alignment: .leading, spacing: FloeSpacing.Size.xs.value) {
                Text(title)
                    .font(FloeFont.font(.button))
                    .foregroundColor(style.foregroundColor)
                
                if let message = message {
                    Text(message)
                        .font(FloeFont.font(.caption))
                        .foregroundColor(style.foregroundColor.opacity(0.9))
                }
            }
            
            Spacer()
            
            // Action button
            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle) {
                    action()
                    dismiss()
                }
                .font(FloeFont.font(.caption))
                .foregroundColor(style.foregroundColor)
                .padding(.horizontal, FloeSpacing.Size.sm.value)
                .padding(.vertical, FloeSpacing.Size.xs.value)
                .background(
                    Capsule()
                        .fill(style.foregroundColor.opacity(0.2))
                )
            }
            
            // Dismiss button
            Button(action: dismiss) {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundColor(style.foregroundColor.opacity(0.7))
            }
        }
        .floePadding(.comfortable)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(style.backgroundColor)
                .floeShadow(.elevated)
        )
        .floePadding(.horizontal, .lg)
    }
    
    private func dismiss() {
        withAnimation {
            isVisible = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss?()
        }
    }
}

// MARK: - Toast Manager

public class FloeToastManager: ObservableObject {
    @Published public var currentToast: FloeToast?
    
    public init() {}
    
    public func show(_ toast: FloeToast) {
        currentToast = toast
    }
    
    public func dismiss() {
        currentToast = nil
    }
}

// MARK: - View Extension

public extension View {
    func floeToast(_ toast: FloeToast?) -> some View {
        self.overlay(
            Group {
                if let toast = toast {
                    toast
                }
            }
        )
    }
}

// MARK: - Convenience Methods

public extension FloeToast {
    static func success(_ title: String, message: String? = nil, duration: Double = 3.0, onDismiss: (() -> Void)? = nil) -> FloeToast {
        FloeToast(title, message: message, style: .success, duration: duration, onDismiss: onDismiss)
    }
    
    static func warning(_ title: String, message: String? = nil, duration: Double = 3.0, onDismiss: (() -> Void)? = nil) -> FloeToast {
        FloeToast(title, message: message, style: .warning, duration: duration, onDismiss: onDismiss)
    }
    
    static func error(_ title: String, message: String? = nil, duration: Double = 5.0, onDismiss: (() -> Void)? = nil) -> FloeToast {
        FloeToast(title, message: message, style: .error, duration: duration, onDismiss: onDismiss)
    }
    
    static func info(_ title: String, message: String? = nil, duration: Double = 3.0, onDismiss: (() -> Void)? = nil) -> FloeToast {
        FloeToast(title, message: message, style: .info, duration: duration, onDismiss: onDismiss)
    }
}

// MARK: - Previews

struct FloeToast_Previews: PreviewProvider {
    
    // Individual preview components
    struct SuccessToastDemo: View {
        @State private var showToast = false
        
        var body: some View {
            VStack(spacing: 20) {
                Text("Background Content")
                    .foregroundColor(.gray)
                
                Button("Show Success Toast") {
                    showToast = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray.opacity(0.1))
            .floeToast(showToast ? FloeToast.success("Success!", message: "Operation completed successfully") {
                showToast = false
            } : nil)
        }
    }
    
    struct ToastManagerDemo: View {
        @StateObject private var toastManager = FloeToastManager()
        
        var body: some View {
            VStack(spacing: 16) {
                Text("Toast Manager Demo")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                HStack(spacing: 12) {
                    Button("Success") {
                        toastManager.show(FloeToast.success("Success!", message: "Everything worked perfectly"))
                    }
                    .buttonStyle(DemoButtonStyle(color: .green))
                    
                    Button("Error") {
                        toastManager.show(FloeToast.error("Error!", message: "Something went wrong"))
                    }
                    .buttonStyle(DemoButtonStyle(color: .red))
                }
                
                HStack(spacing: 12) {
                    Button("Warning") {
                        toastManager.show(FloeToast.warning("Warning!", message: "Please check your input"))
                    }
                    .buttonStyle(DemoButtonStyle(color: .orange))
                    
                    Button("Custom") {
                        toastManager.show(FloeToast("Custom Toast", 
                                                   message: "With action button", 
                                                   style: .custom(backgroundColor: .purple, 
                                                                 foregroundColor: .white, 
                                                                 icon: Image(systemName: "star.fill")),
                                                   actionTitle: "Action",
                                                   action: {
                            print("Action tapped")
                        }))
                    }
                    .buttonStyle(DemoButtonStyle(color: .purple))
                }
                
                Button("Bottom Toast") {
                    toastManager.show(FloeToast("Bottom Position", 
                                               message: "This appears at the bottom", 
                                               style: .info, 
                                               position: .bottom))
                }
                .buttonStyle(DemoButtonStyle(color: .blue))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray.opacity(0.05))
            .floeToast(toastManager.currentToast)
        }
    }
    
    // Helper button style for demos
    struct DemoButtonStyle: ButtonStyle {
        let color: Color
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(6)
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        }
    }
    
    static var previews: some View {
        Group {
            SuccessToastDemo()
                .previewDisplayName("Success Toast")
            
            ToastManagerDemo()
                .previewDisplayName("Toast Manager Demo")
        }
        .previewLayout(.sizeThatFits)
        .frame(width: 375, height: 600)
    }
} 
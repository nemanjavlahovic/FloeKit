import SwiftUI

public struct FloeProgressIndicator: View {
    public enum Style {
        case linear
        case circular
    }
    
    public enum Size {
        case small, medium, large
        
        var lineWidth: CGFloat {
            switch self {
            case .small: return 4
            case .medium: return 6
            case .large: return 8
            }
        }
        
        var circularSize: CGFloat {
            switch self {
            case .small: return 40
            case .medium: return 60
            case .large: return 80
            }
        }
        
        var font: Font {
            switch self {
            case .small: return FloeFont.font(.caption)
            case .medium: return FloeFont.font(.body)
            case .large: return FloeFont.font(.headline)
            }
        }
    }
    
    public enum ProgressState {
        case loading
        case success
        case error
        case determinate(Double)
        case indeterminate
        
        var isCompleted: Bool {
            switch self {
            case .success, .error: return true
            default: return false
            }
        }
        
        var progress: Double {
            switch self {
            case .determinate(let value): return min(max(value, 0), 1)
            case .success: return 1.0
            default: return 0.0
            }
        }
    }
    
    private let style: Style
    private let size: Size
    private let state: ProgressState
    private let primaryColor: Color
    private let backgroundColor: Color
    private let showPercentage: Bool
    private let centerContent: AnyView?
    private let cornerRadius: CGFloat
    private let enableHaptics: Bool
    private let onCompletion: (() -> Void)?
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var animationProgress: Double = 0.0
    @State private var rotationAngle: Double = 0.0
    @State private var hasTriggeredCompletion = false
    
    // MARK: - Initializers
    
    /// Initialize with determinate progress
    public init(
        progress: Double,
        style: Style = .linear,
        size: Size = .medium,
        primaryColor: Color = FloeColors.primary,
        backgroundColor: Color = FloeColors.neutral20,
        showPercentage: Bool = false,
        cornerRadius: CGFloat = 8,
        enableHaptics: Bool = true,
        onCompletion: (() -> Void)? = nil
    ) {
        self.style = style
        self.size = size
        self.state = .determinate(progress)
        self.primaryColor = primaryColor
        self.backgroundColor = backgroundColor
        self.showPercentage = showPercentage
        self.centerContent = nil
        self.cornerRadius = cornerRadius
        self.enableHaptics = enableHaptics
        self.onCompletion = onCompletion
    }
    
    /// Initialize with custom state
    public init(
        state: ProgressState,
        style: Style = .linear,
        size: Size = .medium,
        primaryColor: Color = FloeColors.primary,
        backgroundColor: Color = FloeColors.neutral20,
        showPercentage: Bool = false,
        centerContent: AnyView? = nil,
        cornerRadius: CGFloat = 8,
        enableHaptics: Bool = true,
        onCompletion: (() -> Void)? = nil
    ) {
        self.style = style
        self.size = size
        self.state = state
        self.primaryColor = primaryColor
        self.backgroundColor = backgroundColor
        self.showPercentage = showPercentage
        self.centerContent = centerContent
        self.cornerRadius = cornerRadius
        self.enableHaptics = enableHaptics
        self.onCompletion = onCompletion
    }
    
    public var body: some View {
        VStack(spacing: FloeSpacing.Size.sm.value) {
            progressView
            
            if showPercentage && !state.isCompleted {
                percentageLabel
            }
        }
        .onAppear {
            startAnimations()
        }
        .onChange(of: state.progress) { newValue in
            updateProgress(newValue)
        }
    }
    
    // MARK: - Progress Views
    
    @ViewBuilder
    private var progressView: some View {
        switch style {
        case .linear:
            linearProgressView
        case .circular:
            circularProgressView
        }
    }
    
    private var linearProgressView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(backgroundColor)
                    .floeShadow(.subtle)
                
                // Progress fill
                if case .indeterminate = state {
                    // Indeterminate shimmer animation
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(progressGradient)
                        .frame(width: geometry.size.width * 0.3)
                        .offset(x: (geometry.size.width * 0.7) * animationProgress)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animationProgress)
                } else if case .loading = state {
                    // Loading shimmer animation
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(progressGradient)
                        .frame(width: geometry.size.width * 0.3)
                        .offset(x: (geometry.size.width * 0.7) * animationProgress)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animationProgress)
                } else {
                    // Determinate progress
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(progressGradient)
                        .frame(width: geometry.size.width * animationProgress)
                        .animation(.easeInOut(duration: 0.3), value: animationProgress)
                }
                
                // State overlay
                if state.isCompleted {
                    stateIcon
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(height: size.lineWidth * 2)
    }
    
    private var circularProgressView: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(backgroundColor, lineWidth: size.lineWidth)
                .floeShadow(.subtle)
            
            // Progress circle
            if case .indeterminate = state {
                // Indeterminate spinning animation
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(progressGradient, style: StrokeStyle(lineWidth: size.lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(rotationAngle))
                    .animation(.linear(duration: 1.0).repeatForever(autoreverses: false), value: rotationAngle)
            } else if case .loading = state {
                // Loading spinning animation
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(progressGradient, style: StrokeStyle(lineWidth: size.lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(rotationAngle))
                    .animation(.linear(duration: 1.0).repeatForever(autoreverses: false), value: rotationAngle)
            } else {
                // Determinate progress
                Circle()
                    .trim(from: 0, to: animationProgress)
                    .stroke(progressGradient, style: StrokeStyle(lineWidth: size.lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: animationProgress)
            }
            
            // Center content
            centerContentView
        }
        .frame(width: size.circularSize, height: size.circularSize)
    }
    
    @ViewBuilder
    private var centerContentView: some View {
        if let centerContent = centerContent {
            centerContent
        } else if state.isCompleted {
            stateIcon
        } else if showPercentage {
            Text("\(Int(state.progress * 100))%")
                .font(size.font)
                .foregroundColor(primaryColor)
        }
    }
    
    @ViewBuilder
    private var stateIcon: some View {
        switch state {
        case .success:
            Image(systemName: "checkmark")
                .font(size.font)
                .foregroundColor(FloeColors.success)
                .transition(.scale.combined(with: .opacity))
        case .error:
            Image(systemName: "xmark")
                .font(size.font)
                .foregroundColor(FloeColors.error)
                .transition(.scale.combined(with: .opacity))
        default:
            EmptyView()
        }
    }
    
    private var percentageLabel: some View {
        Text("\(Int(state.progress * 100))%")
            .font(size.font)
            .foregroundColor(primaryColor)
            .floePadding(.horizontal, FloeSpacing.Size.sm)
    }
    
    // MARK: - Computed Properties
    
    private var progressGradient: LinearGradient {
        switch state {
        case .success:
            return LinearGradient(colors: [FloeColors.success], startPoint: .leading, endPoint: .trailing)
        case .error:
            return LinearGradient(colors: [FloeColors.error], startPoint: .leading, endPoint: .trailing)
        case .loading, .indeterminate:
            return LinearGradient(
                colors: [primaryColor.opacity(0.7), primaryColor, primaryColor.opacity(0.7)],
                startPoint: .leading,
                endPoint: .trailing
            )
        default:
            return LinearGradient(colors: [primaryColor], startPoint: .leading, endPoint: .trailing)
        }
    }
    
    // MARK: - Animation Methods
    
    private func startAnimations() {
        switch state {
        case .indeterminate, .loading:
            startIndeterminateAnimation()
        case .determinate(let progress):
            animationProgress = progress
        case .success, .error:
            animationProgress = 1.0
        }
    }
    
    private func startIndeterminateAnimation() {
        if style == .circular {
            // Circular spinning animation
            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        } else {
            // Linear shimmer animation
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                animationProgress = 1.0
            }
        }
    }
    
    private func updateProgress(_ newProgress: Double) {
        withAnimation(.easeInOut(duration: 0.3)) {
            animationProgress = newProgress
        }
        
        // Trigger completion callback and haptics
        if newProgress >= 1.0 && !hasTriggeredCompletion {
            hasTriggeredCompletion = true
            
            if enableHaptics {
                triggerHapticFeedback()
            }
            
            onCompletion?()
        }
    }
    
    private func triggerHapticFeedback() {
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        #endif
    }
}

// MARK: - Convenience Initializers

public extension FloeProgressIndicator {
    /// Create an indeterminate progress indicator
    static func indeterminate(
        style: Style = .circular,
        size: Size = .medium,
        color: Color = FloeColors.primary
    ) -> FloeProgressIndicator {
        return FloeProgressIndicator(
            state: .indeterminate,
            style: style,
            size: size,
            primaryColor: color
        )
    }
    
    /// Create a success state indicator
    static func success(
        style: Style = .circular,
        size: Size = .medium
    ) -> FloeProgressIndicator {
        return FloeProgressIndicator(
            state: .success,
            style: style,
            size: size
        )
    }
    
    /// Create an error state indicator
    static func error(
        style: Style = .circular,
        size: Size = .medium
    ) -> FloeProgressIndicator {
        return FloeProgressIndicator(
            state: .error,
            style: style,
            size: size
        )
    }
    
    /// Create a loading indicator
    static func loading(
        style: Style = .circular,
        size: Size = .medium,
        color: Color = FloeColors.primary
    ) -> FloeProgressIndicator {
        return FloeProgressIndicator(
            state: .loading,
            style: style,
            size: size,
            primaryColor: color
        )
    }
}

// MARK: - Previews

struct FloeProgressIndicator_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Dark mode preview (default)
            ScrollView {
                VStack(spacing: FloeSpacing.Size.lg.value) {
                    PreviewWrapper()
                }
                .floePadding(.spacious)
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
            
            // Light mode preview
            ScrollView {
                VStack(spacing: FloeSpacing.Size.lg.value) {
                    PreviewWrapper()
                }
                .floePadding(.spacious)
            }
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")
        }
        .previewLayout(.sizeThatFits)
    }
    
    struct PreviewWrapper: View {
        @State private var determinateProgress: Double = 0.3
        @State private var animatedProgress: Double = 0.0
        
        var body: some View {
            VStack(spacing: FloeSpacing.Size.xl.value) {
                // Linear Progress Indicators
                VStack(alignment: .leading, spacing: FloeSpacing.Size.md.value) {
                    Text("Linear Progress")
                        .floeFont(.headline)
                    
                    FloeProgressIndicator(
                        progress: determinateProgress,
                        style: .linear,
                        size: .small,
                        showPercentage: true
                    )
                    
                    FloeProgressIndicator(
                        progress: 0.7,
                        style: .linear,
                        size: .medium
                    )
                    
                    FloeProgressIndicator.indeterminate(
                        style: .linear,
                        size: .large,
                        color: FloeColors.secondary
                    )
                }
                
                // Circular Progress Indicators
                VStack(alignment: .leading, spacing: FloeSpacing.Size.md.value) {
                    Text("Circular Progress")
                        .floeFont(.headline)
                    
                    HStack(spacing: FloeSpacing.Size.lg.value) {
                        VStack(spacing: FloeSpacing.Size.xs.value) {
                            FloeProgressIndicator(
                                progress: 0.65,
                                style: .circular,
                                size: .small,
                                showPercentage: true
                            )
                            Text("Determinate")
                                .floeFont(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: FloeSpacing.Size.xs.value) {
                            FloeProgressIndicator.indeterminate(
                                style: .circular,
                                size: .medium,
                                color: FloeColors.primary
                            )
                            Text("Indeterminate")
                                .floeFont(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: FloeSpacing.Size.xs.value) {
                            FloeProgressIndicator.success(
                                style: .circular,
                                size: .large
                            )
                            Text("Success")
                                .floeFont(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // State Examples
                VStack(alignment: .leading, spacing: FloeSpacing.Size.md.value) {
                    Text("State Examples")
                        .floeFont(.headline)
                    
                    HStack(spacing: FloeSpacing.Size.lg.value) {
                        FloeProgressIndicator.loading(
                            style: .circular,
                            size: .medium
                        )
                        
                        FloeProgressIndicator.success(
                            style: .circular,
                            size: .medium
                        )
                        
                        FloeProgressIndicator.error(
                            style: .circular,
                            size: .medium
                        )
                    }
                }
                
                // Interactive Controls
                VStack(spacing: FloeSpacing.Size.md.value) {
                    Text("Interactive Demo")
                        .floeFont(.headline)
                    
                    HStack(spacing: FloeSpacing.Size.lg.value) {
                        VStack(spacing: FloeSpacing.Size.xs.value) {
                            FloeProgressIndicator(
                                progress: determinateProgress,
                                style: .circular,
                                size: .large,
                                showPercentage: true
                            )
                            Text("Slider Controlled")
                                .floeFont(.caption)
                                .foregroundColor(.secondary)
                        }

                    }
                    
                    Slider(value: $determinateProgress, in: 0...1)
                        .floePadding(.horizontal, FloeSpacing.Size.lg)
                }
            }
            .onAppear {
                // Start animated progress from 0
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    animatedProgress = 1.0
                }
            }
        }
    }
} 

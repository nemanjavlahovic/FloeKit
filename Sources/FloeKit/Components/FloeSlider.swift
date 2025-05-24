import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

public struct FloeSlider: View {
    public enum Size {
        case small, medium, large
        
        var trackHeight: CGFloat {
            switch self {
            case .small: return 6
            case .medium: return 8
            case .large: return 12
            }
        }
        
        var thumbSize: CGFloat {
            switch self {
            case .small: return 20
            case .medium: return 24
            case .large: return 28
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
    
    public enum Orientation {
        case horizontal, vertical
    }
    
    public enum LabelStyle: Equatable {
        case none
        case value
        case percentage
        case custom((Double) -> String)
        
        public static func == (lhs: LabelStyle, rhs: LabelStyle) -> Bool {
            switch (lhs, rhs) {
            case (.none, .none), (.value, .value), (.percentage, .percentage):
                return true
            case (.custom, .custom):
                // We can't compare closures directly, so we treat all custom formatters as equal
                return true
            default:
                return false
            }
        }
        
        func format(_ value: Double, range: ClosedRange<Double>) -> String {
            switch self {
            case .none:
                return ""
            case .value:
                if range.upperBound - range.lowerBound > 10 {
                    return String(Int(value.rounded()))
                } else {
                    return String(format: "%.1f", value)
                }
            case .percentage:
                let percent = (value - range.lowerBound) / (range.upperBound - range.lowerBound) * 100
                return String(format: "%.0f%%", percent)
            case .custom(let formatter):
                return formatter(value)
            }
        }
    }
    
    @Binding private var value: Double
    private let range: ClosedRange<Double>
    private let step: Double?
    private let size: Size
    private let orientation: Orientation
    private let showLabels: LabelStyle
    private let showMinMax: Bool
    private let trackColor: Color
    private let fillColor: Color
    private let thumbColor: Color
    private let thumbBorderColor: Color?
    private let thumbBorderWidth: CGFloat
    private let enableHaptics: Bool
    private let cornerRadius: CGFloat
    private let onEditingChanged: ((Bool) -> Void)?
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var isDragging = false
    @State private var lastHapticValue: Double = 0
    
    // MARK: - Initializers
    
    public init(
        value: Binding<Double>,
        in range: ClosedRange<Double> = 0...100,
        step: Double? = nil,
        size: Size = .medium,
        orientation: Orientation = .horizontal,
        showLabels: LabelStyle = .none,
        showMinMax: Bool = false,
        trackColor: Color = Color.floePreviewSurface,
        fillColor: Color = Color.floePreviewPrimary,
        thumbColor: Color = .white,
        thumbBorderColor: Color? = nil,
        thumbBorderWidth: CGFloat = 2,
        enableHaptics: Bool = true,
        cornerRadius: CGFloat? = nil,
        onEditingChanged: ((Bool) -> Void)? = nil
    ) {
        self._value = value
        self.range = range
        self.step = step
        self.size = size
        self.orientation = orientation
        self.showLabels = showLabels
        self.showMinMax = showMinMax
        self.trackColor = trackColor
        self.fillColor = fillColor
        self.thumbColor = thumbColor
        self.thumbBorderColor = thumbBorderColor
        self.thumbBorderWidth = thumbBorderWidth
        self.enableHaptics = enableHaptics
        self.cornerRadius = cornerRadius ?? (size.trackHeight / 2)
        self.onEditingChanged = onEditingChanged
    }
    
    public var body: some View {
        VStack(spacing: FloeSpacing.Size.sm.value) {
            if showLabels != .none {
                valueLabel
            }
            
            if orientation == .horizontal {
                horizontalSlider
            } else {
                verticalSlider
            }
            
            if showMinMax {
                minMaxLabels
            }
        }
        .onAppear {
            lastHapticValue = value
        }
    }
    
    // MARK: - Components
    
    private var valueLabel: some View {
        Text(showLabels.format(value, range: range))
            .font(size.font)
            .foregroundColor(Color.floePreviewPrimary)
            .fontWeight(.medium)
    }
    
    private var horizontalSlider: some View {
        GeometryReader { geometry in
            let trackWidth = geometry.size.width
            let thumbOffset = thumbPosition(in: trackWidth)
            
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(trackColor)
                    .frame(height: size.trackHeight)
                    .floeShadow(.subtle)
                
                // Fill track
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(fillColor)
                    .frame(width: thumbOffset + size.thumbSize / 2, height: size.trackHeight)
                
                // Thumb
                Circle()
                    .fill(thumbColor)
                    .frame(width: size.thumbSize, height: size.thumbSize)
                    .overlay(
                        Circle()
                            .strokeBorder(thumbBorderColor ?? fillColor, lineWidth: thumbBorderWidth)
                    )
                    .floeShadow(isDragging ? .elevated : .medium)
                    .scaleEffect(isDragging ? 1.1 : 1.0)
                    .offset(x: thumbOffset)
                    .animation(.easeInOut(duration: 0.15), value: isDragging)
            }
            .frame(height: max(size.thumbSize, size.trackHeight))
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { dragValue in
                        if !isDragging {
                            isDragging = true
                            onEditingChanged?(true)
                        }
                        
                        let newValue = valueFromPosition(dragValue.location.x, trackWidth: trackWidth)
                        updateValue(newValue)
                    }
                    .onEnded { _ in
                        isDragging = false
                        onEditingChanged?(false)
                        
                        if enableHaptics {
                            #if canImport(UIKit)
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            #endif
                        }
                    }
            )
        }
        .frame(height: max(size.thumbSize, size.trackHeight))
    }
    
    private var verticalSlider: some View {
        GeometryReader { geometry in
            let trackHeight = geometry.size.height
            let thumbOffset = trackHeight - thumbPosition(in: trackHeight) - size.thumbSize / 2
            
            ZStack(alignment: .bottom) {
                // Background track
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(trackColor)
                    .frame(width: size.trackHeight)
                    .floeShadow(.subtle)
                
                // Fill track
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(fillColor)
                    .frame(width: size.trackHeight, height: trackHeight - thumbOffset)
                
                // Thumb
                Circle()
                    .fill(thumbColor)
                    .frame(width: size.thumbSize, height: size.thumbSize)
                    .overlay(
                        Circle()
                            .strokeBorder(thumbBorderColor ?? fillColor, lineWidth: thumbBorderWidth)
                    )
                    .floeShadow(isDragging ? .elevated : .medium)
                    .scaleEffect(isDragging ? 1.1 : 1.0)
                    .offset(y: thumbOffset)
                    .animation(.easeInOut(duration: 0.15), value: isDragging)
            }
            .frame(width: max(size.thumbSize, size.trackHeight))
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { dragValue in
                        if !isDragging {
                            isDragging = true
                            onEditingChanged?(true)
                        }
                        
                        let newValue = valueFromPosition(trackHeight - dragValue.location.y, trackWidth: trackHeight)
                        updateValue(newValue)
                    }
                    .onEnded { _ in
                        isDragging = false
                        onEditingChanged?(false)
                        
                        if enableHaptics {
                            #if canImport(UIKit)
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            #endif
                        }
                    }
            )
        }
        .frame(width: max(size.thumbSize, size.trackHeight))
    }
    
    private var minMaxLabels: some View {
        HStack {
            Text(showLabels.format(range.lowerBound, range: range))
                .font(size.font)
                .foregroundColor(Color.floePreviewNeutral)
            
            Spacer()
            
            Text(showLabels.format(range.upperBound, range: range))
                .font(size.font)
                .foregroundColor(Color.floePreviewNeutral)
        }
    }
    
    // MARK: - Helper Methods
    
    private func thumbPosition(in trackWidth: CGFloat) -> CGFloat {
        let normalizedValue = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        let availableWidth = trackWidth - size.thumbSize
        return normalizedValue * availableWidth
    }
    
    private func valueFromPosition(_ position: CGFloat, trackWidth: CGFloat) -> Double {
        let availableWidth = trackWidth - size.thumbSize
        let normalizedPosition = max(0, min(position - size.thumbSize / 2, availableWidth)) / availableWidth
        let newValue = range.lowerBound + normalizedPosition * (range.upperBound - range.lowerBound)
        
        if let step = step {
            return (newValue / step).rounded() * step
        }
        
        return newValue
    }
    
    private func updateValue(_ newValue: Double) {
        let clampedValue = max(range.lowerBound, min(range.upperBound, newValue))
        
        // Haptic feedback for value changes
        if enableHaptics && abs(clampedValue - lastHapticValue) > (range.upperBound - range.lowerBound) * 0.1 {
            #if canImport(UIKit)
            let selectionFeedback = UISelectionFeedbackGenerator()
            selectionFeedback.selectionChanged()
            #endif
            lastHapticValue = clampedValue
        }
        
        value = clampedValue
    }
}

// MARK: - Convenience Initializers

public extension FloeSlider {
    /// Creates a percentage slider (0-100)
    static func percentage(
        value: Binding<Double>,
        size: Size = .medium,
        orientation: Orientation = .horizontal,
        showLabels: Bool = true,
        enableHaptics: Bool = true,
        onEditingChanged: ((Bool) -> Void)? = nil
    ) -> FloeSlider {
        FloeSlider(
            value: value,
            in: 0...100,
            size: size,
            orientation: orientation,
            showLabels: showLabels ? .percentage : .none,
            enableHaptics: enableHaptics,
            onEditingChanged: onEditingChanged
        )
    }
    
    /// Creates a volume-style slider (0-1) with custom styling
    static func volume(
        value: Binding<Double>,
        size: Size = .medium,
        orientation: Orientation = .horizontal,
        onEditingChanged: ((Bool) -> Void)? = nil
    ) -> FloeSlider {
        FloeSlider(
            value: value,
            in: 0...1,
            size: size,
            orientation: orientation,
            showLabels: .percentage,
            fillColor: Color.floePreviewSecondary,
            enableHaptics: true,
            onEditingChanged: onEditingChanged
        )
    }
}

// MARK: - Previews

struct FloeSlider_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            InteractiveSliderPreview()
                .previewDisplayName("Interactive - Light Mode")
                .environment(\.colorScheme, .light)
            
            InteractiveSliderPreview()
                .previewDisplayName("Interactive - Dark Mode")
                .environment(\.colorScheme, .dark)
        }
        .previewLayout(.sizeThatFits)
    }
}

// MARK: - Interactive Preview Container
private struct InteractiveSliderPreview: View {
    @State private var basicValue: Double = 50
    @State private var percentageValue: Double = 75
    @State private var stepValue: Double = 2.5
    @State private var verticalValue: Double = 30
    @State private var volumeValue: Double = 0.7
    @State private var customValue: Double = 80
    @State private var temperatureValue: Double = 22.5
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Basic Slider
                VStack(spacing: 8) {
                    HStack {
                        Text("Basic Slider")
                            .font(.headline)
                        Spacer()
                        Text("Value: \(Int(basicValue))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    FloeSlider(value: $basicValue, in: 0...100, showLabels: .value)
                }
                
                // Percentage Slider
                VStack(spacing: 8) {
                    HStack {
                        Text("Percentage Slider")
                            .font(.headline)
                        Spacer()
                        Text("\(Int(percentageValue))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    FloeSlider.percentage(value: $percentageValue, showLabels: true)
                }
                
                // Custom Range with Steps
                VStack(spacing: 8) {
                    HStack {
                        Text("Rating (0-5, step 0.5)")
                            .font(.headline)
                        Spacer()
                        Text("⭐ \(String(format: "%.1f", stepValue))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    FloeSlider(
                        value: $stepValue,
                        in: 0...5,
                        step: 0.5,
                        showLabels: .value,
                        showMinMax: true
                    )
                }
                
                // Temperature Slider
                VStack(spacing: 8) {
                    HStack {
                        Text("Temperature Control")
                            .font(.headline)
                        Spacer()
                        Text("\(String(format: "%.1f", temperatureValue))°C")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    FloeSlider(
                        value: $temperatureValue,
                        in: 16...30,
                        step: 0.5,
                        showLabels: .custom({ "\(String(format: "%.1f", $0))°C" }),
                        fillColor: temperatureColor,
                        thumbColor: temperatureColor
                    )
                }
                
                // Horizontal Layout with Vertical Slider and Volume
                HStack(spacing: 30) {
                    // Vertical Slider
                    VStack {
                        Text("Volume")
                            .font(.headline)
                        FloeSlider(
                            value: $verticalValue,
                            in: 0...100,
                            orientation: .vertical,
                            showLabels: .percentage,
                            fillColor: Color.floePreviewSecondary
                        )
                        .frame(height: 200)
                        Text("\(Int(verticalValue))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Volume Style
                    VStack {
                        Text("Brightness")
                            .font(.headline)
                        FloeSlider.volume(value: $volumeValue)
                        Text("\(Int(volumeValue * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Large Custom Styled Slider
                VStack(spacing: 8) {
                    HStack {
                        Text("Custom Styled (Large)")
                            .font(.headline)
                        Spacer()
                        Text("\(Int(customValue))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    FloeSlider(
                        value: $customValue,
                        in: 0...100,
                        size: .large,
                        showLabels: .percentage,
                        fillColor: Color.floePreviewAccent,
                        thumbColor: Color.floePreviewAccent,
                        thumbBorderColor: .white
                    )
                }
                
                // Animation Demo Button
                VStack(spacing: 12) {
                    Text("Animation Demo")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        Button("Random Values") {
                            withAnimation(.easeInOut(duration: 0.8)) {
                                basicValue = Double.random(in: 0...100)
                                percentageValue = Double.random(in: 0...100)
                                stepValue = Double.random(in: 0...5)
                                verticalValue = Double.random(in: 0...100)
                                volumeValue = Double.random(in: 0...1)
                                customValue = Double.random(in: 0...100)
                                temperatureValue = Double.random(in: 16...30)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Reset") {
                            withAnimation(.easeInOut(duration: 0.6)) {
                                basicValue = 50
                                percentageValue = 75
                                stepValue = 2.5
                                verticalValue = 30
                                volumeValue = 0.7
                                customValue = 80
                                temperatureValue = 22.5
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .padding()
        }
    }
    
    private var temperatureColor: Color {
        // Dynamic color based on temperature value
        let normalizedTemp = (temperatureValue - 16) / (30 - 16)
        if normalizedTemp < 0.3 {
            return .blue
        } else if normalizedTemp < 0.7 {
            return .green
        } else {
            return .red
        }
    }
} 
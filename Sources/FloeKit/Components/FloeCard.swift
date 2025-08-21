import SwiftUI

// MARK: - Swipe Action

public struct FloeSwipeAction {
    let icon: String
    let color: Color
    let action: () -> Void
    
    public init(icon: String, color: Color, action: @escaping () -> Void) {
        self.icon = icon
        self.color = color
        self.action = action
    }
}

// MARK: - FloeCard

public struct FloeCard<Content: View>: View {
    private let content: Content
    private let backgroundColor: Color
    private let cornerRadius: CGFloat
    private let shadowStyle: FloeShadow.Style
    private let borderColor: Color?
    private let borderWidth: CGFloat
    private let padding: EdgeInsets
    
    // Selection states
    private let isSelectable: Bool
    @Binding private var isSelected: Bool
    private let selectedBorderColor: Color
    private let selectedBackgroundColor: Color?
    
    // Interaction callbacks
    private let onTap: (() -> Void)?
    private let onLongPress: (() -> Void)?
    
    // Swipe actions
    private let leadingSwipeActions: [FloeSwipeAction]
    private let trailingSwipeActions: [FloeSwipeAction]
    
    @State private var swipeOffset: CGFloat = 0
    @State private var isPressed = false
    @GestureState private var dragOffset: CGFloat = 0
    
    public init(
        backgroundColor: Color = FloeColors.surface,
        cornerRadius: CGFloat = 16,
        shadowStyle: FloeShadow.Style = .medium,
        borderColor: Color? = nil,
        borderWidth: CGFloat = 1,
        padding: FloeSpacing.PaddingStyle = .card,
        isSelectable: Bool = false,
        isSelected: Binding<Bool> = .constant(false),
        selectedBorderColor: Color = FloeColors.primary,
        selectedBackgroundColor: Color? = nil,
        onTap: (() -> Void)? = nil,
        onLongPress: (() -> Void)? = nil,
        leadingSwipeActions: [FloeSwipeAction] = [],
        trailingSwipeActions: [FloeSwipeAction] = [],
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.shadowStyle = shadowStyle
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.padding = padding.edgeInsets
        self.isSelectable = isSelectable
        self._isSelected = isSelected
        self.selectedBorderColor = selectedBorderColor
        self.selectedBackgroundColor = selectedBackgroundColor
        self.onTap = onTap
        self.onLongPress = onLongPress
        self.leadingSwipeActions = leadingSwipeActions
        self.trailingSwipeActions = trailingSwipeActions
    }
    
    private var effectiveBackgroundColor: Color {
        if isSelectable && isSelected {
            return selectedBackgroundColor ?? backgroundColor.opacity(0.8)
        }
        return backgroundColor
    }
    
    private var effectiveBorderColor: Color? {
        if isSelectable && isSelected {
            return selectedBorderColor
        }
        return borderColor
    }
    
    private var effectiveBorderWidth: CGFloat {
        if isSelectable && isSelected {
            return 2
        }
        return borderWidth
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Swipe action backgrounds
                if !leadingSwipeActions.isEmpty || !trailingSwipeActions.isEmpty {
                    swipeActionBackground(geometry: geometry)
                }
                
                // Main card content
                cardContent
                    .offset(x: swipeOffset + dragOffset)
                    .gesture(swipeGesture(geometry: geometry))
            }
        }
        .frame(height: cardHeight())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: swipeOffset)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    private var cardContent: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(effectiveBackgroundColor)
                    .floeShadow(shadowStyle)
            )
            .overlay(
                Group {
                    if let borderColor = effectiveBorderColor {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(borderColor, lineWidth: effectiveBorderWidth)
                    }
                }
            )
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
            .onTapGesture {
                if isSelectable {
                    withAnimation(.spring(response: 0.3)) {
                        isSelected.toggle()
                    }
                }
                onTap?()
                triggerHaptics(.selection)
            }
            .onLongPressGesture(minimumDuration: 0.5, maximumDistance: .infinity, pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = pressing
                }
            }, perform: {
                onLongPress?()
                triggerHaptics(.medium)
            })
    }
    
    private func swipeActionBackground(geometry: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            // Leading actions
            if swipeOffset > 0 && !leadingSwipeActions.isEmpty {
                HStack(spacing: 0) {
                    ForEach(leadingSwipeActions.indices, id: \.self) { index in
                        actionButton(
                            action: leadingSwipeActions[index],
                            width: min(80, swipeOffset / CGFloat(leadingSwipeActions.count))
                        )
                    }
                }
            }
            
            Spacer()
            
            // Trailing actions
            if swipeOffset < 0 && !trailingSwipeActions.isEmpty {
                HStack(spacing: 0) {
                    ForEach(trailingSwipeActions.indices, id: \.self) { index in
                        actionButton(
                            action: trailingSwipeActions[index],
                            width: min(80, abs(swipeOffset) / CGFloat(trailingSwipeActions.count))
                        )
                    }
                }
            }
        }
    }
    
    private func actionButton(action: FloeSwipeAction, width: CGFloat) -> some View {
        Button(action: {
            withAnimation(.spring()) {
                swipeOffset = 0
            }
            action.action()
            triggerHaptics(.light)
        }) {
            Image(systemName: action.icon)
                .foregroundColor(.white)
                .frame(width: width, height: cardHeight())
                .background(action.color)
        }
    }
    
    private func swipeGesture(geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                if !leadingSwipeActions.isEmpty || !trailingSwipeActions.isEmpty {
                    state = value.translation.width
                }
            }
            .onEnded { value in
                let threshold: CGFloat = 80
                let dragAmount = value.translation.width
                
                if abs(dragAmount) > threshold {
                    if dragAmount > 0 && !leadingSwipeActions.isEmpty {
                        // Open leading actions
                        swipeOffset = CGFloat(leadingSwipeActions.count) * 80
                    } else if dragAmount < 0 && !trailingSwipeActions.isEmpty {
                        // Open trailing actions
                        swipeOffset = -CGFloat(trailingSwipeActions.count) * 80
                    } else {
                        swipeOffset = 0
                    }
                } else {
                    swipeOffset = 0
                }
            }
    }
    
    private func cardHeight() -> CGFloat {
        // Calculate based on content
        return 100 // This is a default, actual height will be determined by content
    }
    
    private func triggerHaptics(_ style: HapticStyle) {
        #if os(iOS)
        switch style {
        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        case .medium:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        default:
            break
        }
        #endif
    }
    
    private enum HapticStyle {
        case selection, light, medium
    }
}

// MARK: - Convenience Modifiers

extension View {
    public func floeCard(
        backgroundColor: Color = FloeColors.surface,
        cornerRadius: CGFloat = 16,
        shadowStyle: FloeShadow.Style = .medium,
        padding: FloeSpacing.PaddingStyle = .card
    ) -> some View {
        FloeCard(
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius,
            shadowStyle: shadowStyle,
            padding: padding
        ) {
            self
        }
    }
    
    public func floeSwipeActions(
        edge: HorizontalEdge,
        @ArrayBuilder<FloeSwipeAction> actions: () -> [FloeSwipeAction]
    ) -> some View {
        // This would need to be implemented with a preference key
        // to pass swipe actions up to the parent FloeCard
        self
    }
}

// MARK: - Array Builder

@resultBuilder
public struct ArrayBuilder<Element> {
    public static func buildBlock(_ components: Element...) -> [Element] {
        components
    }
}

// MARK: - Previews

struct FloeCard_Previews: PreviewProvider {
    struct InteractivePreview: View {
        @State private var isSelected1 = false
        @State private var isSelected2 = false
        @State private var taskCompleted = false
        
        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Basic Cards")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    FloeCard {
                        Text("Simple Card")
                            .font(.headline)
                    }
                    
                    FloeCard(
                        backgroundColor: FloeColors.primary.opacity(0.1),
                        cornerRadius: 20,
                        shadowStyle: .elevated,
                        borderColor: FloeColors.primary
                    ) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Custom Styled Card")
                                .font(.headline)
                            Text("With custom background, border, and shadow")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    Text("Selectable Cards")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    FloeCard(
                        isSelectable: true,
                        isSelected: $isSelected1
                    ) {
                        HStack {
                            Image(systemName: isSelected1 ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(isSelected1 ? FloeColors.primary : .secondary)
                            Text("Tap to select this card")
                            Spacer()
                        }
                    }
                    
                    FloeCard(
                        isSelectable: true,
                        isSelected: $isSelected2,
                        selectedBorderColor: FloeColors.success,
                        selectedBackgroundColor: FloeColors.success.opacity(0.1)
                    ) {
                        HStack {
                            Image(systemName: isSelected2 ? "star.fill" : "star")
                                .foregroundColor(isSelected2 ? FloeColors.success : .secondary)
                            Text("Another selectable card")
                            Spacer()
                        }
                    }
                    
                    Divider()
                    
                    Text("Interactive Cards")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    FloeCard(
                        onTap: {
                            print("Card tapped!")
                        },
                        onLongPress: {
                            print("Card long pressed!")
                        }
                    ) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Interactive Card")
                                .font(.headline)
                            Text("Tap or long press for actions")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    FloeCard(
                        leadingSwipeActions: [
                            FloeSwipeAction(icon: "checkmark", color: .green) {
                                taskCompleted.toggle()
                            }
                        ],
                        trailingSwipeActions: [
                            FloeSwipeAction(icon: "trash", color: .red) {
                                print("Delete")
                            },
                            FloeSwipeAction(icon: "pencil", color: .blue) {
                                print("Edit")
                            }
                        ]
                    ) {
                        HStack {
                            Image(systemName: taskCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(taskCompleted ? .green : .secondary)
                            VStack(alignment: .leading) {
                                Text("Swipeable Task Card")
                                    .font(.headline)
                                    .strikethrough(taskCompleted)
                                Text("Swipe left or right for actions")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    static var previews: some View {
        Group {
            // Dark mode preview
            InteractivePreview()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode - Interactive")
            
            // Light mode preview
            InteractivePreview()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode - Interactive")
        }
    }
}
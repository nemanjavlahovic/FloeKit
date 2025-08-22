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

#Preview("Basic Cards") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        FloeCard {
            VStack(alignment: .leading, spacing: FloeSpacing.Size.sm.value) {
                Text("Simple Card")
                    .font(.headline)
                Text("This is a basic card with some content inside.")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        
        FloeCard {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                VStack(alignment: .leading) {
                    Text("Card with Icon")
                        .font(.headline)
                    Text("Icon and text layout")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
        }
    }
    .padding()
}

#Preview("Card Styles") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        FloeCard(backgroundColor: .blue.opacity(0.1), shadowStyle: .soft) {
            Text("Soft Shadow Card")
                .font(.headline)
                .foregroundColor(.blue)
        }
        
        FloeCard(backgroundColor: .green.opacity(0.1), shadowStyle: .elevated) {
            Text("Elevated Card")
                .font(.headline)
                .foregroundColor(.green)
        }
        
        FloeCard(backgroundColor: .purple.opacity(0.1), cornerRadius: 24, shadowStyle: .none) {
            Text("Rounded Card")
                .font(.headline)
                .foregroundColor(.purple)
        }
    }
    .padding()
}

#Preview("Cards with Borders") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        FloeCard(borderColor: .blue, borderWidth: 2) {
            Text("Blue Border Card")
                .font(.headline)
                .foregroundColor(.blue)
        }
        
        FloeCard(borderColor: .red, borderWidth: 1) {
            Text("Red Border Card")
                .font(.headline)
                .foregroundColor(.red)
        }
        
        FloeCard(backgroundColor: .yellow.opacity(0.1), borderColor: .orange, borderWidth: 3) {
            Text("Thick Border Card")
                .font(.headline)
                .foregroundColor(.orange)
        }
    }
    .padding()
}

#Preview("Selectable Cards") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        FloeCard(isSelectable: true, isSelected: .constant(false)) {
            VStack(alignment: .leading) {
                Text("Tap to Select")
                    .font(.headline)
                Text("This card can be selected")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        
        FloeCard(isSelectable: true, isSelected: .constant(true)) {
            VStack(alignment: .leading) {
                Text("Selected Card")
                    .font(.headline)
                Text("This card is currently selected")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }
    .padding()
}

#Preview("Interactive Cards") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        FloeCard(onTap: { print("Card tapped") }) {
            VStack(alignment: .leading) {
                Text("Tap Me")
                    .font(.headline)
                Text("This card responds to taps")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        
        FloeCard(onLongPress: { print("Card long pressed") }) {
            VStack(alignment: .leading) {
                Text("Long Press Me")
                    .font(.headline)
                Text("This card responds to long press")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        
        FloeCard(
            onTap: { print("Tapped") },
            onLongPress: { print("Long pressed") }
        ) {
            VStack(alignment: .leading) {
                Text("Tap or Long Press")
                    .font(.headline)
                Text("This card responds to both gestures")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }
    .padding()
}

#Preview("Cards with Swipe Actions") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        FloeCard(
            leadingSwipeActions: [
                FloeSwipeAction(icon: "heart.fill", color: .green) { print("Like") },
                FloeSwipeAction(icon: "bookmark.fill", color: .blue) { print("Save") }
            ]
        ) {
            VStack(alignment: .leading) {
                Text("Swipe Right")
                    .font(.headline)
                Text("Swipe to reveal like and save actions")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        
        FloeCard(
            trailingSwipeActions: [
                FloeSwipeAction(icon: "square.and.arrow.up", color: .blue) { print("Share") },
                FloeSwipeAction(icon: "trash.fill", color: .red) { print("Delete") }
            ]
        ) {
            VStack(alignment: .leading) {
                Text("Swipe Left")
                    .font(.headline)
                Text("Swipe to reveal share and delete actions")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        
        FloeCard(
            leadingSwipeActions: [
                FloeSwipeAction(icon: "checkmark", color: .green) { print("Complete") }
            ],
            trailingSwipeActions: [
                FloeSwipeAction(icon: "trash", color: .red) { print("Delete") }
            ]
        ) {
            VStack(alignment: .leading) {
                Text("Swipe Both Ways")
                    .font(.headline)
                Text("Swipe left or right for different actions")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }
    .padding()
}

#Preview("Content Cards") {
    ScrollView {
        VStack(spacing: FloeSpacing.Size.md.value) {
            // Profile Card
            FloeCard {
                HStack(spacing: FloeSpacing.Size.md.value) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text("JD")
                                .foregroundColor(.white)
                                .font(.headline)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("John Doe")
                            .font(.headline)
                        Text("iOS Developer")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("San Francisco, CA")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Follow") {
                        print("Follow tapped")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            
            // Article Card
            FloeCard {
                VStack(alignment: .leading, spacing: FloeSpacing.Size.sm.value) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 120)
                        .cornerRadius(8)
                    
                    Text("How to Build Great SwiftUI Apps")
                        .font(.headline)
                    
                    Text("Learn the best practices for creating beautiful and performant SwiftUI applications...")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Text("5 min read")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        HStack(spacing: 16) {
                            Button(action: {}) {
                                Image(systemName: "heart")
                                    .foregroundColor(.red)
                            }
                            
                            Button(action: {}) {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            
            // Product Card
            FloeCard {
                VStack(alignment: .leading, spacing: FloeSpacing.Size.sm.value) {
                    Rectangle()
                        .fill(Color.orange.opacity(0.3))
                        .frame(height: 100)
                        .cornerRadius(8)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("iPhone 15 Pro")
                                .font(.headline)
                            Text("From $999")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        Button("Buy Now") {
                            print("Buy now tapped")
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
    }
}

#Preview("Card Modifier") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        Text("Using Card Modifier")
            .font(.headline)
            .floeCard()
        
        HStack {
            Text("Custom Style")
                .font(.body)
            Spacer()
            Image(systemName: "arrow.right")
        }
        .floeCard(backgroundColor: .blue.opacity(0.1), cornerRadius: 12)
        
        VStack(alignment: .leading) {
            Text("No Shadow Card")
                .font(.headline)
            Text("This card has no shadow")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .floeCard(shadowStyle: .none)
    }
    .padding()
}

#Preview("Dark Mode") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        FloeCard {
            VStack(alignment: .leading) {
                Text("Dark Mode Card")
                    .font(.headline)
                Text("This card adapts to dark mode")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        
        FloeCard(isSelectable: true, isSelected: .constant(true)) {
            VStack(alignment: .leading) {
                Text("Selected in Dark Mode")
                    .font(.headline)
                Text("Selection styling in dark mode")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        
        FloeCard(borderColor: .blue, borderWidth: 2) {
            Text("Bordered Card")
                .font(.headline)
                .foregroundColor(.blue)
        }
    }
    .padding()
    .preferredColorScheme(.dark)
}


import SwiftUI

public struct FloeChip: View {
    public enum Style {
        case filled
        case outlined
        case ghost
    }
    
    private let title: String
    private let style: Style
    private let color: Color
    private let isSelected: Bool
    private let isDismissible: Bool
    private let icon: Image?
    private let action: (() -> Void)?
    private let onDismiss: (() -> Void)?
    
    public init(
        _ title: String,
        style: Style = .filled,
        color: Color = FloeColors.primary,
        isSelected: Bool = false,
        isDismissible: Bool = false,
        icon: Image? = nil,
        action: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.title = title
        self.style = style
        self.color = color
        self.isSelected = isSelected
        self.isDismissible = isDismissible
        self.icon = icon
        self.action = action
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        HStack(spacing: 6) {
            if let icon = icon {
                icon
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(textColor)
            }
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(textColor)
            
            if isDismissible, let onDismiss = onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(textColor.opacity(0.7))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor, lineWidth: borderWidth)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture {
            action?()
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .filled:
            return isSelected ? color : color.opacity(0.1)
        case .outlined:
            return isSelected ? color.opacity(0.1) : Color.clear
        case .ghost:
            return isSelected ? color.opacity(0.1) : Color.clear
        }
    }
    
    private var textColor: Color {
        switch style {
        case .filled:
            return isSelected ? .white : color
        case .outlined, .ghost:
            return color
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .filled:
            return Color.clear
        case .outlined:
            return color
        case .ghost:
            return Color.clear
        }
    }
    
    private var borderWidth: CGFloat {
        style == .outlined ? 1 : 0
    }
}

public extension FloeChip {
    static func tag(_ title: String, color: Color = FloeColors.primary) -> FloeChip {
        FloeChip(title, style: .filled, color: color)
    }
    
    static func filter(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> FloeChip {
        FloeChip(title, style: .outlined, isSelected: isSelected, action: action)
    }
}
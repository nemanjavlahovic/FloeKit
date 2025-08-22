import SwiftUI

public struct FloeDivider: View {
    public enum Style {
        case horizontal
        case vertical
    }
    
    private let style: Style
    private let color: Color
    private let thickness: CGFloat
    private let padding: CGFloat
    
    public init(
        style: Style = .horizontal,
        color: Color = FloeColors.neutral20,
        thickness: CGFloat = 1,
        padding: CGFloat = 0
    ) {
        self.style = style
        self.color = color
        self.thickness = thickness
        self.padding = padding
    }
    
    public var body: some View {
        switch style {
        case .horizontal:
            Rectangle()
                .fill(color)
                .frame(height: thickness)
                .padding(.horizontal, padding)
        case .vertical:
            Rectangle()
                .fill(color)
                .frame(width: thickness)
                .padding(.vertical, padding)
        }
    }
}

public extension FloeDivider {
    static var horizontal: FloeDivider {
        FloeDivider(style: .horizontal)
    }
    
    static var vertical: FloeDivider {
        FloeDivider(style: .vertical)
    }
}
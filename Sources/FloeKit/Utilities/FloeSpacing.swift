import SwiftUI

public struct FloeSpacing {
    // MARK: - Spacing Values
    public enum Size: CGFloat, CaseIterable {
        case xs = 4      // Extra small
        case sm = 8      // Small
        case md = 12     // Medium
        case lg = 16     // Large
        case xl = 20     // Extra large
        case xl2 = 24    // 2X Large
        case xl3 = 32    // 3X Large
        case xl4 = 40    // 4X Large
        case xl5 = 48    // 5X Large
        case xl6 = 64    // 6X Large
        
        public var value: CGFloat {
            return self.rawValue
        }
    }
    
    // MARK: - Common Padding Presets
    public enum PaddingStyle {
        case none
        case compact     // xs all around
        case cozy        // sm all around
        case comfortable // md all around
        case spacious    // lg all around
        case generous    // xl all around
        case card        // lg all around
        case section     // lg all around
        case custom(EdgeInsets)
        
        var edgeInsets: EdgeInsets {
            switch self {
            case .none:
                return EdgeInsets()
            case .compact:
                return EdgeInsets(top: Size.xs.value, leading: Size.xs.value, bottom: Size.xs.value, trailing: Size.xs.value)
            case .cozy:
                return EdgeInsets(top: Size.sm.value, leading: Size.sm.value, bottom: Size.sm.value, trailing: Size.sm.value)
            case .comfortable:
                return EdgeInsets(top: Size.md.value, leading: Size.md.value, bottom: Size.md.value, trailing: Size.md.value)
            case .spacious:
                return EdgeInsets(top: Size.lg.value, leading: Size.lg.value, bottom: Size.lg.value, trailing: Size.lg.value)
            case .generous:
                return EdgeInsets(top: Size.xl.value, leading: Size.xl.value, bottom: Size.xl.value, trailing: Size.xl.value)
            case .card:
                return EdgeInsets(top: Size.lg.value, leading: Size.lg.value, bottom: Size.lg.value, trailing: Size.lg.value)
            case .section:
                return EdgeInsets(top: Size.lg.value, leading: Size.lg.value, bottom: Size.lg.value, trailing: Size.lg.value)
            case .custom(let insets):
                return insets
            }
        }
    }
    
    // MARK: - Button-specific Padding
    public enum ButtonPadding {
        case small
        case medium
        case large
        
        var edgeInsets: EdgeInsets {
            switch self {
            case .small:
                return EdgeInsets(top: Size.sm.value, leading: Size.lg.value, bottom: Size.sm.value, trailing: Size.lg.value)
            case .medium:
                return EdgeInsets(top: Size.md.value, leading: Size.xl2.value, bottom: Size.md.value, trailing: Size.xl2.value)
            case .large:
                return EdgeInsets(top: Size.lg.value, leading: Size.xl3.value, bottom: Size.lg.value, trailing: Size.xl3.value)
            }
        }
    }
    
    // MARK: - TextField-specific Padding
    public enum TextFieldPadding {
        case small
        case medium
        case large
        
        var edgeInsets: EdgeInsets {
            switch self {
            case .small:
                return EdgeInsets(top: Size.sm.value, leading: Size.md.value, bottom: Size.sm.value, trailing: Size.md.value)
            case .medium:
                return EdgeInsets(top: Size.md.value, leading: Size.lg.value, bottom: Size.md.value, trailing: Size.lg.value)
            case .large:
                return EdgeInsets(top: Size.lg.value, leading: Size.xl.value, bottom: Size.lg.value, trailing: Size.xl.value)
            }
        }
    }
}

// MARK: - View Extensions
public extension View {
    func floePadding(_ style: FloeSpacing.PaddingStyle) -> some View {
        self.padding(style.edgeInsets)
    }
    
    func floePadding(_ size: FloeSpacing.Size) -> some View {
        self.padding(size.value)
    }
    
    func floePadding(_ edges: Edge.Set = .all, _ size: FloeSpacing.Size) -> some View {
        self.padding(edges, size.value)
    }
} 
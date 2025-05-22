import SwiftUI

public struct FloeShadow {
    // MARK: - Shadow Styles
    public enum Style {
        case none
        case subtle
        case soft
        case medium
        case elevated
        
        var radius: CGFloat {
            switch self {
            case .none: return 0
            case .subtle: return 4
            case .soft: return 8
            case .medium: return 12
            case .elevated: return 20
            }
        }
        
        var yOffset: CGFloat {
            switch self {
            case .none: return 0
            case .subtle: return 1
            case .soft: return 2
            case .medium: return 4
            case .elevated: return 8
            }
        }
        
        var lightOpacity: Double {
            switch self {
            case .none: return 0
            case .subtle: return 0.04
            case .soft: return 0.06
            case .medium: return 0.08
            case .elevated: return 0.12
            }
        }
        
        var darkOpacity: Double {
            switch self {
            case .none: return 0
            case .subtle: return 0.12
            case .soft: return 0.16
            case .medium: return 0.20
            case .elevated: return 0.28
            }
        }
    }
    
    // MARK: - Public Methods
    public static func shadow(_ style: Style, colorScheme: ColorScheme = .light) -> some View {
        EmptyView()
            .shadow(
                color: .black.opacity(colorScheme == .dark ? style.darkOpacity : style.lightOpacity),
                radius: style.radius,
                x: 0,
                y: style.yOffset
            )
    }
}

// MARK: - View Extension
public extension View {
    func floeShadow(_ style: FloeShadow.Style, colorScheme: ColorScheme = .light) -> some View {
        self.shadow(
            color: .black.opacity(colorScheme == .dark ? style.darkOpacity : style.lightOpacity),
            radius: style.radius,
            x: 0,
            y: style.yOffset
        )
    }
    
    func floeShadow(_ style: FloeShadow.Style) -> some View {
        self.modifier(AdaptiveShadowModifier(style: style))
    }
}

// MARK: - Adaptive Shadow Modifier
private struct AdaptiveShadowModifier: ViewModifier {
    let style: FloeShadow.Style
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content
            .shadow(
                color: .black.opacity(colorScheme == .dark ? style.darkOpacity : style.lightOpacity),
                radius: style.radius,
                x: 0,
                y: style.yOffset
            )
    }
} 
import SwiftUI

public enum FloeFont {
    // MARK: - Font Sizes
    public enum Size {
        case xs      // 12pt
        case sm      // 14pt
        case base    // 16pt
        case lg      // 18pt
        case xl      // 20pt
        case xl2     // 24pt
        case xl3     // 30pt
        case xl4     // 36pt
        
        var pointSize: CGFloat {
            switch self {
            case .xs: return 12
            case .sm: return 14
            case .base: return 16
            case .lg: return 18
            case .xl: return 20
            case .xl2: return 24
            case .xl3: return 30
            case .xl4: return 36
            }
        }
    }
    
    // MARK: - Font Weights
    public enum Weight {
        case regular
        case medium
        case semibold
        case bold
        
        var fontWeight: Font.Weight {
            switch self {
            case .regular: return .regular
            case .medium: return .medium
            case .semibold: return .semibold
            case .bold: return .bold
            }
        }
    }
    
    // MARK: - Font Styles
    public enum Style {
        case body
        case caption
        case button
        case title
        case headline
        case subheadline
        
        var size: Size {
            switch self {
            case .body: return .base
            case .caption: return .sm
            case .button: return .base
            case .title: return .xl2
            case .headline: return .xl
            case .subheadline: return .lg
            }
        }
        
        var weight: Weight {
            switch self {
            case .body: return .regular
            case .caption: return .regular
            case .button: return .semibold
            case .title: return .bold
            case .headline: return .semibold
            case .subheadline: return .medium
            }
        }
    }
    
    // MARK: - Public Methods
    public static func font(_ style: Style) -> Font {
        return .system(size: style.size.pointSize, weight: style.weight.fontWeight)
    }
    
    public static func font(size: Size, weight: Weight = .regular) -> Font {
        return .system(size: size.pointSize, weight: weight.fontWeight)
    }
}

// MARK: - View Extension
public extension View {
    func floeFont(_ style: FloeFont.Style) -> some View {
        self.font(FloeFont.font(style))
    }
    
    func floeFont(size: FloeFont.Size, weight: FloeFont.Weight = .regular) -> some View {
        self.font(FloeFont.font(size: size, weight: weight))
    }
} 
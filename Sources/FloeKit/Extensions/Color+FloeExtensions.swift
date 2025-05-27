import SwiftUI

// MARK: - FloeKit Color Extensions
public extension Color {
    
    // MARK: - Opacity Variants
    /// Creates a color with 10% opacity
    var opacity10: Color { self.opacity(0.1) }
    
    /// Creates a color with 20% opacity
    var opacity20: Color { self.opacity(0.2) }
    
    /// Creates a color with 30% opacity
    var opacity30: Color { self.opacity(0.3) }
    
    /// Creates a color with 40% opacity
    var opacity40: Color { self.opacity(0.4) }
    
    /// Creates a color with 50% opacity
    var opacity50: Color { self.opacity(0.5) }
    
    /// Creates a color with 60% opacity
    var opacity60: Color { self.opacity(0.6) }
    
    /// Creates a color with 70% opacity
    var opacity70: Color { self.opacity(0.7) }
    
    /// Creates a color with 80% opacity
    var opacity80: Color { self.opacity(0.8) }
    
    /// Creates a color with 90% opacity
    var opacity90: Color { self.opacity(0.9) }
    
    // MARK: - Adaptive Colors
    /// Creates an adaptive color that changes based on color scheme
    /// - Parameters:
    ///   - light: Color for light mode
    ///   - dark: Color for dark mode
    /// - Returns: An adaptive color
    static func adaptive(light: Color, dark: Color) -> Color {
        #if canImport(UIKit)
        return Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
        #else
        // On macOS, use environment-based color scheme detection
        return Color.primary // Fallback for macOS
        #endif
    }
    
    // MARK: - Color Manipulation
    /// Lightens the color by the specified amount
    /// - Parameter amount: The amount to lighten (0.0 to 1.0)
    /// - Returns: A lightened color
    func lighter(by amount: Double = 0.2) -> Color {
        return self.opacity(1.0 - amount)
    }
    
    /// Darkens the color by the specified amount
    /// - Parameter amount: The amount to darken (0.0 to 1.0)
    /// - Returns: A darkened color
    func darker(by amount: Double = 0.2) -> Color {
        #if canImport(UIKit)
        let uiColor = UIColor(self)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return Color(
            hue: Double(hue),
            saturation: Double(saturation),
            brightness: Double(max(0, brightness - CGFloat(amount))),
            opacity: Double(alpha)
        )
        #else
        // Fallback for macOS - simple opacity reduction
        return self.opacity(1.0 - amount)
        #endif
    }
    
    // MARK: - Hex Color Support
    /// Creates a color from a hex string
    /// - Parameter hex: The hex string (with or without #)
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // MARK: - Color to Hex
    /// Converts the color to a hex string
    /// - Parameter includeAlpha: Whether to include alpha in the hex string
    /// - Returns: A hex string representation of the color
    func toHex(includeAlpha: Bool = false) -> String {
        #if canImport(UIKit)
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        if includeAlpha {
            return String(format: "#%02X%02X%02X%02X",
                         Int(alpha * 255),
                         Int(red * 255),
                         Int(green * 255),
                         Int(blue * 255))
        } else {
            return String(format: "#%02X%02X%02X",
                         Int(red * 255),
                         Int(green * 255),
                         Int(blue * 255))
        }
        #else
        // Fallback for macOS
        return "#000000"
        #endif
    }
    
    // MARK: - Contrast Checking
    /// Calculates the contrast ratio between this color and another
    /// - Parameter other: The other color to compare against
    /// - Returns: The contrast ratio (1.0 to 21.0)
    func contrastRatio(with other: Color) -> Double {
        let luminance1 = self.luminance()
        let luminance2 = other.luminance()
        let lighter = max(luminance1, luminance2)
        let darker = min(luminance1, luminance2)
        return (lighter + 0.05) / (darker + 0.05)
    }
    
    /// Calculates the relative luminance of the color
    /// - Returns: The luminance value (0.0 to 1.0)
    private func luminance() -> Double {
        #if canImport(UIKit)
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        func adjust(component: CGFloat) -> Double {
            let c = Double(component)
            return c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }
        
        return 0.2126 * adjust(component: red) +
               0.7152 * adjust(component: green) +
               0.0722 * adjust(component: blue)
        #else
        // Fallback for macOS
        return 0.5
        #endif
    }
    
    /// Checks if this color has sufficient contrast with another for accessibility
    /// - Parameters:
    ///   - other: The other color to check against
    ///   - level: The WCAG compliance level (.AA or .AAA)
    /// - Returns: True if the contrast is sufficient
    func hasAccessibleContrast(with other: Color, level: WCAGLevel = .AA) -> Bool {
        let ratio = contrastRatio(with: other)
        switch level {
        case .AA:
            return ratio >= 4.5
        case .AAA:
            return ratio >= 7.0
        }
    }
}

// MARK: - WCAG Compliance Level
public enum WCAGLevel {
    case AA
    case AAA
}

// MARK: - FloeColors Semantic Extensions
public extension FloeColors {
    
    // MARK: - Semantic Colors
    static let success = Color.adaptive(
        light: Color(red: 0.18, green: 0.80, blue: 0.44),
        dark: Color(red: 0.22, green: 0.84, blue: 0.48)
    )
    
    static let successLight = success.opacity30
    
    static let warning = Color.adaptive(
        light: Color(red: 0.98, green: 0.67, blue: 0.22),
        dark: Color(red: 1.0, green: 0.71, blue: 0.26)
    )
    
    static let warningLight = warning.opacity30
    
    static let info = Color.adaptive(
        light: Color(red: 0.22, green: 0.47, blue: 0.98),
        dark: Color(red: 0.26, green: 0.51, blue: 1.0)
    )
    
    static let infoLight = info.opacity30
    
    // MARK: - Primary Color Opacity Variants
    static let primary10 = primary.opacity10
    static let primary20 = primary.opacity20
    static let primary30 = primary.opacity30
    static let primary40 = primary.opacity40
    static let primary50 = primary.opacity50
    
    // MARK: - Secondary Color Opacity Variants
    static let secondary10 = secondary.opacity10
    static let secondary20 = secondary.opacity20
    static let secondary30 = secondary.opacity30
    static let secondary40 = secondary.opacity40
    static let secondary50 = secondary.opacity50
    
    // MARK: - Error Color Opacity Variants
    static let error10 = error.opacity10
    static let error20 = error.opacity20
    static let error30 = error.opacity30
    static let error40 = error.opacity40
    static let error50 = error.opacity50
} 
import SwiftUI

public struct FloeColors {
    // MARK: - Core Palette
    public static let primary = Color("FloePrimary", bundle: .module)
    public static let secondary = Color("FloeSecondary", bundle: .module)
    public static let accent = Color("FloeAccent", bundle: .module)
    public static let error = Color("FloeError", bundle: .module)
    public static let background = Color("FloeBackground", bundle: .module)
    public static let surface = Color("FloeSurface", bundle: .module)
    
    // MARK: - Neutrals
    public static let neutral0 = Color("FloeNeutral0", bundle: .module)
    public static let neutral10 = Color("FloeNeutral10", bundle: .module)
    public static let neutral20 = Color("FloeNeutral20", bundle: .module)
    public static let neutral30 = Color("FloeNeutral30", bundle: .module)
    public static let neutral40 = Color("FloeNeutral40", bundle: .module)
    public static let neutral90 = Color("FloeNeutral90", bundle: .module)
}

// MARK: - Example Color Definitions (for preview/testing)
public extension Color {
    static let floePreviewPrimary = Color(red: 0.22, green: 0.47, blue: 0.98)
    static let floePreviewSecondary = Color(red: 0.18, green: 0.80, blue: 0.44)
    static let floePreviewAccent = Color(red: 0.98, green: 0.67, blue: 0.22)
    static let floePreviewError = Color(red: 0.95, green: 0.23, blue: 0.23)
    static let floePreviewBackground = Color(red: 0.97, green: 0.98, blue: 1.0)
    static let floePreviewSurface = Color(red: 0.92, green: 0.94, blue: 0.98)
    static let floePreviewNeutral = Color(red: 0.60, green: 0.65, blue: 0.70)
} 

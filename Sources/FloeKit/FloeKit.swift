import SwiftUI

// MARK: - FloeKit Module
public struct FloeKit {
    public static let version = "0.3.2"
    
    /// Initialize FloeKit with any global configuration if needed
    public static func configure() {
        // Future: Add any global setup here
    }
}

// MARK: - Module Exports
// All components and utilities are automatically available when importing FloeKit
// because they are declared as public in their respective files.

// This file serves as the main entry point and ensures the module compiles correctly.
// Components available after importing FloeKit:
// - FloeButton, FloeTextField, FloeCard, FloeAvatar, FloeToggle
// - FloeToast, FloeTabBar, FloeSlider, FloeTextView, FloeProgressIndicator
// - FloeColors, FloeFont, FloeSpacing, FloeShadow utilities
// - View+FloeModifiers, Color+FloeExtensions (Extension utilities) 
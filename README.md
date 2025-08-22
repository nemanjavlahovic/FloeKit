# FloeKit

> Elegant, modular UI components for SwiftUI

![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%2015%2B%20%7C%20macOS%2012%2B-blue.svg)
![SPM](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)

FloeKit provides clean, composable UI components built on SwiftUI with consistent design, theming, and accessibility support.

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/nemanjavlahovic/FloeKit", from: "0.4.0")
]
```

Or add via Xcode: File → Add Package Dependencies

## Quick Start

```swift
import FloeKit

struct ContentView: View {
    @State private var name = ""
    @State private var rating: Double = 0
    
    var body: some View {
        VStack(spacing: 20) {
            FloeTextField(text: $name, placeholder: "Enter name")
            FloeButton.primary("Save") { /* action */ }
            FloeRating(rating: $rating)
        }
        .padding()
    }
}
```

## Components

### Core Components
- **[FloeButton](Documentation/Components/FloeButton.md)** - Buttons with multiple styles and haptic feedback
- **[FloeTextField](Documentation/Components/FloeTextField.md)** - Text input with validation and icons
- **[FloeCard](Documentation/Components/FloeCard.md)** - Interactive containers with selection and swipe actions
- **[FloeAvatar](Documentation/Components/FloeAvatar.md)** - User avatars with status indicators

### Navigation & Layout
- **[FloeTabBar](Documentation/Components/FloeTabBar.md)** - Clean tab bar with badges
- **[FloeBottomSheet](Documentation/Components/FloeBottomSheet.md)** - Modal sheets with drag-to-dismiss
- **[FloeSegmentedControl](Documentation/Components/FloeSegmentedControl.md)** - Segmented picker control

### Input & Selection  
- **[FloeSlider](Documentation/Components/FloeSlider.md)** - Value slider with haptic feedback
- **[FloeRating](Documentation/Components/FloeRating.md)** - Star rating component
- **[FloeOTPField](Documentation/Components/FloeOTPField.md)** - PIN/OTP input fields
- **[FloeDatePicker](Documentation/Components/FloeDatePicker.md)** - Enhanced date picker

### Feedback & Display
- **[FloeToast](Documentation/Components/FloeToast.md)** - Toast notifications
- **[FloeProgressIndicator](Documentation/Components/FloeProgressIndicator.md)** - Progress bars and spinners
- **[FloeEmptyState](Documentation/Components/FloeEmptyState.md)** - Empty state views
- **[FloeBadge](Documentation/Components/FloeBadge.md)** - Notification badges

### Text & Content
- **[FloeTextView](Documentation/Components/FloeTextView.md)** - Rich text display with expansion
- **[FloeSearchBar](Documentation/Components/FloeSearchBar.md)** - Enhanced search input

## Utilities

- **FloeColors** - Adaptive color system with dark mode
- **FloeFont** - Typography system with semantic styles
- **FloeSpacing** - Consistent spacing and padding
- **FloeShadow** - Shadow styles that adapt to themes

## Theming

Override FloeKit's colors by adding color assets to your app:

1. Add `Colors.xcassets` to your project
2. Create color sets: `FloePrimary`, `FloeSecondary`, `FloeAccent`, etc.
3. FloeKit automatically uses your colors

## Examples

See the included Example app for comprehensive usage examples.

## Documentation

Full documentation available in the `/Documentation` folder:

- [Installation Guide](Documentation/Guides/Installation.md)
- [Theming Guide](Documentation/Guides/Theming.md)
- [Component API Reference](Documentation/Components/)
- [Migration Guide](Documentation/Guides/Migration.md)

## Requirements

- iOS 15.0+ / macOS 12.0+
- Swift 5.9+
- Xcode 15.0+

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests where appropriate
5. Submit a pull request

## License

FloeKit is available under the MIT license. See [LICENSE](LICENSE) for details.

---

**FloeKit** - Building beautiful SwiftUI apps, one component at a time.
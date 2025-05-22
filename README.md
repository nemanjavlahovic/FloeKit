# FloeKit

> **Elegant, modular UI building blocks for SwiftUI**

Inspired by floating ice sheets, **FloeKit** provides calm, elegant, and modular UI components designed for composability, design clarity, and reuse. It positions itself as a thoughtful layer *on top of SwiftUI*, offering a consistent design system with built-in theming, spacing, and typography.

![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%2015%2B%20%7C%20macOS%2012%2B-blue.svg)
![SPM](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)

---

## ✨ Features

- **🎨 Consistent Design System** - Unified colors, typography, spacing, and shadows
- **📱 Cross-Platform** - Works on iOS and macOS
- **🌗 Dark Mode Ready** - Automatic light/dark mode adaptation
- **♿ Accessibility First** - Built-in VoiceOver and accessibility support
- **🔧 Highly Customizable** - Override any aspect while maintaining consistency
- **📦 Zero Dependencies** - Pure SwiftUI implementation

---

## 🚀 Installation

### Swift Package Manager

Add FloeKit to your project through Xcode:

1. File → Add Package Dependencies
2. Enter package URL: `https://github.com/nemanjavlahovic/FloeKit`
3. Select version and add to target

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/nemanjavlahovic/FloeKit", from: "0.1.0")
]
```

---

## 🧱 Components (v0.1)

### FloeButton
Soft, elevated buttons with multiple sizes, loading states, and icon support.

```swift
import FloeKit

// Basic button
FloeButton("Get Started") {
    // Action
}

// Button with icon and custom styling
FloeButton("Save", 
          size: .large,
          backgroundColor: .blue,
          textColor: .white,
          icon: Image(systemName: "checkmark")) {
    // Save action
}

// Loading state
FloeButton("Processing...", isLoading: true) {
    // Action
}
```

**Sizes:** `.small`, `.medium`, `.large`  
**Features:** Loading states, icons, custom colors, accessibility support

---

### FloeTextField
Elegant text input with focus states, icons, validation, and character limits.

```swift
@State private var email = ""
@State private var password = ""

// Basic text field
FloeTextField(text: $email, placeholder: "Email address")

// With icons and validation
FloeTextField(
    text: $email,
    placeholder: "Enter email",
    leadingIcon: Image(systemName: "envelope"),
    errorMessage: "Invalid email format"
)

// Secure field
FloeTextField(
    text: $password,
    placeholder: "Password",
    leadingIcon: Image(systemName: "lock"),
    isSecure: true
)

// With character limit
FloeTextField(
    text: $bio,
    placeholder: "Bio",
    characterLimit: 150
)
```

**Features:** Icons, secure input, validation, character limits, focus states

---

### FloeCard
Clean, elevated containers with consistent shadows and padding.

```swift
FloeCard {
    VStack {
        Text("Card Title")
            .floeFont(.headline)
        Text("Card content goes here")
            .floeFont(.body)
    }
}

// Custom styling
FloeCard(backgroundColor: .blue.opacity(0.1),
         shadowStyle: .elevated,
         padding: .generous) {
    // Content
}
```

**Features:** Customizable shadows, padding presets, border support

---

### FloeSection
Reusable section containers with titles, subtitles, and trailing content.

```swift
FloeSection(title: "Settings") {
    VStack {
        Text("Notifications")
        Text("Privacy")
        Text("Account")
    }
}

// With subtitle and trailing button
FloeSection(title: "Profile", 
           subtitle: "Manage your information",
           trailing: AnyView(Button("Edit") { })) {
    // Content
}
```

**Features:** Optional subtitles, trailing content, consistent spacing

---

## 🛠️ Utilities

### FloeColors
Consistent color palette with automatic light/dark mode support.

```swift
// Use predefined colors
.foregroundColor(FloeColors.primary)
.backgroundColor(FloeColors.surface)

// Color tokens available:
// - Primary, Secondary, Accent, Error
// - Background, Surface
// - Neutral scale (neutral0 to neutral90)
```

---

### FloeFont
Typography system with semantic font styles.

```swift
Text("Headline")
    .floeFont(.headline)

Text("Body text")
    .floeFont(.body)

// Or with custom size and weight
Text("Custom")
    .floeFont(size: .xl, weight: .bold)

// Available styles: .body, .caption, .button, .title, .headline, .subheadline
// Available sizes: .xs, .sm, .base, .lg, .xl, .xl2, .xl3, .xl4
```

---

### FloeSpacing
Consistent spacing and padding system.

```swift
// Use spacing tokens
VStack(spacing: FloeSpacing.Size.lg.value) {
    // Content
}

// Apply semantic padding
SomeView()
    .floePadding(.card)        // Standard card padding
    .floePadding(.section)     // Section container padding
    .floePadding(.comfortable) // Comfortable all-around padding

// Custom spacing
SomeView()
    .floePadding(.vertical, .lg)
    .floePadding(.horizontal, .xl)
```

---

### FloeShadow
Consistent shadow system with automatic dark mode adaptation.

```swift
// Apply semantic shadows
RoundedRectangle(cornerRadius: 12)
    .floeShadow(.soft)      // Subtle shadow
    .floeShadow(.medium)    // Standard shadow
    .floeShadow(.elevated)  // Strong shadow

// Available styles: .none, .subtle, .soft, .medium, .elevated
```

---

## 🗺️ Roadmap

### 📝 FloeTextView *(Coming Soon)*
Multi-line, expandable text view with rich formatting support.
- Attributed text support
- "Read more/less" functionality
- Inline links and formatting
- Character/line limits

### ⏳ FloeProgressIndicator *(Planned)*
Modern progress indicators with enhanced feedback.
- Linear and circular styles
- Animated transitions
- Success/error states
- Haptic feedback

### 🗂️ FloeSectionHeader *(Planned)*
Reusable section headers with actions.
- Title and subtitle support
- Trailing action buttons
- Collapsible sections

### 🧾 FloeListItem *(Planned)*
Highly customizable list rows.
- Leading/trailing content
- Swipe actions
- Badges and accessories
- Tap handling

### 🖼️ FloeAvatar *(Planned)*
Elegant avatar components.
- Image, initials, or icon fallbacks
- Online/offline indicators
- Grouped avatars
- Multiple sizes

### 🗨️ FloeToast *(Planned)*
Lightweight toast notifications.
- Auto-dismiss functionality
- Custom styling
- Action buttons
- Queue management

### 🧩 FloeTabBar *(Planned)*
Modern floating tab bar.
- Smooth animations
- Scrollable tabs
- Central action button
- Custom indicators

---

## 🎨 Theming

FloeKit supports comprehensive theming through color asset overrides:

1. Add a `Colors.xcassets` to your app
2. Create color sets with FloeKit's color names:
   - `FloePrimary`, `FloeSecondary`, `FloeAccent`
   - `FloeBackground`, `FloeSurface`
   - `FloeNeutral0` through `FloeNeutral90`
3. FloeKit will automatically use your custom colors

---

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

1. Clone the repository
2. Open in Xcode or your preferred Swift IDE
3. Run tests: `swift test`
4. Build: `swift build`

---

## 📄 License

FloeKit is available under the MIT license. See [LICENSE](LICENSE) for details.

---

## 🙏 Acknowledgments

Inspired by modern design systems and the SwiftUI community's best practices.

---
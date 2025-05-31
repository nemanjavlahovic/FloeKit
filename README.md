# FloeKit
![7a368114-cc08-48e8-99fa-a7b060ece85c](https://github.com/user-attachments/assets/f810b190-6d9c-45f0-8dc9-3642ec033c04)

> **Elegant, modular UI building blocks for SwiftUI**

Inspired by floating ice sheets, **FloeKit** provides calm, elegant, and modular UI components designed for composability, design clarity, and reuse. It positions itself as a thoughtful layer *on top of SwiftUI*, offering a consistent design system with built-in theming, spacing, and typography.

![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%2015%2B%20%7C%20macOS%2012%2B-blue.svg)
![SPM](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)

<details>
<summary>📋 Table of Contents</summary>

- [✨ Features](#-features)
- [🚀 Installation](#-installation)
- [🧱 Components](#-components)
  - [FloeButton](#floebutton)
  - [FloeTextField](#floetextfield)
  - [FloeCard](#floecard)
  - [FloeAvatar](#floeavatar)
  - [FloeToast](#floetoast-new)
  - [FloeTabBar](#floetabbar-new)
  - [FloeSlider](#floeslider-new)
  - [FloeTextView](#floetextview-new)
  - [FloeProgressIndicator](#floeprogressindicator-new)
  - [FloeSearchBar](#floesearchbar-new)
  - [FloeSkeleton](#floeskeleton-new)
- [🏗️ Comprehensive Example](#️-comprehensive-example)
- [🛠️ Utilities](#️-utilities)
  - [FloeColors](#floecolors)
  - [FloeFont](#floefont)
  - [FloeSpacing](#floespacing)
  - [FloeShadow](#floeshadow)
- [🗺️ Roadmap](#️-roadmap)
- [🎨 Theming](#-theming)
- [📄 License](#-license)
- [🙏 Acknowledgments](#-acknowledgments)

</details>

---

## ✨ Features

- **🎨 Consistent Design System** - Unified colors, typography, spacing, and shadows
- **📱 Cross-Platform** - Works seamlessly on iOS and macOS
- **🌗 Perfect Dark Mode** - ✅ **Complete** - All components tested and beautiful in both light and dark modes
- **♿ Accessibility First** - Built-in VoiceOver, Dynamic Type, and comprehensive accessibility support
- **🏗️ Advanced Architecture** - Result builders, preference keys, haptic feedback, and sophisticated animations
- **🔧 Highly Customizable** - Override any aspect while maintaining design consistency
- **⚡ Performance Optimized** - Efficient SwiftUI implementation with smooth 60fps animations
- **📦 Zero Dependencies** - Pure SwiftUI implementation with no external dependencies
- **🎯 Production Ready** - Battle-tested components with proper error handling and edge cases

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
    .package(url: "https://github.com/nemanjavlahovic/FloeKit", from: "0.3.0")
]
```

---

## 🧱 Components

### FloeButton
Soft, elevated buttons with multiple sizes, loading states, and icon support.

![FloeButton Examples](Documentation/Screenshots/floe_button_ss.png)

```swift
import FloeKit

// Basic button
FloeButton("Get Started") {
    // Action
}

// Button with icon and custom styling
// Note: Parameters can be specified in any order using named parameters
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

![FloeTextField Examples](Documentation/Screenshots/floe_textfield_ss.png)

```swift
@State private var email = ""
@State private var password = ""
@State private var bio = ""

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

![FloeCard Examples](Documentation/Screenshots/floe_card_ss.png)

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
         padding: .spacious) {
    // Content
}
```

**Features:** Customizable shadows, padding presets, border support

---

### FloeAvatar
Elegant, customizable avatar components with status indicators and grouping support.

![FloeAvatar Examples](Documentation/Screenshots/floe_avatar_ss.png)

```swift
// Basic avatars
FloeAvatar.initials("JD")
FloeAvatar.icon("person.fill")
FloeAvatar.placeholder()

// With image
FloeAvatar(image: Image("user-photo"))

// Different sizes
FloeAvatar.initials("SM", size: .small)
FloeAvatar.initials("LG", size: .large)
FloeAvatar.initials("XL", size: .extraLarge)

// With status indicators
FloeAvatar.online(initials: "ON")
FloeAvatar(initials: "AW", statusIndicator: .away)
FloeAvatar(initials: "BY", statusIndicator: .busy)
FloeAvatar(initials: "CT", statusIndicator: .custom(.purple))

// Custom styling
FloeAvatar(
    initials: "VIP",
    backgroundColor: .black,
    foregroundColor: .yellow,
    borderColor: .yellow,
    borderWidth: 2,
    shadowStyle: .elevated
)

// Interactive avatars
FloeAvatar.initials("TAP") {
    print("Avatar tapped!")
}
```

**Grouped Avatars:**
```swift
// Stacked avatars with overlap
FloeAvatarGroup(
    avatars: [avatar1, avatar2, avatar3],
    style: .stacked,
    maxVisible: 3
)

// Grid layout
FloeAvatarGroup(
    avatars: avatarArray,
    style: .grid(columns: 2)
)
```

**Sizes:** `.small`, `.medium`, `.large`, `.extraLarge`  
**Status:** Online, offline, away, busy, custom colors  
**Features:** Images, initials, SF Symbols, borders, shadows, tap actions, grouping

---

### FloeToast *(New)*
Lightweight, animated toast notifications with swipe-to-dismiss and customizable styles.

```swift
@StateObject private var toastManager = FloeToastManager()

// Basic usage with convenience methods
.floeToast(FloeToast.success("Success!", message: "Operation completed"))
.floeToast(FloeToast.error("Error!", message: "Something went wrong"))
.floeToast(FloeToast.warning("Warning!", message: "Please check your input"))
.floeToast(FloeToast.info("Info", message: "New update available"))

// Custom toast with action
FloeToast("Custom Toast",
          message: "With action button",
          style: .custom(backgroundColor: .purple, 
                        foregroundColor: .white, 
                        icon: Image(systemName: "star.fill")),
          actionTitle: "Action") {
    // Action handler
}

// Using Toast Manager
toastManager.show(FloeToast.success("Saved successfully!"))

// Advanced configuration
FloeToast("Upload Complete",
          message: "Your file has been uploaded",
          style: .success,
          position: .bottom,
          duration: 5.0,
          actionTitle: "View") {
    // View file action
} onDismiss: {
    print("Toast dismissed")
}
```

**Styles:** Success, warning, error, info, custom  
**Positions:** Top, bottom  
**Features:** Auto-dismiss, swipe gestures, action buttons, custom styling, animations

---

### FloeTabBar *(New)*
Modern floating tab bar with smooth animations and flexible configuration.

![FloeTabBar Result Builder](Documentation/Screenshots/floe_tabbar_result_builder_ss.png)
![FloeTabBar Enhanced Badges](Documentation/Screenshots/floe_tabbar_enhanced_badges_ss.png)

```swift
// Define tabs
let tabs = [
    FloeTabBar.Tab.systemIcon(id: "home", title: "Home", 
                             systemName: "house", selectedSystemName: "house.fill"),
    FloeTabBar.Tab.systemIcon(id: "search", title: "Search", 
                             systemName: "magnifyingglass", badge: "3"),
    FloeTabBar.Tab.systemIcon(id: "favorites", title: "Favorites", 
                             systemName: "heart", selectedSystemName: "heart.fill"),
    FloeTabBar.Tab.systemIcon(id: "profile", title: "Profile", 
                             systemName: "person", selectedSystemName: "person.fill")
]

// Basic tab bar
@State private var selectedTab = "home"

FloeTabBar(
    tabs: tabs,
    selectedTabId: selectedTab,
    onTabSelected: { selectedTab = $0 }
)

// Floating style with central action
FloeTabBar(
    tabs: tabs,
    selectedTabId: selectedTab,
    onTabSelected: { selectedTab = $0 },
    style: .floating,
    indicatorStyle: .pill,
    centralAction: { print("Add new item") },
    centralActionIcon: Image(systemName: "plus.circle.fill")
)

// Scrollable for many tabs
FloeTabBar(
    tabs: manyTabs,
    selectedTabId: selectedTab,
    onTabSelected: { selectedTab = $0 },
    isScrollable: true
)

// Complete tab bar controller
FloeTabBarController(
    tabs: tabs,
    initialSelection: "home",
    style: .floating
) { selectedTab in
    // Content for each tab
    switch selectedTab {
    case "home": HomeView()
    case "search": SearchView()
    case "favorites": FavoritesView()
    case "profile": ProfileView()
    default: EmptyView()
    }
}
```

**Styles:** Floating, attached, minimal  
**Indicators:** Pill, underline, background, none  
**Features:** Badges, central action button, scrollable tabs, animations, custom icons

**Result Builder Syntax:**
```swift
// Declarative tab creation with @TabBuilder
FloeTabBar(
    selectedTabId: selectedTab,
    onTabSelected: { selectedTab = $0 },
    style: .floating,
    indicatorStyle: .pill
) {
    FloeTabBar.Tab.systemIcon(id: "home", title: "Home", systemName: "house")
    FloeTabBar.Tab.systemIcon(id: "search", title: "Search", systemName: "magnifyingglass")
    FloeTabBar.Tab.systemIcon(id: "favorites", title: "Favorites", systemName: "heart")
    FloeTabBar.Tab.systemIcon(id: "profile", title: "Profile", systemName: "person")
}
```

---

### FloeSlider *(New)*
Customizable slider with haptic feedback, value labels, and both horizontal/vertical orientations.

```swift
@State private var volume: Double = 50
@State private var brightness: Double = 0.7

// Basic slider
FloeSlider(value: $volume, in: 0...100, showLabels: .value)

// Percentage slider with convenience method
FloeSlider.percentage(value: $volume, showLabels: true)

// Volume-style slider (0-1)
FloeSlider.volume(value: $brightness)

// Custom range with steps
FloeSlider(
    value: $rating,
    in: 0...5,
    step: 0.5,
    showLabels: .value,
    showMinMax: true
)

// Vertical slider
FloeSlider(
    value: $volume,
    in: 0...100,
    orientation: .vertical,
    showLabels: .percentage
)
.frame(height: 200)

// Custom styling
FloeSlider(
    value: $temperature,
    in: 16...30,
    showLabels: .custom({ "\(Int($0))°C" }),
    fillColor: .orange,
    thumbColor: .red,
    enableHaptics: true
)
```

**Orientations:** Horizontal, vertical  
**Label Styles:** None, value, percentage, custom formatter  
**Features:** Haptic feedback, range indicators, step values, custom styling, accessibility

---

### FloeTextView *(New)*
Rich text display and editing component with expansion controls and character limits.

![FloeTextView Examples](Documentation/Screenshots/floe_textview_ss.png)

```swift
@State private var editableText = ""
@State private var limitedText = ""

// Basic editable text view
FloeTextView(
    text: $editableText,
    placeholder: "Enter your thoughts...",
    size: .medium
)

// Read-only with expansion
FloeTextView.readOnly(
    text: "Long text content that can be expanded...",
    expansionStyle: .readMore(previewLines: 2)
)

// With character limit
FloeTextView.withCharacterLimit(
    text: $limitedText,
    placeholder: "Bio (max 100 characters)",
    characterLimit: 100,
    size: .small
)

// Attributed text with rich formatting
FloeTextView.attributedText(
    attributedString,
    size: .medium,
    expansionStyle: .readMore(previewLines: 3)
)
```

**Sizes:** `.small`, `.medium`, `.large`  
**Expansion Styles:** Read more/less, character limits, custom  
**Features:** Rich text support, smooth animations, character counting, accessibility

---

### FloeProgressIndicator *(New)*
Versatile progress indicators with linear and circular styles, supporting both determinate and indeterminate states.

![FloeProgressIndicator Demo](Documentation/Screenshots/floe_progress_indicator_rec.mov)

```swift
@State private var progress: Double = 0.65

// Linear progress indicators
FloeProgressIndicator(
    progress: progress,
    style: .linear,
    size: .medium,
    showPercentage: true
)

// Circular progress indicators
FloeProgressIndicator(
    progress: 0.75,
    style: .circular,
    size: .large,
    showPercentage: true
)

// Indeterminate loading
FloeProgressIndicator.indeterminate(
    style: .circular,
    size: .medium,
    color: .blue
)

// State-based indicators
FloeProgressIndicator.loading(style: .circular, size: .medium)
FloeProgressIndicator.success(style: .circular, size: .medium)
FloeProgressIndicator.error(style: .circular, size: .medium)

// Custom styling
FloeProgressIndicator(
    progress: progress,
    style: .linear,
    size: .large,
    color: .purple,
    backgroundColor: .gray.opacity(0.2),
    showPercentage: true
)
```

**Styles:** Linear, circular  
**States:** Determinate, indeterminate, loading, success, error  
**Sizes:** `.small`, `.medium`, `.large`  
**Features:** Smooth animations, custom colors, percentage display, accessibility

---

### FloeSearchBar *(New)*
Enhanced search bar with modern styling and functionality.

```swift
@State private var searchText = ""

// Basic search bar
FloeSearchBar(
    text: $searchText,
    placeholder: "Search...",
    onSearchSubmit: { query in
        print("Searching for: \(query)")
    }
)

// Search bar with voice input
FloeSearchBar.withVoiceSearch(
    text: $searchText,
    placeholder: "Search with voice...",
    onVoiceSearch: { activateVoiceSearch() }
)

// Search bar with filter
FloeSearchBar.withFilter(
    text: $searchText,
    placeholder: "Search and filter...",
    onFilter: { showFilterOptions() }
)

// Search bar with cancel button
FloeSearchBar.withCancelButton(
    text: $searchText,
    placeholder: "Search...",
    onCancel: { clearSearch() }
)
```

**Features:** Auto-clear button, focus states, voice search support, filter integration, cancel button, custom styling, accessibility support

---

### FloeSkeleton *(New)*
Skeleton loading components for beautiful placeholder UI while content loads.

```swift
// Basic skeleton shapes
FloeSkeleton.avatar(size: 40)
FloeSkeleton.text(lines: 3)
FloeSkeleton.button(width: 100, height: 40)

// Post skeleton with automatic layout
FloeSkeleton.post()

// Multiple loading items
FloeSkeletonLoading(count: 3) {
    FloeSkeleton.listItem()
}

// Custom skeleton with different animations
FloeSkeleton(
    style: .rectangle(width: 200, height: 40),
    animationType: .shimmer,
    cornerRadius: 8
)

// NEW: Skeleton View Modifiers - Apply to any view!
@State private var isLoading = true

// Apply skeleton to any view
MyComplexCard()
    .floeSkeleton($isLoading)

// Skeleton for text content
Text("User Name")
    .floeTextSkeleton($isLoading)

Text("Multi-line content here")
    .floeTextSkeleton($isLoading, lines: 2, lastLineWidth: 0.6)

// Skeleton for buttons
FloeButton("Save") { }
    .floeSkeleton($isLoading, cornerRadius: 16)

// Skeleton for avatars
FloeAvatar.initials("JD")
    .floeSkeleton($isLoading, cornerRadius: 25)

// Custom animation types
AnyView()
    .floeSkeleton($isLoading, animationType: .pulse)
    .floeSkeleton($isLoading, animationType: .wave)
    .floeSkeleton($isLoading, animationType: .shimmer)
```

**Styles:** Text, circle, rectangle, card, custom  
**Animations:** Shimmer, pulse, wave, none  
**Features:** Multiple animation types, customizable colors, automatic staggered loading, convenience methods for common use cases, **view modifiers for any SwiftUI view**

---

## 🏗️ Comprehensive Example

Here's how FloeKit components work together in a real application:

```swift
import SwiftUI
import FloeKit

struct ProfileView: View {
    @State private var name = ""
    @State private var bio = ""
    @State private var selectedTab = "profile"
    @State private var showSuccessToast = false
    
    var body: some View {
        FloeTabBarController(
            initialSelection: "profile",
            style: .floating
        ) {
            FloeTabBar.Tab.systemIcon(id: "profile", title: "Profile", systemName: "person")
            FloeTabBar.Tab.systemIcon(id: "settings", title: "Settings", systemName: "gear")
        } content: { selectedTab in
            ScrollView {
                VStack(spacing: FloeSpacing.Size.lg.value) {
                    // Avatar Section
                    FloeCard {
                        VStack(spacing: FloeSpacing.Size.md.value) {
                            FloeAvatar.initials("JD", size: .extraLarge)
                            Text("John Doe")
                                .floeFont(.headline)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Form Section
                    FloeCard(padding: .comfortable) {
                        VStack(spacing: FloeSpacing.Size.md.value) {
                            FloeTextField(
                                text: $name,
                                placeholder: "Full Name",
                                leadingIcon: Image(systemName: "person.fill")
                            )
                            
                            FloeTextView.withCharacterLimit(
                                text: $bio,
                                placeholder: "Tell us about yourself...",
                                characterLimit: 150,
                                size: .medium
                            )
                            
                            FloeButton("Save Profile",
                                      size: .large,
                                      backgroundColor: FloeColors.primary,
                                      textColor: .white) {
                                showSuccessToast = true
                            }
                        }
                    }
                    
                    // Progress Section
                    FloeCard {
                        VStack(alignment: .leading, spacing: FloeSpacing.Size.sm.value) {
                            Text("Profile Completion")
                                .floeFont(.headline)
                            
                            FloeProgressIndicator(
                                progress: 0.75,
                                style: .linear,
                                size: .medium,
                                showPercentage: true
                            )
                        }
                    }
                }
                .floePadding(.comfortable)
            }
            .floeToast(showSuccessToast ? 
                FloeToast.success("Profile Updated!", 
                                 message: "Your changes have been saved") {
                    showSuccessToast = false
                } : nil
            )
        }
    }
}
```

**This example demonstrates:**
- **FloeTabBarController** with multiple screens
- **FloeCard** for clean content organization  
- **FloeAvatar** for user representation
- **FloeTextField** with icons for form input
- **FloeTextView** with character limits for longer text
- **FloeButton** for primary actions
- **FloeProgressIndicator** for status display
- **FloeToast** for user feedback
- **FloeSpacing** and **FloeFont** for consistent styling

---

## 🛠️ Utilities

### FloeColors
Adaptive color palette with seamless light/dark mode support.

```swift
// Primary semantic colors
.foregroundColor(FloeColors.primary)     // Main brand color
.backgroundColor(FloeColors.secondary)   // Secondary brand color
.foregroundColor(FloeColors.accent)      // Accent highlights
.foregroundColor(FloeColors.error)       // Error states

// Surface colors
.backgroundColor(FloeColors.background)  // Main background
.backgroundColor(FloeColors.surface)     // Card/component backgrounds

// Neutral scale for subtle elements
.foregroundColor(FloeColors.neutral0)    // Pure contrast
.foregroundColor(FloeColors.neutral10)   // High contrast text
.foregroundColor(FloeColors.neutral20)   // Medium contrast borders
.foregroundColor(FloeColors.neutral30)   // Low contrast dividers
.foregroundColor(FloeColors.neutral40)   // Subtle text
.foregroundColor(FloeColors.neutral90)   // Very subtle backgrounds

// State colors
.foregroundColor(FloeColors.success)     // Success feedback
.foregroundColor(FloeColors.warning)     // Warning states
```

**✅ All colors automatically adapt to light/dark mode**  
**✅ Consistent contrast ratios for accessibility**  
**✅ Can be overridden via color assets for custom theming**

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
    .floePadding(.spacious)    // Spacious padding
    .floePadding(.generous)    // Generous padding

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

### 🎛️ FloeStepper *(Next Phase)*
Custom stepper component with enhanced visual feedback.
- Smooth animations and haptic feedback
- Custom styling and button designs
- Long press for rapid changes
- Custom step values and ranges

### 📅 FloeDatePicker & FloeTimePicker *(Next Phase)*
Modern date and time selection components.
- Inline and compact picker styles
- Custom styling with FloeKit design language
- Range selection support
- Localization and timezone support

### 🔍 FloeSearchBar *(Next Phase)*
Enhanced search bar with modern styling and functionality.
- Animated search icon and clear button
- Search suggestions and recent searches
- Voice input support
- Custom filtering and debouncing

### 📋 FloeList & FloeGrid *(Planned)*
Enhanced list and grid components with built-in styling.
- Pull-to-refresh and infinite scrolling
- Swipe actions and reordering
- Section headers with sticky behavior
- Loading states and empty state views

### 🎨 FloeColorPicker *(Planned)*
Modern color selection component.
- Multiple picker styles (wheel, palette, sliders)
- Custom color palettes and recent colors
- Hex, RGB, HSL input support
- Eyedropper functionality

### 📊 FloeChart *(Planned)*
Simple charting components for basic data visualization.
- Line, bar, and pie chart support
- Animated data updates
- Interactive tooltips and legends
- Customizable colors and styling

---

## 🎨 Theming

FloeKit supports comprehensive theming through color asset overrides:

1. Add a `Colors.xcassets` to your app
2. Create color sets with FloeKit's color names:
   - `FloePrimary`, `FloeSecondary`, `FloeAccent`
   - `FloeBackground`, `FloeSurface`
   - `FloeNeutral0`, `FloeNeutral10`, `FloeNeutral20`, `FloeNeutral30`, `FloeNeutral40`, `FloeNeutral90`
3. FloeKit will automatically use your custom colors

---

## 📄 License

FloeKit is available under the MIT license. See [LICENSE](LICENSE) for details.

---

## 🙏 Acknowledgments

Inspired by modern design systems and the SwiftUI community's best practices.

---

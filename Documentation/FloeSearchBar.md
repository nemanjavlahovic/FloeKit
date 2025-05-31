# FloeSearchBar

A modern, customizable search bar component that follows FloeKit's design principles with full dark/light mode support.

## Features

- **Multiple Sizes**: Small, medium, and large variants
- **Leading & Trailing Elements**: Support for icons and interactive buttons
- **Voice Search Integration**: Built-in voice search button option
- **Filter Support**: Quick filter button integration
- **Cancel Button**: Optional cancel functionality
- **Automatic Clear Button**: Shows when text is entered
- **Focus Management**: Proper keyboard focus handling
- **Accessibility**: Full VoiceOver support
- **Animations**: Smooth transitions and interactions
- **Cross-Platform**: iOS 15+ and macOS 12+ support

## Basic Usage

```swift
@State private var searchText = ""

FloeSearchBar(
    text: $searchText,
    placeholder: "Search products..."
)
```

## Convenience Initializers

### Voice Search
```swift
FloeSearchBar.withVoiceSearch(
    text: $searchText,
    placeholder: "Say something...",
    onVoiceSearch: {
        // Handle voice search activation
    }
)
```

### Filter Integration
```swift
FloeSearchBar.withFilter(
    text: $searchText,
    placeholder: "Search and filter...",
    onFilter: {
        // Show filter options
    }
)
```

### Cancel Button
```swift
FloeSearchBar.withCancelButton(
    text: $searchText,
    placeholder: "Search here...",
    onCancel: {
        // Handle search cancellation
    }
)
```

## Custom Styling

```swift
FloeSearchBar(
    text: $searchText,
    placeholder: "Custom search...",
    size: .large,
    backgroundColor: FloeColors.accent.opacity(0.1),
    borderColor: FloeColors.accent,
    borderWidth: 2,
    textColor: FloeColors.primary,
    cornerRadius: 20,
    leadingElement: .button(Image(systemName: "magnifyingglass.circle.fill")) {
        // Custom search action
    },
    trailingElement: .button(Image(systemName: "qrcode.viewfinder")) {
        // QR scanner action
    }
)
```

## Leading & Trailing Elements

### Icons
```swift
// Leading icon
leadingElement: .icon(Image(systemName: "magnifyingglass"))

// Trailing icon
trailingElement: .icon(Image(systemName: "mic"))
```

### Interactive Buttons
```swift
// Leading button
leadingElement: .button(Image(systemName: "scope")) {
    // Handle scope selection
}

// Trailing button
trailingElement: .button(Image(systemName: "camera")) {
    // Handle camera action
}
```

### Built-in Options
```swift
// Voice search
trailingElement: .voiceSearch {
    // Handle voice search
}

// Filter
trailingElement: .filter {
    // Show filters
}
```

## Event Handling

```swift
FloeSearchBar(
    text: $searchText,
    onSearchSubmit: { query in
        // Handle search submission
        performSearch(query)
    },
    onTextChange: { newText in
        // Handle text changes (for live search)
        updateSuggestions(newText)
    },
    onCancel: {
        // Handle search cancellation
        clearResults()
    }
)
```

## Sizes

- `.small` - Compact search bar for tight spaces
- `.medium` - Standard size (default)
- `.large` - Prominent search bar for main interfaces

## Dark Mode Support

FloeSearchBar automatically adapts to light and dark modes using FloeKit's adaptive color system:

- Uses `FloeColors.surface` for background
- Uses `FloeColors.primary` for text
- Uses `FloeColors.neutral40` for icons
- Accent color highlights focus state

## Accessibility

The component includes comprehensive accessibility support:

- Proper accessibility labels and hints
- VoiceOver navigation support
- Dynamic Type support through FloeFont
- Keyboard navigation compatibility
- Screen reader friendly interactions

## Example

See `FloeSearchBarExample.swift` for a comprehensive showcase of all search bar configurations and styling options. 
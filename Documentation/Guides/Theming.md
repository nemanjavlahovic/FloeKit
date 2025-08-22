# Theming Guide

FloeKit components automatically adapt to your app's theme through color asset overrides.

## Custom Colors

1. **Add Colors.xcassets** to your Xcode project
2. **Create color sets** with FloeKit names:
   - `FloePrimary` - Main brand color  
   - `FloeSecondary` - Secondary brand color
   - `FloeAccent` - Accent highlights
   - `FloeError` - Error states
   - `FloeSuccess` - Success states
   - `FloeWarning` - Warning states

3. **FloeKit automatically uses your colors** across all components

## Example Setup

```
Colors.xcassets/
├── FloePrimary.colorset/
│   ├── Contents.json
│   └── (your brand color)
├── FloeSecondary.colorset/
└── FloeAccent.colorset/
```

## Dark Mode

All FloeKit colors automatically support dark mode when you configure both light and dark variants in your color assets.

## Utilities

Access FloeKit's color system in your own views:

```swift
Text("Hello")
    .foregroundColor(FloeColors.primary)
    .backgroundColor(FloeColors.surface)
```
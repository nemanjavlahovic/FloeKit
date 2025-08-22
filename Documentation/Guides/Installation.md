# Installation Guide

## Swift Package Manager (Recommended)

### Xcode
1. Open your project in Xcode
2. File → Add Package Dependencies
3. Enter: `https://github.com/nemanjavlahovic/FloeKit`
4. Select version and add to your target

### Package.swift
```swift
dependencies: [
    .package(url: "https://github.com/nemanjavlahovic/FloeKit", from: "0.4.0")
]
```

## Usage

```swift
import SwiftUI
import FloeKit

struct ContentView: View {
    var body: some View {
        FloeButton.primary("Hello FloeKit!") {
            print("Button tapped!")
        }
    }
}
```

## Requirements

- iOS 15.0+ / macOS 12.0+
- Swift 5.9+
- Xcode 15.0+
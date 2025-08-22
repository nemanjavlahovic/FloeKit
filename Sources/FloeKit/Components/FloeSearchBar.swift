import SwiftUI

public struct FloeSearchBar: View {
    public enum Size {
        case small, medium, large
        
        var padding: EdgeInsets {
            switch self {
            case .small: return FloeSpacing.TextFieldPadding.small.edgeInsets
            case .medium: return FloeSpacing.TextFieldPadding.medium.edgeInsets
            case .large: return FloeSpacing.TextFieldPadding.large.edgeInsets
            }
        }
        
        var font: Font {
            switch self {
            case .small: return FloeFont.font(.caption)
            case .medium: return FloeFont.font(.body)
            case .large: return FloeFont.font(.headline)
            }
        }
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 16
            case .medium: return 20
            case .large: return 24
            }
        }
    }
    
    public enum LeadingElement {
        case icon(Image)
        case button(Image, action: () -> Void)
    }
    
    public enum TrailingElement {
        case icon(Image)
        case button(Image, action: () -> Void)
        case voiceSearch(() -> Void)
        case filter(() -> Void)
    }
    
    @Binding private var text: String
    private let placeholder: String
    private let size: Size
    private let backgroundColor: Color
    private let borderColor: Color?
    private let borderWidth: CGFloat
    private let textColor: Color
    private let cornerRadius: CGFloat
    private let leadingElement: LeadingElement?
    private let trailingElement: TrailingElement?
    private let showsCancelButton: Bool
    private let onSearchSubmit: ((String) -> Void)?
    private let onCancel: (() -> Void)?
    private let onTextChange: ((String) -> Void)?
    
    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    @State private var isPressed = false
    
    public init(
        text: Binding<String>,
        placeholder: String = "Search...",
        size: Size = .medium,
        backgroundColor: Color = FloeColors.surface,
        borderColor: Color? = nil,
        borderWidth: CGFloat = 1.0,
        textColor: Color = FloeColors.primary,
        cornerRadius: CGFloat = 14,
        leadingElement: LeadingElement? = .icon(Image(systemName: "magnifyingglass")),
        trailingElement: TrailingElement? = nil,
        showsCancelButton: Bool = false,
        onSearchSubmit: ((String) -> Void)? = nil,
        onCancel: (() -> Void)? = nil,
        onTextChange: ((String) -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.size = size
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.textColor = textColor
        self.cornerRadius = cornerRadius
        self.leadingElement = leadingElement
        self.trailingElement = trailingElement
        self.showsCancelButton = showsCancelButton
        self.onSearchSubmit = onSearchSubmit
        self.onCancel = onCancel
        self.onTextChange = onTextChange
    }
    
    public var body: some View {
        HStack(spacing: FloeSpacing.Size.sm.value) {
            searchBarContent
            
            if showsCancelButton && (isFocused || !text.isEmpty) {
                Button("Cancel") {
                    text = ""
                    isFocused = false
                    onCancel?()
                }
                .foregroundColor(FloeColors.primary)
                .font(size.font)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .animation(.easeInOut(duration: 0.2), value: text.isEmpty)
    }
    
    private var searchBarContent: some View {
        HStack(spacing: FloeSpacing.Size.sm.value) {
            // Leading Element
            leadingElementView
            
            // Search TextField
            TextField(placeholder, text: $text)
                .font(size.font)
                .foregroundColor(textColor)
                .focused($isFocused)
                .onSubmit {
                    onSearchSubmit?(text)
                }
                .onChange(of: text) { newValue in
                    onTextChange?(newValue)
                }
                .accessibilityLabel("Search field")
                .accessibilityHint("Enter text to search")
            
            // Clear button (appears when there's text)
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(FloeColors.neutral40)
                        .frame(width: size.iconSize, height: size.iconSize)
                }
                .accessibilityLabel("Clear search")
                .transition(.scale.combined(with: .opacity))
            }
            
            // Trailing Element
            trailingElementView
        }
        .padding(size.padding)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(backgroundColor)
                .floeShadow(.soft)
        )
        .overlay(
            Group {
                if let borderColor = borderColor {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(borderColor, lineWidth: borderWidth)
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(isFocused ? FloeColors.primary : .clear, lineWidth: 2)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if !isFocused {
                isFocused = true
            }
        }
    }
    
    @ViewBuilder
    private var leadingElementView: some View {
        if let leadingElement = leadingElement {
            switch leadingElement {
            case .icon(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: size.iconSize, height: size.iconSize)
                    .foregroundColor(isFocused ? FloeColors.primary : FloeColors.neutral40)
                    .accessibilityHidden(true)
                    
            case .button(let image, let action):
                Button(action: action) {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: size.iconSize, height: size.iconSize)
                        .foregroundColor(isFocused ? FloeColors.primary : FloeColors.neutral40)
                }
                .accessibilityLabel("Search action")
            }
        }
    }
    
    @ViewBuilder
    private var trailingElementView: some View {
        if let trailingElement = trailingElement {
            switch trailingElement {
            case .icon(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: size.iconSize, height: size.iconSize)
                    .foregroundColor(isFocused ? FloeColors.primary : FloeColors.neutral40)
                    .accessibilityHidden(true)
                    
            case .button(let image, let action):
                Button(action: action) {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: size.iconSize, height: size.iconSize)
                        .foregroundColor(isFocused ? FloeColors.primary : FloeColors.neutral40)
                }
                .accessibilityLabel("Additional action")
                
            case .voiceSearch(let action):
                Button(action: action) {
                    Image(systemName: "mic.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: size.iconSize, height: size.iconSize)
                        .foregroundColor(isFocused ? FloeColors.primary : FloeColors.neutral40)
                }
                .accessibilityLabel("Voice search")
                .accessibilityHint("Activate voice search")
                
            case .filter(let action):
                Button(action: action) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: size.iconSize, height: size.iconSize)
                        .foregroundColor(isFocused ? FloeColors.primary : FloeColors.neutral40)
                }
                .accessibilityLabel("Filter options")
                .accessibilityHint("Show filter options")
            }
        }
    }
}

// MARK: - Convenience Initializers

public extension FloeSearchBar {
    static func withVoiceSearch(
        text: Binding<String>,
        placeholder: String = "Search...",
        size: Size = .medium,
        onVoiceSearch: @escaping () -> Void,
        onSearchSubmit: ((String) -> Void)? = nil
    ) -> FloeSearchBar {
        FloeSearchBar(
            text: text,
            placeholder: placeholder,
            size: size,
            trailingElement: .voiceSearch(onVoiceSearch),
            onSearchSubmit: onSearchSubmit
        )
    }
    
    static func withFilter(
        text: Binding<String>,
        placeholder: String = "Search...",
        size: Size = .medium,
        onFilter: @escaping () -> Void,
        onSearchSubmit: ((String) -> Void)? = nil
    ) -> FloeSearchBar {
        FloeSearchBar(
            text: text,
            placeholder: placeholder,
            size: size,
            trailingElement: .filter(onFilter),
            onSearchSubmit: onSearchSubmit
        )
    }
    
    static func withCancelButton(
        text: Binding<String>,
        placeholder: String = "Search...",
        size: Size = .medium,
        onSearchSubmit: ((String) -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) -> FloeSearchBar {
        FloeSearchBar(
            text: text,
            placeholder: placeholder,
            size: size,
            showsCancelButton: true,
            onSearchSubmit: onSearchSubmit,
            onCancel: onCancel
        )
    }
}

// MARK: - Previews

#Preview("Search Bar Sizes") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        FloeSearchBar(text: .constant(""), placeholder: "Small search", size: .small)
        FloeSearchBar(text: .constant(""), placeholder: "Medium search", size: .medium)
        FloeSearchBar(text: .constant(""), placeholder: "Large search", size: .large)
    }
    .padding()
}

#Preview("Basic Search Bars") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        FloeSearchBar(text: .constant(""), placeholder: "Search products...")
        FloeSearchBar(text: .constant("iPhone 15"), placeholder: "Search...")
        FloeSearchBar(
            text: .constant(""),
            placeholder: "Search recipes",
            leadingElement: .icon(Image(systemName: "magnifyingglass"))
        )
    }
    .padding()
}

#Preview("Search with Voice & Filter") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        FloeSearchBar.withVoiceSearch(
            text: .constant(""),
            placeholder: "Search with voice...",
            onVoiceSearch: { print("Voice search tapped") }
        )
        
        FloeSearchBar.withFilter(
            text: .constant(""),
            placeholder: "Search and filter...",
            onFilter: { print("Filter tapped") }
        )
        
        FloeSearchBar(
            text: .constant(""),
            placeholder: "Voice + Filter",
            trailingElement: .voiceSearch({ print("Voice search") })
        )
    }
    .padding()
}

#Preview("Search with Cancel Button") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        FloeSearchBar.withCancelButton(
            text: .constant(""),
            placeholder: "Search...",
            onCancel: { print("Search cancelled") }
        )
        
        FloeSearchBar.withCancelButton(
            text: .constant("Current search query"),
            placeholder: "Search with text...",
            onCancel: { print("Search cancelled") }
        )
        
        FloeSearchBar(
            text: .constant("Active search"),
            placeholder: "Search...",
            showsCancelButton: true,
            onCancel: { print("Cancelled") }
        )
    }
    .padding()
}

#Preview("Custom Leading Elements") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        FloeSearchBar(
            text: .constant(""),
            placeholder: "Search locations...",
            leadingElement: .icon(Image(systemName: "location"))
        )
        
        FloeSearchBar(
            text: .constant(""),
            placeholder: "Search menu...",
            leadingElement: .button(
                Image(systemName: "line.3.horizontal"),
                action: { print("Menu tapped") }
            )
        )
        
        FloeSearchBar(
            text: .constant(""),
            placeholder: "Search contacts...",
            leadingElement: .icon(Image(systemName: "person.circle"))
        )
    }
    .padding()
}

#Preview("Custom Trailing Elements") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        FloeSearchBar(
            text: .constant(""),
            placeholder: "Search...",
            trailingElement: .icon(Image(systemName: "camera"))
        )
        
        FloeSearchBar(
            text: .constant(""),
            placeholder: "Search photos...",
            trailingElement: .button(
                Image(systemName: "photo"),
                action: { print("Photo search") }
            )
        )
        
        FloeSearchBar(
            text: .constant(""),
            placeholder: "QR Code search...",
            trailingElement: .button(
                Image(systemName: "qrcode.viewfinder"),
                action: { print("QR Code scan") }
            )
        )
    }
    .padding()
}

#Preview("Advanced Search Features") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        FloeSearchBar(
            text: .constant(""),
            placeholder: "Search with all features...",
            leadingElement: .button(
                Image(systemName: "scope"),
                action: { print("Scope selection") }
            ),
            trailingElement: .voiceSearch({ print("Voice search") }),
            showsCancelButton: true
        )
        
        FloeSearchBar(
            text: .constant("machine learning"),
            placeholder: "Advanced search...",
            leadingElement: .icon(Image(systemName: "brain.head.profile")),
            trailingElement: .filter({ print("Filter options") }),
            showsCancelButton: true
        )
    }
    .padding()
}

#Preview("Custom Styled Search Bars") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        FloeSearchBar(
            text: .constant(""),
            placeholder: "Blue themed search...",
            backgroundColor: Color.blue.opacity(0.1),
            borderColor: .blue,
            borderWidth: 2.0,
            textColor: .blue
        )
        
        FloeSearchBar(
            text: .constant(""),
            placeholder: "Rounded search...",
            cornerRadius: 25,
            leadingElement: .icon(Image(systemName: "magnifyingglass"))
        )
        
        FloeSearchBar(
            text: .constant(""),
            placeholder: "Custom border...",
            backgroundColor: Color.purple.opacity(0.05),
            borderColor: .purple,
            textColor: .purple,
            trailingElement: .voiceSearch({ print("Voice") })
        )
    }
    .padding()
}

#Preview("Search with Actions") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        FloeSearchBar(
            text: .constant(""),
            placeholder: "Search with submit action...",
            onSearchSubmit: { query in
                print("Search submitted: \(query)")
            }
        )
        
        FloeSearchBar(
            text: .constant("live query"),
            placeholder: "Real-time search...",
            onTextChange: { text in
                print("Search text changed: \(text)")
            }
        )
        
        FloeSearchBar.withCancelButton(
            text: .constant("cancelable search"),
            placeholder: "Search...",
            onSearchSubmit: { query in print("Searching: \(query)") },
            onCancel: { print("Search cancelled") }
        )
    }
    .padding()
}

#Preview("E-commerce Search Examples") {
    VStack(spacing: FloeSpacing.Size.lg.value) {
        Text("E-commerce Search Patterns")
            .font(FloeFont.font(.title))
        
        FloeSearchBar.withVoiceSearch(
            text: .constant(""),
            placeholder: "Search products...",
            onVoiceSearch: { print("Voice product search") }
        )
        
        FloeSearchBar.withFilter(
            text: .constant(""),
            placeholder: "Search categories...",
            onFilter: { print("Category filters") }
        )
        
        FloeSearchBar(
            text: .constant(""),
            placeholder: "Scan barcode or search...",
            leadingElement: .icon(Image(systemName: "magnifyingglass")),
            trailingElement: .button(
                Image(systemName: "barcode.viewfinder"),
                action: { print("Barcode scan") }
            )
        )
    }
    .padding()
}

#Preview("Dark Mode") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        FloeSearchBar(
            text: .constant(""),
            placeholder: "Search in dark mode..."
        )
        
        FloeSearchBar.withVoiceSearch(
            text: .constant("dark mode query"),
            placeholder: "Voice search...",
            onVoiceSearch: { print("Voice search") }
        )
        
        FloeSearchBar.withCancelButton(
            text: .constant(""),
            placeholder: "Search with cancel...",
            onCancel: { print("Cancelled") }
        )
    }
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("Focus States") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        Text("Tap search bars to see focus states")
            .floeFont(.caption)
            .foregroundColor(.gray)
        
        FloeSearchBar(
            text: .constant(""),
            placeholder: "Focus to see border highlight..."
        )
        
        FloeSearchBar(
            text: .constant(""),
            placeholder: "Icons change color on focus...",
            leadingElement: .icon(Image(systemName: "magnifyingglass")),
            trailingElement: .voiceSearch({ print("Voice") })
        )
        
        FloeSearchBar.withCancelButton(
            text: .constant(""),
            placeholder: "Cancel button appears on focus...",
            onCancel: { print("Cancelled") }
        )
    }
    .padding()
}


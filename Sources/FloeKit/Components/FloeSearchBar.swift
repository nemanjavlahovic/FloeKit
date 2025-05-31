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

struct FloeSearchBar_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Dark mode preview (default)
            VStack(spacing: 20) {
                PreviewWrapper()
            }
            .padding()
            .previewDisplayName("Dark Mode")
            .preferredColorScheme(.dark)
            
            // Light mode preview
            VStack(spacing: 20) {
                PreviewWrapper()
            }
            .padding()
            .previewDisplayName("Light Mode")
            .preferredColorScheme(.light)
        }
        .previewLayout(.sizeThatFits)
    }
    
    struct PreviewWrapper: View {
        @State private var basicSearch = ""
        @State private var voiceSearch = ""
        @State private var filterSearch = ""
        @State private var cancelSearch = ""
        @State private var customSearch = ""
        
        var body: some View {
            VStack(spacing: 20) {
                Text("FloeSearchBar Examples")
                    .font(.headline)
                    .padding()
                
                // Basic search bar
                VStack(alignment: .leading, spacing: 8) {
                    Text("Basic Search")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    FloeSearchBar(
                        text: $basicSearch,
                        placeholder: "Search products..."
                    )
                }
                
                // Search bar with voice search
                VStack(alignment: .leading, spacing: 8) {
                    Text("With Voice Search")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    FloeSearchBar.withVoiceSearch(
                        text: $voiceSearch,
                        placeholder: "Search with voice...",
                        onVoiceSearch: {
                            print("Voice search activated")
                        },
                        onSearchSubmit: { query in
                            print("Searching for: \(query)")
                        }
                    )
                }
                
                // Search bar with filter
                VStack(alignment: .leading, spacing: 8) {
                    Text("With Filter")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    FloeSearchBar.withFilter(
                        text: $filterSearch,
                        placeholder: "Search and filter...",
                        onFilter: {
                            print("Filter activated")
                        }
                    )
                }
                
                // Search bar with cancel button
                VStack(alignment: .leading, spacing: 8) {
                    Text("With Cancel Button")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    FloeSearchBar.withCancelButton(
                        text: $cancelSearch,
                        placeholder: "Search with cancel...",
                        onCancel: {
                            print("Search cancelled")
                        }
                    )
                }
                
                // Custom styled search bar
                VStack(alignment: .leading, spacing: 8) {
                    Text("Custom Styling")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    FloeSearchBar(
                        text: $customSearch,
                        placeholder: "Custom search...",
                        size: .large,
                        backgroundColor: FloeColors.accent.opacity(0.1),
                        borderColor: FloeColors.accent,
                        borderWidth: 2,
                        textColor: FloeColors.primary,
                        cornerRadius: 20,
                        leadingElement: .button(Image(systemName: "magnifyingglass.circle.fill")) {
                            print("Custom search button tapped")
                        },
                        trailingElement: .button(Image(systemName: "qrcode.viewfinder")) {
                            print("QR code scanner activated")
                        }
                    )
                }
            }
        }
    }
} 
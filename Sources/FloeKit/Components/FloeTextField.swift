import SwiftUI

public struct FloeTextField: View {
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
    
    @Binding private var text: String
    private let placeholder: String
    private let size: Size
    private let backgroundColor: Color
    private let borderColor: Color?
    private let borderWidth: CGFloat
    private let textColor: Color
    private let cornerRadius: CGFloat
    private let leadingIcon: Image?
    private let trailingIcon: Image?
    private let isSecure: Bool
    private let characterLimit: Int?
    private let errorMessage: String?
    private let onCommit: (() -> Void)?
    
    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    public init(
        text: Binding<String>,
        placeholder: String,
        size: Size = .medium,
        backgroundColor: Color = FloeColors.surface,
        borderColor: Color? = nil,
        borderWidth: CGFloat = 1.0,
        textColor: Color = FloeColors.primary,
        cornerRadius: CGFloat = 14,
        leadingIcon: Image? = nil,
        trailingIcon: Image? = nil,
        isSecure: Bool = false,
        characterLimit: Int? = nil,
        errorMessage: String? = nil,
        onCommit: (() -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.size = size
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.textColor = textColor
        self.cornerRadius = cornerRadius
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
        self.isSecure = isSecure
        self.characterLimit = characterLimit
        self.errorMessage = errorMessage
        self.onCommit = onCommit
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: FloeSpacing.Size.xs.value) {
            HStack(spacing: FloeSpacing.Size.sm.value) {
                if let leadingIcon = leadingIcon {
                    leadingIcon
                        .resizable()
                        .scaledToFit()
                        .frame(width: size.iconSize, height: size.iconSize)
                        .foregroundColor(isFocused ? .accentColor : .gray)
                }
                
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .textFieldStyle(.plain)
                        .font(size.font)
                        .foregroundColor(textColor)
                        .focused($isFocused)
                        .onSubmit { onCommit?() }
                } else {
                    TextField(placeholder, text: $text)
                        .textFieldStyle(.plain)
                        .font(size.font)
                        .foregroundColor(textColor)
                        .focused($isFocused)
                        .onSubmit { onCommit?() }
                }
                
                if let trailingIcon = trailingIcon {
                    trailingIcon
                        .resizable()
                        .scaledToFit()
                        .frame(width: size.iconSize, height: size.iconSize)
                        .foregroundColor(isFocused ? .accentColor : .gray)
                }
                
                if !text.isEmpty {
                    Button(action: { text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .frame(width: size.iconSize, height: size.iconSize)
                    }
                }
            }
            .padding(size.padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(backgroundColor)
                    .floeShadow(.medium)
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
                    .stroke(isFocused ? Color.accentColor : .clear, lineWidth: 2)
            )
            
            if let errorMessage = errorMessage, !errorMessage.isEmpty {
                Text(errorMessage)
                    .floeFont(.caption)
                    .foregroundColor(.red)
                    .padding(.leading, 4)
            }
            
            if let limit = characterLimit {
                Text("\(text.count)/\(limit)")
                    .floeFont(.caption)
                    .foregroundColor(text.count > limit ? .red : .gray)
                    .padding(.leading, 4)
            }
        }
    }
}

// MARK: - Previews

struct FloeTextField_Previews: PreviewProvider {
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
        @State private var defaultText = ""
        @State private var searchText = "With Icons"
        @State private var passwordText = "Password123"
        @State private var errorText = "Error state"
        @State private var bioText = "Character limit"
        
        var body: some View {
            VStack(spacing: 20) {
                FloeTextField(
                    text: $defaultText,
                    placeholder: "Default TextField"
                )
                
                FloeTextField(
                    text: $searchText,
                    placeholder: "Search...",
                    leadingIcon: Image(systemName: "magnifyingglass"),
                    trailingIcon: Image(systemName: "mic.fill")
                )
                
                FloeTextField(
                    text: $passwordText,
                    placeholder: "Enter password",
                    leadingIcon: Image(systemName: "lock.fill"),
                    isSecure: true
                )
                
                FloeTextField(
                    text: $errorText,
                    placeholder: "Username",
                    leadingIcon: Image(systemName: "person.fill"),
                    errorMessage: "Username is already taken"
                )
                
                FloeTextField(
                    text: $bioText,
                    placeholder: "Bio",
                    characterLimit: 100
                )
            }
        }
    }
} 

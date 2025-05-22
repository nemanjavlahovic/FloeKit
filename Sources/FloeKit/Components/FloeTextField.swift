import SwiftUI

public struct FloeTextField: View {
    public enum Size {
        case small, medium, large
        
        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
            case .medium: return EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
            case .large: return EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
            }
        }
        
        var font: Font {
            switch self {
            case .small: return .body
            case .medium: return .body
            case .large: return .title3
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
    private let keyboardType: UIKeyboardType
    private let textContentType: UITextContentType?
    private let characterLimit: Int?
    private let errorMessage: String?
    private let onCommit: (() -> Void)?
    
    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    public init(
        text: Binding<String>,
        placeholder: String,
        size: Size = .medium,
        backgroundColor: Color = Color(.systemGray6),
        borderColor: Color? = nil,
        borderWidth: CGFloat = 1.0,
        textColor: Color = .primary,
        cornerRadius: CGFloat = 14,
        leadingIcon: Image? = nil,
        trailingIcon: Image? = nil,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil,
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
        self.keyboardType = keyboardType
        self.textContentType = textContentType
        self.characterLimit = characterLimit
        self.errorMessage = errorMessage
        self.onCommit = onCommit
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
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
                        .keyboardType(keyboardType)
                        .textContentType(textContentType)
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
                    .shadow(color: .black.opacity(colorScheme == .dark ? 0.2 : 0.08), radius: 10, x: 0, y: 4)
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
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.leading, 4)
            }
            
            if let limit = characterLimit {
                Text("\(text.count)/\(limit)")
                    .font(.caption)
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
            VStack(spacing: 20) {
                PreviewWrapper()
            }
            .padding()
            .previewDisplayName("Light Mode")
            .environment(\.colorScheme, .light)
            
            VStack(spacing: 20) {
                PreviewWrapper()
            }
            .padding()
            .previewDisplayName("Dark Mode")
            .environment(\.colorScheme, .dark)
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

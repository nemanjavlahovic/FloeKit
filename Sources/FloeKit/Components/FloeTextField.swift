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

#Preview("Text Field Sizes") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        FloeTextField(text: .constant("Small text field"), placeholder: "Small", size: .small)
        FloeTextField(text: .constant("Medium text field"), placeholder: "Medium", size: .medium)
        FloeTextField(text: .constant("Large text field"), placeholder: "Large", size: .large)
    }
    .padding()
}

#Preview("Text Field Placeholders") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        FloeTextField(text: .constant(""), placeholder: "Enter your name")
        FloeTextField(text: .constant(""), placeholder: "Email address")
        FloeTextField(text: .constant(""), placeholder: "Phone number")
        FloeTextField(text: .constant(""), placeholder: "Search...")
    }
    .padding()
}

#Preview("Text Fields with Icons") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        FloeTextField(
            text: .constant(""),
            placeholder: "Search",
            leadingIcon: Image(systemName: "magnifyingglass")
        )
        
        FloeTextField(
            text: .constant("john.doe@example.com"),
            placeholder: "Email",
            leadingIcon: Image(systemName: "envelope"),
            trailingIcon: Image(systemName: "checkmark.circle.fill")
        )
        
        FloeTextField(
            text: .constant(""),
            placeholder: "Location",
            leadingIcon: Image(systemName: "location"),
            trailingIcon: Image(systemName: "chevron.down")
        )
    }
    .padding()
}

#Preview("Secure Text Fields") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        FloeTextField(
            text: .constant(""),
            placeholder: "Password",
            leadingIcon: Image(systemName: "lock"),
            isSecure: true
        )
        
        FloeTextField(
            text: .constant("mypassword"),
            placeholder: "Current Password",
            leadingIcon: Image(systemName: "lock.shield"),
            isSecure: true
        )
        
        FloeTextField(
            text: .constant(""),
            placeholder: "Confirm Password",
            leadingIcon: Image(systemName: "lock.fill"),
            isSecure: true
        )
    }
    .padding()
}

#Preview("Text Fields with Character Limits") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        FloeTextField(
            text: .constant("Hello world"),
            placeholder: "Tweet",
            characterLimit: 280
        )
        
        FloeTextField(
            text: .constant("This is a very long message that exceeds the limit"),
            placeholder: "Short message",
            characterLimit: 25
        )
        
        FloeTextField(
            text: .constant("John"),
            placeholder: "Username",
            leadingIcon: Image(systemName: "person"),
            characterLimit: 20
        )
    }
    .padding()
}

#Preview("Text Fields with Errors") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        FloeTextField(
            text: .constant("invalid-email"),
            placeholder: "Email",
            leadingIcon: Image(systemName: "envelope"),
            errorMessage: "Please enter a valid email address"
        )
        
        FloeTextField(
            text: .constant("123"),
            placeholder: "Password",
            leadingIcon: Image(systemName: "lock"),
            isSecure: true,
            errorMessage: "Password must be at least 8 characters"
        )
        
        FloeTextField(
            text: .constant(""),
            placeholder: "Required field",
            errorMessage: "This field is required"
        )
    }
    .padding()
}

#Preview("Custom Styled Text Fields") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        FloeTextField(
            text: .constant("Custom background"),
            placeholder: "Custom style",
            backgroundColor: Color.blue.opacity(0.1),
            borderColor: .blue,
            borderWidth: 2.0,
            textColor: .blue
        )
        
        FloeTextField(
            text: .constant("Rounded text field"),
            placeholder: "Very rounded",
            cornerRadius: 25
        )
        
        FloeTextField(
            text: .constant("Purple theme"),
            placeholder: "Custom colors",
            backgroundColor: Color.purple.opacity(0.1),
            borderColor: .purple,
            textColor: .purple,
            leadingIcon: Image(systemName: "star.fill")
        )
    }
    .padding()
}

#Preview("Interactive States") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        FloeTextField(
            text: .constant(""),
            placeholder: "Focus me",
            leadingIcon: Image(systemName: "textformat")
        )
        
        FloeTextField(
            text: .constant("Clear me"),
            placeholder: "Has clear button",
            trailingIcon: Image(systemName: "info.circle")
        )
        
        FloeTextField(
            text: .constant("Type here and watch the counter"),
            placeholder: "Character counter",
            characterLimit: 50
        )
    }
    .padding()
}

#Preview("Form Example") {
    VStack(spacing: FloeSpacing.Size.lg.value) {
        Text("Sign Up Form")
            .font(FloeFont.font(.title))
        
        FloeTextField(
            text: .constant(""),
            placeholder: "Full Name",
            leadingIcon: Image(systemName: "person")
        )
        
        FloeTextField(
            text: .constant(""),
            placeholder: "Email",
            leadingIcon: Image(systemName: "envelope")
        )
        
        FloeTextField(
            text: .constant(""),
            placeholder: "Phone Number",
            leadingIcon: Image(systemName: "phone")
        )
        
        FloeTextField(
            text: .constant(""),
            placeholder: "Password",
            leadingIcon: Image(systemName: "lock"),
            isSecure: true,
            characterLimit: 50
        )
        
        FloeTextField(
            text: .constant(""),
            placeholder: "Bio (Optional)",
            size: .large,
            characterLimit: 150
        )
    }
    .padding()
}

#Preview("Dark Mode") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        FloeTextField(
            text: .constant("Dark mode text"),
            placeholder: "Placeholder text",
            leadingIcon: Image(systemName: "moon")
        )
        
        FloeTextField(
            text: .constant(""),
            placeholder: "Search in dark mode",
            leadingIcon: Image(systemName: "magnifyingglass"),
            trailingIcon: Image(systemName: "mic")
        )
        
        FloeTextField(
            text: .constant("error@example.com"),
            placeholder: "Email",
            leadingIcon: Image(systemName: "envelope"),
            errorMessage: "Invalid email format"
        )
    }
    .padding()
    .preferredColorScheme(.dark)
}


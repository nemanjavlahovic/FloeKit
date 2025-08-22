import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public struct FloeTextView: View {
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
            case .large: return FloeFont.font(.subheadline)
            }
        }
        
        var minHeight: CGFloat {
            switch self {
            case .small: return 80
            case .medium: return 120
            case .large: return 160
            }
        }
    }
    
    public enum ExpansionStyle {
        case none
        case readMore(previewLines: Int)
        case expandable(maxLines: Int?)
        
        var previewLineLimit: Int? {
            switch self {
            case .none: return nil
            case .readMore(let lines): return lines
            case .expandable(let maxLines): return maxLines
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
    private let expansionStyle: ExpansionStyle
    private let characterLimit: Int?
    private let lineLimit: Int?
    private let showCharacterCount: Bool
    private let isEditable: Bool
    private let attributedText: AttributedString?
    private let onTextChange: ((String) -> Void)?
    
    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    @State private var isExpanded = false
    @State private var textHeight: CGFloat = 0
    @State private var needsExpansion = false
    
    // MARK: - Initializers
    
    /// Initialize with plain text binding
    public init(
        text: Binding<String>,
        placeholder: String = "Enter text...",
        size: Size = .medium,
        backgroundColor: Color = FloeColors.surface,
        borderColor: Color? = nil,
        borderWidth: CGFloat = 1.0,
        textColor: Color = FloeColors.primary,
        cornerRadius: CGFloat = 14,
        expansionStyle: ExpansionStyle = .none,
        characterLimit: Int? = nil,
        lineLimit: Int? = nil,
        showCharacterCount: Bool = false,
        isEditable: Bool = true,
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
        self.expansionStyle = expansionStyle
        self.characterLimit = characterLimit
        self.lineLimit = lineLimit
        self.showCharacterCount = showCharacterCount
        self.isEditable = isEditable
        self.attributedText = nil
        self.onTextChange = onTextChange
    }
    
    /// Initialize with attributed text (read-only)
    public init(
        attributedText: AttributedString,
        size: Size = .medium,
        backgroundColor: Color = FloeColors.surface,
        borderColor: Color? = nil,
        borderWidth: CGFloat = 1.0,
        cornerRadius: CGFloat = 14,
        expansionStyle: ExpansionStyle = .readMore(previewLines: 3)
    ) {
        self._text = .constant("")
        self.placeholder = ""
        self.size = size
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.textColor = Color.primary
        self.cornerRadius = cornerRadius
        self.expansionStyle = expansionStyle
        self.characterLimit = nil
        self.lineLimit = nil
        self.showCharacterCount = false
        self.isEditable = false
        self.attributedText = attributedText
        self.onTextChange = nil
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: FloeSpacing.Size.sm.value) {
            contentView
            bottomAccessoryView
        }
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(isEditable ? "Text editor" : "Text content")
        .accessibilityHint(isEditable ? "Double tap to edit text" : (needsExpansionControl ? "Double tap to expand or collapse" : ""))
        .accessibilityValue(text.isEmpty ? placeholder : text)
    }
    
    // MARK: - Content View
    
    @ViewBuilder
    private var contentView: some View {
        if isEditable {
            editableTextView
        } else {
            readOnlyTextView
        }
    }
    
    private var editableTextView: some View {
        ZStack(alignment: .topLeading) {
            // Background with border and shadow
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(backgroundColor)
                .floeShadow(.soft)
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
            
            // Text editing area
            VStack(alignment: .leading, spacing: 0) {
                if #available(iOS 16.0, macOS 13.0, *) {
                    TextEditor(text: $text)
                        .font(size.font)
                        .foregroundColor(textColor)
                        .focused($isFocused)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .onChange(of: text) { newValue in
                            handleTextChange(newValue)
                        }
                } else {
                    TextEditor(text: $text)
                        .font(size.font)
                        .foregroundColor(textColor)
                        .focused($isFocused)
                        .background(Color.clear)
                        .onAppear {
                            #if canImport(UIKit) && !os(macOS)
                            UITextView.appearance().backgroundColor = .clear
                            #endif
                        }
                        .onChange(of: text) { newValue in
                            handleTextChange(newValue)
                        }
                }
                
                // Placeholder overlay
                if text.isEmpty {
                    Text(placeholder)
                        .font(size.font)
                        .foregroundColor(.gray)
                        .allowsHitTesting(false)
                        .padding(.top, 8)
                        .padding(.leading, 4)
                }
            }
            .padding(size.padding)
        }
        .frame(minHeight: size.minHeight)
        .fixedSize(horizontal: false, vertical: true)
    }
    
    @ViewBuilder
    private var readOnlyTextView: some View {
        if let attributedText = attributedText {
            VStack(alignment: .leading, spacing: FloeSpacing.Size.sm.value) {
                Text(attributedText)
                    .font(size.font)
                    .lineLimit(currentLineLimit)
                    .padding(size.padding)
                    .frame(maxWidth: .infinity, alignment: .leading)
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
                
                if needsExpansionControl {
                    expansionButton
                }
            }
            .onAppear {
                updateExpansionStateForAttributedText()
            }
        } else {
            VStack(alignment: .leading, spacing: FloeSpacing.Size.sm.value) {
                Text(text)
                    .font(size.font)
                    .foregroundColor(textColor)
                    .lineLimit(currentLineLimit)
                    .padding(size.padding)
                    .frame(maxWidth: .infinity, alignment: .leading)
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
                
                if needsExpansionControl {
                    expansionButton
                }
            }
            .onAppear {
                updateExpansionState()
            }
        }
    }
    
    // MARK: - Bottom Accessory View
    
    @ViewBuilder
    private var bottomAccessoryView: some View {
        if showCharacterCount || hasCharacterLimit || (isEditable && needsExpansionControl) {
            HStack {
                if isEditable && needsExpansionControl {
                    expansionButton
                }
                
                Spacer()
                
                if showCharacterCount || hasCharacterLimit {
                    characterCountView
                }
            }
            .floePadding(.horizontal, FloeSpacing.Size.xs)
        }
    }
    
    private var characterCountView: some View {
        Group {
            if let limit = characterLimit {
                Text("\(text.count)/\(limit)")
                    .floeFont(.caption)
                    .foregroundColor(text.count > limit ? .red : .gray)
            } else {
                Text("\(text.count)")
                    .floeFont(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var expansionButton: some View {
        Button(action: { isExpanded.toggle() }) {
            Text(isExpanded ? "Read less" : "Read more")
                .floeFont(.caption)
                .foregroundColor(.accentColor)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Computed Properties
    
    private var currentLineLimit: Int? {
        switch expansionStyle {
        case .none:
            return lineLimit
        case .readMore(let previewLines):
            return isExpanded ? nil : previewLines
        case .expandable(let maxLines):
            return isExpanded ? maxLines : expansionStyle.previewLineLimit
        }
    }
    
    private var needsExpansionControl: Bool {
        switch expansionStyle {
        case .none:
            return false
        case .readMore, .expandable:
            if attributedText != nil {
                // For attributed text, we need to check if expansion is needed
                return needsExpansion
            } else {
                // For regular text, check line count
                return needsExpansion || text.components(separatedBy: .newlines).count > 3
            }
        }
    }
    
    private var hasCharacterLimit: Bool {
        characterLimit != nil
    }
    
    // MARK: - Helper Methods
    
    private func handleTextChange(_ newValue: String) {
        // Apply character limit if specified
        if let limit = characterLimit, newValue.count > limit {
            text = String(newValue.prefix(limit))
            return
        }
        
        // Check if expansion control is needed
        updateExpansionState()
        
        // Call the text change handler
        onTextChange?(newValue)
    }
    
    private func updateExpansionState() {
        let lineCount = text.components(separatedBy: .newlines).count
        let characterCount = text.count
        
        switch expansionStyle {
        case .none:
            needsExpansion = false
        case .readMore(let previewLines):
            // Consider both explicit line breaks and estimated wrapped lines
            let estimatedWrappedLines = max(lineCount, characterCount / 50) // Rough estimate: 50 chars per line
            needsExpansion = estimatedWrappedLines > previewLines
        case .expandable(let maxLines):
            if let maxLines = maxLines {
                let estimatedWrappedLines = max(lineCount, characterCount / 50)
                needsExpansion = estimatedWrappedLines > maxLines
            } else {
                needsExpansion = lineCount > 3 || characterCount > 150
            }
        }
    }
    
    private func updateExpansionStateForAttributedText() {
        guard let attributedText = attributedText else { return }
        
        // Convert AttributedString to String for line counting
        let textContent = String(attributedText.characters)
        let lineCount = textContent.components(separatedBy: .newlines).count
        let characterCount = textContent.count
        
        switch expansionStyle {
        case .none:
            needsExpansion = false
        case .readMore(let previewLines):
            // For attributed text, consider both line breaks and character count
            let estimatedWrappedLines = max(lineCount, characterCount / 50)
            needsExpansion = estimatedWrappedLines > previewLines
        case .expandable(let maxLines):
            if let maxLines = maxLines {
                let estimatedWrappedLines = max(lineCount, characterCount / 50)
                needsExpansion = estimatedWrappedLines > maxLines
            } else {
                needsExpansion = lineCount > 3 || characterCount > 150
            }
        }
    }
}

// MARK: - Convenience Initializers

public extension FloeTextView {
    /// Create a read-only text view with expansion capability
    static func readOnly(
        text: String,
        size: Size = .medium,
        backgroundColor: Color = FloeColors.surface,
        expansionStyle: ExpansionStyle = .readMore(previewLines: 3)
    ) -> FloeTextView {
        return FloeTextView(
            text: .constant(text),
            size: size,
            backgroundColor: backgroundColor,
            expansionStyle: expansionStyle,
            isEditable: false
        )
    }
    
    /// Create a read-only attributed text view with expansion capability
    static func attributedText(
        _ attributedText: AttributedString,
        size: Size = .medium,
        backgroundColor: Color = FloeColors.surface,
        expansionStyle: ExpansionStyle = .readMore(previewLines: 3)
    ) -> FloeTextView {
        return FloeTextView(
            attributedText: attributedText,
            size: size,
            backgroundColor: backgroundColor,
            expansionStyle: expansionStyle
        )
    }
    
    /// Create an editable text view with character limit
    static func withCharacterLimit(
        text: Binding<String>,
        placeholder: String = "Enter text...",
        characterLimit: Int,
        size: Size = .medium
    ) -> FloeTextView {
        return FloeTextView(
            text: text,
            placeholder: placeholder,
            size: size,
            characterLimit: characterLimit,
            showCharacterCount: true
        )
    }
}


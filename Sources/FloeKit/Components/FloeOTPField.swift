import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public struct FloeOTPField: View {
    @Binding var text: String
    @FocusState private var focusedField: Int?
    
    private let numberOfFields: Int
    private let fieldWidth: CGFloat
    private let fieldHeight: CGFloat
    private let spacing: CGFloat
    private let cornerRadius: CGFloat
    private let font: Font
    private let borderColor: Color
    private let focusedBorderColor: Color
    private let backgroundColor: Color
    private let textColor: Color
    private let autoSubmit: Bool
    private let isSecure: Bool
    private let hapticFeedback: Bool
    private let onComplete: ((String) -> Void)?
    private let onTextChange: ((String) -> Void)?
    
    @State private var fields: [String] = []
    
    public init(
        text: Binding<String>,
        numberOfFields: Int = 6,
        fieldWidth: CGFloat = 45,
        fieldHeight: CGFloat = 56,
        spacing: CGFloat = 8,
        cornerRadius: CGFloat = 12,
        font: Font = .system(size: 24, weight: .semibold, design: .rounded),
        borderColor: Color = FloeColors.neutral20,
        focusedBorderColor: Color = FloeColors.primary,
        backgroundColor: Color = FloeColors.surface,
        textColor: Color = FloeColors.neutral10,
        autoSubmit: Bool = true,
        isSecure: Bool = false,
        hapticFeedback: Bool = true,
        onComplete: ((String) -> Void)? = nil,
        onTextChange: ((String) -> Void)? = nil
    ) {
        self._text = text
        self.numberOfFields = numberOfFields
        self.fieldWidth = fieldWidth
        self.fieldHeight = fieldHeight
        self.spacing = spacing
        self.cornerRadius = cornerRadius
        self.font = font
        self.borderColor = borderColor
        self.focusedBorderColor = focusedBorderColor
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.autoSubmit = autoSubmit
        self.isSecure = isSecure
        self.hapticFeedback = hapticFeedback
        self.onComplete = onComplete
        self.onTextChange = onTextChange
        
        self._fields = State(initialValue: Array(repeating: "", count: numberOfFields))
    }
    
    public var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<numberOfFields, id: \.self) { index in
                OTPFieldCell(
                    text: binding(for: index),
                    index: index,
                    isSecure: isSecure,
                    fieldWidth: fieldWidth,
                    fieldHeight: fieldHeight,
                    cornerRadius: cornerRadius,
                    font: font,
                    borderColor: borderColor,
                    focusedBorderColor: focusedBorderColor,
                    backgroundColor: backgroundColor,
                    textColor: textColor,
                    isFocused: focusedField == index,
                    onTextChange: { newValue in
                        handleTextChange(at: index, newValue: newValue)
                    },
                    onBackspace: {
                        handleBackspace(at: index)
                    }
                )
                .focused($focusedField, equals: index)
            }
        }
        .onAppear {
            setupInitialFields()
        }
        .onChange(of: text) { newValue in
            if newValue.count <= numberOfFields {
                updateFieldsFromText(newValue)
            }
        }
    }
    
    private func binding(for index: Int) -> Binding<String> {
        Binding(
            get: {
                guard index < fields.count else { return "" }
                return fields[index]
            },
            set: { newValue in
                guard index < fields.count else { return }
                fields[index] = newValue
            }
        )
    }
    
    private func setupInitialFields() {
        if !text.isEmpty {
            updateFieldsFromText(text)
        }
    }
    
    private func updateFieldsFromText(_ text: String) {
        let characters = Array(text.prefix(numberOfFields))
        for i in 0..<numberOfFields {
            if i < characters.count {
                fields[i] = String(characters[i])
            } else {
                fields[i] = ""
            }
        }
    }
    
    private func handleTextChange(at index: Int, newValue: String) {
        guard index < fields.count else { return }
        
        if hapticFeedback {
            #if os(iOS)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
        }
        
        if newValue.count > 1 {
            let filtered = String(newValue.prefix(1))
            fields[index] = filtered
            
            if newValue.count > 1 && index < numberOfFields - 1 {
                let remainingText = String(newValue.dropFirst())
                for (offset, char) in remainingText.enumerated() {
                    let nextIndex = index + offset + 1
                    if nextIndex < numberOfFields {
                        fields[nextIndex] = String(char)
                        if nextIndex == numberOfFields - 1 {
                            focusedField = nextIndex
                        }
                    }
                }
                if index + remainingText.count < numberOfFields {
                    focusedField = min(index + remainingText.count, numberOfFields - 1)
                }
            }
        } else {
            fields[index] = newValue
            
            if !newValue.isEmpty && index < numberOfFields - 1 {
                focusedField = index + 1
            }
        }
        
        updateText()
    }
    
    private func handleBackspace(at index: Int) {
        guard index < fields.count else { return }
        
        if fields[index].isEmpty && index > 0 {
            focusedField = index - 1
            fields[index - 1] = ""
        } else {
            fields[index] = ""
        }
        
        updateText()
    }
    
    private func updateText() {
        let newText = fields.joined()
        text = newText
        onTextChange?(newText)
        
        if newText.count == numberOfFields && autoSubmit {
            onComplete?(newText)
            
            if hapticFeedback {
                #if os(iOS)
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                #endif
            }
        }
    }
}

private struct OTPFieldCell: View {
    @Binding var text: String
    let index: Int
    let isSecure: Bool
    let fieldWidth: CGFloat
    let fieldHeight: CGFloat
    let cornerRadius: CGFloat
    let font: Font
    let borderColor: Color
    let focusedBorderColor: Color
    let backgroundColor: Color
    let textColor: Color
    let isFocused: Bool
    let onTextChange: (String) -> Void
    let onBackspace: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(isFocused ? focusedBorderColor : borderColor, lineWidth: isFocused ? 2 : 1)
                )
                .frame(width: fieldWidth, height: fieldHeight)
            
            if isSecure && !text.isEmpty {
                Circle()
                    .fill(textColor)
                    .frame(width: 12, height: 12)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
            } else {
                TextField("", text: $text)
                    .font(font)
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.center)
                    .frame(width: fieldWidth, height: fieldHeight)
                    #if os(iOS)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    #endif
                    .onChange(of: text) { newValue in
                        onTextChange(newValue)
                    }
                    .onSubmit {
                        if text.isEmpty {
                            onBackspace()
                        }
                    }
            }
            
            if isFocused && text.isEmpty {
                RoundedRectangle(cornerRadius: 2)
                    .fill(focusedBorderColor)
                    .frame(width: 2, height: 20)
                    .opacity(isAnimating ? 0.3 : 1.0)
            }
        }
        .onAppear {
            if isFocused {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
        }
        .onChange(of: isFocused) { newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            } else {
                isAnimating = false
            }
        }
        .onChange(of: text) { _ in
            if !text.isEmpty {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isAnimating = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isAnimating = false
                }
            }
        }
    }
}

// MARK: - Convenience Initializers

public extension FloeOTPField {
    static func pin(
        text: Binding<String>,
        numberOfFields: Int = 4,
        onComplete: ((String) -> Void)? = nil
    ) -> FloeOTPField {
        FloeOTPField(
            text: text,
            numberOfFields: numberOfFields,
            isSecure: true,
            onComplete: onComplete
        )
    }
    
    static func verificationCode(
        text: Binding<String>,
        numberOfFields: Int = 6,
        onComplete: ((String) -> Void)? = nil
    ) -> FloeOTPField {
        FloeOTPField(
            text: text,
            numberOfFields: numberOfFields,
            font: .system(size: 28, weight: .bold, design: .monospaced),
            onComplete: onComplete
        )
    }
    
    static func smsCode(
        text: Binding<String>,
        onComplete: ((String) -> Void)? = nil
    ) -> FloeOTPField {
        FloeOTPField(
            text: text,
            numberOfFields: 6,
            fieldWidth: 40,
            fieldHeight: 48,
            spacing: 6,
            font: .system(size: 20, weight: .medium),
            onComplete: onComplete
        )
    }
}

// MARK: - View Extension

public extension View {
    @available(iOS 16.0, macOS 13.0, *)
    func floeOTPField(
        text: Binding<String>,
        numberOfFields: Int = 6,
        isPresented: Binding<Bool>,
        title: String = "Enter Code",
        message: String? = nil,
        onComplete: @escaping (String) -> Void
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let message = message {
                        Text(message)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                FloeOTPField(
                    text: text,
                    numberOfFields: numberOfFields,
                    onComplete: { code in
                        isPresented.wrappedValue = false
                        onComplete(code)
                    }
                )
                
                Spacer()
            }
            .padding()
            .presentationDetents([.height(280)])
        }
    }
}

// MARK: - Previews

struct FloeOTPField_Previews: PreviewProvider {
    static var previews: some View {
        OTPFieldPreviewView()
    }
    
    struct OTPFieldPreviewView: View {
        @State private var otpCode = ""
        @State private var pinCode = ""
        @State private var smsCode = ""
        @State private var customCode = ""
        @State private var showingAlert = false
        @State private var alertMessage = ""
        
        var body: some View {
            ScrollView {
                VStack(spacing: 40) {
                    Text("FloeOTPField Examples")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Standard OTP")
                            .font(.headline)
                        
                        FloeOTPField(
                            text: $otpCode,
                            onComplete: { code in
                                alertMessage = "OTP Complete: \(code)"
                                showingAlert = true
                            }
                        )
                        
                        Text("Entered: \(otpCode)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("PIN Code (Secure)")
                            .font(.headline)
                        
                        FloeOTPField.pin(
                            text: $pinCode,
                            onComplete: { code in
                                alertMessage = "PIN Complete: \(code)"
                                showingAlert = true
                            }
                        )
                        
                        Text("Entered: \(pinCode)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("SMS Verification")
                            .font(.headline)
                        
                        FloeOTPField.smsCode(
                            text: $smsCode,
                            onComplete: { code in
                                alertMessage = "SMS Code Complete: \(code)"
                                showingAlert = true
                            }
                        )
                        
                        Text("Entered: \(smsCode)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Custom Style")
                            .font(.headline)
                        
                        FloeOTPField(
                            text: $customCode,
                            numberOfFields: 5,
                            fieldWidth: 50,
                            fieldHeight: 60,
                            spacing: 12,
                            cornerRadius: 16,
                            font: .system(size: 32, weight: .heavy, design: .rounded),
                            borderColor: .purple.opacity(0.3),
                            focusedBorderColor: .purple,
                            backgroundColor: .purple.opacity(0.05),
                            textColor: .purple,
                            onComplete: { code in
                                alertMessage = "Custom Code Complete: \(code)"
                                showingAlert = true
                            }
                        )
                        
                        Text("Entered: \(customCode)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    FloeButton("Clear All") {
                        otpCode = ""
                        pinCode = ""
                        smsCode = ""
                        customCode = ""
                    }
                }
                .padding()
            }
            .alert("Code Submitted", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
}
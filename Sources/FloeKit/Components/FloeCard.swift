import SwiftUI

public struct FloeCard<Content: View>: View {
    private let content: Content
    private let backgroundColor: Color
    private let cornerRadius: CGFloat
    private let shadowStyle: FloeShadow.Style
    private let borderColor: Color?
    private let borderWidth: CGFloat
    private let padding: EdgeInsets
    
    public init(
        backgroundColor: Color = FloeColors.surface,
        cornerRadius: CGFloat = 16,
        shadowStyle: FloeShadow.Style = .medium,
        borderColor: Color? = nil,
        borderWidth: CGFloat = 1,
        padding: FloeSpacing.PaddingStyle = .card,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.shadowStyle = shadowStyle
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.padding = padding.edgeInsets
    }
    
    public var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(backgroundColor)
                    .floeShadow(shadowStyle)
            )
            .overlay(
                Group {
                    if let borderColor = borderColor {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(borderColor, lineWidth: borderWidth)
                    }
                }
            )
    }
}

// MARK: - Previews

struct FloeCard_Previews: PreviewProvider {
    struct AdaptivePreview: View {
        @Environment(\.colorScheme) var colorScheme
        var body: some View {
            VStack(spacing: 20) {
                FloeCard {
                    Text("Basic Card")
                        .font(.headline)
                }
                
                FloeCard(
                    backgroundColor: FloeColors.primary.opacity(0.1),
                    cornerRadius: 20,
                    shadowStyle: .elevated,
                    borderColor: FloeColors.primary
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Custom Styled Card")
                            .font(.headline)
                        Text("With custom background, border, and shadow")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                FloeCard {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(FloeColors.accent)
                            Text("Featured Content")
                                .font(.headline)
                        }
                        
                        Text("This card contains more complex content with multiple elements and proper spacing.")
                            .font(.body)
                        
                        HStack {
                            Button("Learn More") { }
                            .buttonStyle(.bordered)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right")
                                .foregroundColor(FloeColors.primary)
                        }
                    }
                }
            }
            .padding()
        }
    }
    static var previews: some View {
        Group {
            // Dark mode preview (default)
            AdaptivePreview()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
            
            // Light mode preview
            AdaptivePreview()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
        }
        .previewLayout(.sizeThatFits)
    }
} 

import SwiftUI

public struct FloeCard<Content: View>: View {
    private let content: Content
    private let backgroundColor: Color
    private let cornerRadius: CGFloat
    private let shadowColor: Color
    private let shadowRadius: CGFloat
    private let shadowOffset: CGPoint
    private let borderColor: Color?
    private let borderWidth: CGFloat
    private let padding: EdgeInsets
    
    public init(
        backgroundColor: Color = Color(.systemBackground),
        cornerRadius: CGFloat = 16,
        shadowColor: Color = .black,
        shadowRadius: CGFloat = 10,
        shadowOffset: CGPoint = CGPoint(x: 0, y: 4),
        borderColor: Color? = nil,
        borderWidth: CGFloat = 1,
        padding: EdgeInsets = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.shadowColor = shadowColor
        self.shadowRadius = shadowRadius
        self.shadowOffset = shadowOffset
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.padding = padding
    }
    
    public var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(backgroundColor)
                    .shadow(
                        color: shadowColor.opacity(0.08),
                        radius: shadowRadius,
                        x: shadowOffset.x,
                        y: shadowOffset.y
                    )
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
                    backgroundColor: colorScheme == .dark ? Color.blue.opacity(0.4) : Color.blue.opacity(0.1),
                    cornerRadius: 20,
                    shadowRadius: 15,
                    borderColor: colorScheme == .dark ? Color.blue.opacity(0.6) : Color.blue.opacity(0.3)
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
                                .foregroundColor(.yellow)
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
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .padding()
        }
    }
    static var previews: some View {
        Group {
            AdaptivePreview()
                .previewDisplayName("Light Mode")
                .environment(\.colorScheme, .light)
            AdaptivePreview()
                .previewDisplayName("Dark Mode")
                .environment(\.colorScheme, .dark)
        }
        .previewLayout(.sizeThatFits)
    }
} 

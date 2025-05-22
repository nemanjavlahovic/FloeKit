import SwiftUI

public struct FloeSection<Content: View>: View {
    private let title: String
    private let subtitle: String?
    private let trailing: AnyView?
    private let backgroundColor: Color
    private let cornerRadius: CGFloat
    private let padding: EdgeInsets
    private let content: Content
    
    public init(
        title: String,
        subtitle: String? = nil,
        trailing: AnyView? = nil,
        backgroundColor: Color = Color.floePreviewSurface,
        cornerRadius: CGFloat = 14,
        padding: FloeSpacing.PaddingStyle = .section,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.padding = padding.edgeInsets
        self.content = content()
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: FloeSpacing.Size.md.value) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: FloeSpacing.Size.xs.value) {
                    Text(title)
                        .floeFont(.headline)
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .floeFont(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                if let trailing = trailing {
                    trailing
                }
            }
            content
        }
        .padding(padding)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(backgroundColor)
                .floeShadow(.soft)
        )   
    }
}

// MARK: - Previews

struct FloeSection_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack(spacing: 24) {
                FloeSection(title: "Profile") {
                    HStack {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 40, height: 40)
                        VStack(alignment: .leading) {
                            Text("Jane Doe")
                                .font(.body)
                            Text("@janedoe")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                FloeSection(title: "Settings", subtitle: "Manage your preferences", trailing: AnyView(Button("Edit") {})) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notifications")
                        Text("Privacy")
                        Text("Account")
                    }
                }
            }
            .padding()
            .previewDisplayName("Light Mode")
            .environment(\.colorScheme, .light)
            VStack(spacing: 24) {
                FloeSection(title: "Profile") {
                    HStack {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 40, height: 40)
                        VStack(alignment: .leading) {
                            Text("Jane Doe")
                                .font(.body)
                            Text("@janedoe")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                FloeSection(title: "Settings", subtitle: "Manage your preferences", trailing: AnyView(Button("Edit") {})) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notifications")
                        Text("Privacy")
                        Text("Account")
                    }
                }
            }
            .padding()
            .previewDisplayName("Dark Mode")
            .environment(\.colorScheme, .dark)
        }
        .previewLayout(.sizeThatFits)
    }
} 
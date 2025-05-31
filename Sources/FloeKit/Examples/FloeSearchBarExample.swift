import SwiftUI

/// Example app demonstrating FloeSearchBar usage patterns
public struct FloeSearchBarExample: View {
    @State private var basicSearch = ""
    @State private var voiceSearch = ""
    @State private var filterSearch = ""
    @State private var cancelSearch = ""
    @State private var customSearch = ""
    @State private var appStoreSearch = ""
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 8) {
                        Text("FloeSearchBar Examples")
                            .floeFont(.title)
                            .foregroundColor(FloeColors.primary)
                        
                        Text("Showcase of different search bar configurations")
                            .floeFont(.body)
                            .foregroundColor(FloeColors.neutral40)
                    }
                    .padding(.top)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        // Basic Search Bar
                        ExampleSection(title: "Basic Search Bar") {
                            FloeSearchBar(
                                text: $basicSearch,
                                placeholder: "Search products...",
                                onSearchSubmit: { query in
                                    print("Searching for: \(query)")
                                }
                            )
                        }
                        
                        // Voice Search
                        ExampleSection(title: "Voice Search") {
                            FloeSearchBar.withVoiceSearch(
                                text: $voiceSearch,
                                placeholder: "Say something...",
                                onVoiceSearch: {
                                    print("🎤 Voice search activated")
                                },
                                onSearchSubmit: { query in
                                    print("Voice search: \(query)")
                                }
                            )
                        }
                        
                        // Filter Search
                        ExampleSection(title: "Search with Filter") {
                            FloeSearchBar.withFilter(
                                text: $filterSearch,
                                placeholder: "Search and filter results...",
                                onFilter: {
                                    print("🔽 Filter options opened")
                                }
                            )
                        }
                        
                        // Cancel Button
                        ExampleSection(title: "Search with Cancel") {
                            FloeSearchBar.withCancelButton(
                                text: $cancelSearch,
                                placeholder: "Tap to search...",
                                onCancel: {
                                    print("❌ Search cancelled")
                                }
                            )
                        }
                        
                        // Custom Styled
                        ExampleSection(title: "Custom Style") {
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
                                    print("🔍 Custom search action")
                                },
                                trailingElement: .button(Image(systemName: "qrcode.viewfinder")) {
                                    print("📱 QR scanner opened")
                                }
                            )
                        }
                        
                        // App Store Style
                        ExampleSection(title: "App Store Style") {
                            FloeSearchBar(
                                text: $appStoreSearch,
                                placeholder: "Apps, games, and more...",
                                size: .medium,
                                backgroundColor: FloeColors.neutral10,
                                textColor: FloeColors.primary,
                                cornerRadius: 12,
                                leadingElement: .icon(Image(systemName: "magnifyingglass")),
                                trailingElement: .voiceSearch {
                                    print("🎙️ App Store voice search")
                                },
                                onSearchSubmit: { query in
                                    print("App Store search: \(query)")
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 50)
                }
            }
            .navigationTitle("FloeSearchBar")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}

// MARK: - Helper Views

private struct ExampleSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .floeFont(.headline)
                .foregroundColor(FloeColors.primary)
            
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Previews

struct FloeSearchBarExample_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FloeSearchBarExample()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
            
            FloeSearchBarExample()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
        }
    }
} 
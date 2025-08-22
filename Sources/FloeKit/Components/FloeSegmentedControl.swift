import SwiftUI

public struct FloeSegmentedControl: View {
    public enum Style {
        case pill
        case underline
        case card
        
        var indicatorAnimation: Animation {
            .spring(response: 0.35, dampingFraction: 0.8)
        }
    }
    
    @Binding private var selection: String
    private let options: [String]
    private let style: Style
    private let accentColor: Color
    private let backgroundColor: Color
    private let enableHaptics: Bool
    
    @Namespace private var namespace
    @State private var optionSizes: [String: CGSize] = [:]
    
    public init(
        selection: Binding<String>,
        options: [String],
        style: Style = .pill,
        accentColor: Color = FloeColors.primary,
        backgroundColor: Color = FloeColors.surface,
        enableHaptics: Bool = true
    ) {
        self._selection = selection
        self.options = options
        self.style = style
        self.accentColor = accentColor
        self.backgroundColor = backgroundColor
        self.enableHaptics = enableHaptics
    }
    
    public var body: some View {
        switch style {
        case .pill:
            pillStyle
        case .underline:
            underlineStyle
        case .card:
            cardStyle
        }
    }
    
    // MARK: - Pill Style
    
    private var pillStyle: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.self) { option in
                pillOption(option)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(backgroundColor)
                .floeShadow(.soft)
        )
    }
    
    private func pillOption(_ option: String) -> some View {
        Button(action: {
            selectOption(option)
        }) {
            Text(option)
                .font(FloeFont.font(.button))
                .foregroundColor(selection == option ? .white : FloeColors.neutral10)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Group {
                        if selection == option {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(accentColor)
                                .matchedGeometryEffect(
                                    id: "pill_indicator",
                                    in: namespace
                                )
                        }
                    }
                )
                .contentShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .animation(style.indicatorAnimation, value: selection)
    }
    
    // MARK: - Underline Style
    
    private var underlineStyle: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(options, id: \.self) { option in
                    underlineOption(option)
                        .onPreferenceChange(SizePreferenceKey.self) { size in
                            if option == options.first {
                                optionSizes[option] = size
                            }
                        }
                }
            }
            
            // Underline indicator
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    ForEach(options, id: \.self) { option in
                        Rectangle()
                            .fill(selection == option ? accentColor : Color.clear)
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                            .matchedGeometryEffect(
                                id: selection == option ? "underline_indicator" : "none_\(option)",
                                in: namespace
                            )
                    }
                }
            }
            .frame(height: 2)
        }
    }
    
    private func underlineOption(_ option: String) -> some View {
        Button(action: {
            selectOption(option)
        }) {
            Text(option)
                .font(FloeFont.font(selection == option ? .headline : .body))
                .foregroundColor(selection == option ? accentColor : FloeColors.neutral40)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(GeometryReader { geometry in
                    Color.clear.preference(
                        key: SizePreferenceKey.self,
                        value: geometry.size
                    )
                })
        }
        .buttonStyle(.plain)
        .animation(style.indicatorAnimation, value: selection)
    }
    
    // MARK: - Card Style
    
    private var cardStyle: some View {
        HStack(spacing: 8) {
            ForEach(options, id: \.self) { option in
                cardOption(option)
            }
        }
    }
    
    private func cardOption(_ option: String) -> some View {
        Button(action: {
            selectOption(option)
        }) {
            Text(option)
                .font(FloeFont.font(selection == option ? .headline : .body))
                .foregroundColor(selection == option ? .white : FloeColors.neutral10)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(selection == option ? accentColor : backgroundColor)
                        .floeShadow(selection == option ? .medium : .soft)
                )
                .overlay(
                    Group {
                        if selection != option {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(FloeColors.neutral90, lineWidth: 1)
                        }
                    }
                )
        }
        .buttonStyle(.plain)
        .scaleEffect(selection == option ? 1.02 : 1.0)
        .animation(style.indicatorAnimation, value: selection)
    }
    
    // MARK: - Helper Methods
    
    private func selectOption(_ option: String) {
        withAnimation(style.indicatorAnimation) {
            selection = option
        }
        
        if enableHaptics {
            triggerHaptics()
        }
    }
    
    private func triggerHaptics() {
        #if os(iOS)
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        #endif
    }
}

// MARK: - Icon Support

public struct FloeSegmentedControlWithIcons: View {
    public struct Option: Identifiable {
        public let id: String
        public let title: String?
        public let icon: String
        public let selectedIcon: String?
        
        public init(id: String, title: String? = nil, icon: String, selectedIcon: String? = nil) {
            self.id = id
            self.title = title
            self.icon = icon
            self.selectedIcon = selectedIcon
        }
    }
    
    @Binding private var selection: String
    private let options: [Option]
    private let style: FloeSegmentedControl.Style
    private let accentColor: Color
    private let backgroundColor: Color
    private let showTitles: Bool
    
    @Namespace private var namespace
    
    public init(
        selection: Binding<String>,
        options: [Option],
        style: FloeSegmentedControl.Style = .pill,
        accentColor: Color = FloeColors.primary,
        backgroundColor: Color = FloeColors.surface,
        showTitles: Bool = true
    ) {
        self._selection = selection
        self.options = options
        self.style = style
        self.accentColor = accentColor
        self.backgroundColor = backgroundColor
        self.showTitles = showTitles
    }
    
    public var body: some View {
        HStack(spacing: style == .card ? 8 : 4) {
            ForEach(options) { option in
                optionButton(option)
            }
        }
        .padding(style == .pill ? 4 : 0)
        .background(
            Group {
                if style == .pill {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(backgroundColor)
                        .floeShadow(.soft)
                }
            }
        )
    }
    
    private func optionButton(_ option: Option) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                selection = option.id
            }
            #if os(iOS)
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
            #endif
        }) {
            HStack(spacing: 6) {
                Image(systemName: selection == option.id && option.selectedIcon != nil ? option.selectedIcon! : option.icon)
                    .font(.system(size: 16, weight: .medium))
                
                if showTitles, let title = option.title {
                    Text(title)
                        .font(FloeFont.font(.button))
                }
            }
            .foregroundColor(selection == option.id ? (style == .card ? .white : accentColor) : FloeColors.neutral40)
            .padding(.horizontal, showTitles ? 16 : 12)
            .padding(.vertical, 8)
            .frame(maxWidth: style == .card ? .infinity : nil)
            .background(
                Group {
                    switch style {
                    case .pill:
                        if selection == option.id {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(accentColor.opacity(0.15))
                                .matchedGeometryEffect(id: "icon_indicator", in: namespace)
                        }
                    case .card:
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(selection == option.id ? accentColor : backgroundColor)
                            .floeShadow(selection == option.id ? .medium : .soft)
                    case .underline:
                        EmptyView()
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preference Key

private struct SizePreferenceKey: PreferenceKey {
    static let defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

// MARK: - Convenience Initializers

extension FloeSegmentedControl {
    public init(
        selection: Binding<String>,
        options: [String]
    ) {
        self.init(
            selection: selection,
            options: options,
            style: .pill
        )
    }
}


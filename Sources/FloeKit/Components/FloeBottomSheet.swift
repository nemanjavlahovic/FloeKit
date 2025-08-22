import SwiftUI

@available(iOS 16.0, macOS 13.0, *)
public struct FloeBottomSheet<Content: View>: View {
    @Binding var isPresented: Bool
    let content: Content
    
    private let detents: Set<PresentationDetent>
    private let showDragIndicator: Bool
    private let dismissible: Bool
    private let backgroundColor: Color
    private let cornerRadius: CGFloat
    private let onDismiss: (() -> Void)?
    
    public init(
        isPresented: Binding<Bool>,
        detents: Set<PresentationDetent> = [.medium, .large],
        showDragIndicator: Bool = true,
        dismissible: Bool = true,
        backgroundColor: Color = FloeColors.surface,
        cornerRadius: CGFloat = 24,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.detents = detents
        self.showDragIndicator = showDragIndicator
        self.dismissible = dismissible
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.onDismiss = onDismiss
        self.content = content()
    }
    
    public var body: some View {
        EmptyView()
            .sheet(isPresented: $isPresented) {
                if let onDismiss = onDismiss {
                    onDismiss()
                }
            } content: {
                ZStack {
                    backgroundColor.ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        if showDragIndicator {
                            DragIndicator()
                                .padding(.top, 8)
                                .padding(.bottom, 16)
                        }
                        
                        content
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .presentationDetents(detents)
                .presentationDragIndicator(showDragIndicator ? .hidden : .visible)
                .interactiveDismissDisabled(!dismissible)
//                #if os(iOS)
//                .presentationCornerRadius(cornerRadius)
//                .presentationBackgroundInteraction(
//                    dismissible ? .enabled : .disabled
//                )
//                #endif
            }
    }
}

private struct DragIndicator: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 2.5)
            .fill(FloeColors.neutral30)
            .frame(width: 36, height: 5)
    }
}

// MARK: - Custom Bottom Sheet Implementation (iOS 15 compatible)

public struct FloeCustomBottomSheet<Content: View>: View {
    @Binding var isPresented: Bool
    let content: Content
    
    public enum Height {
        case fixed(CGFloat)
        case percentage(CGFloat)
        case dynamic
    }
    
    private let height: Height
    private let showDragIndicator: Bool
    private let dismissible: Bool
    private let backgroundColor: Color
    private let cornerRadius: CGFloat
    private let onDismiss: (() -> Void)?
    
    @State private var offset: CGFloat = 0
    @State private var lastOffset: CGFloat = 0
    @GestureState private var dragState: CGFloat = 0
    
    public init(
        isPresented: Binding<Bool>,
        height: Height = .percentage(0.5),
        showDragIndicator: Bool = true,
        dismissible: Bool = true,
        backgroundColor: Color = FloeColors.surface,
        cornerRadius: CGFloat = 24,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.height = height
        self.showDragIndicator = showDragIndicator
        self.dismissible = dismissible
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.onDismiss = onDismiss
        self.content = content()
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                if isPresented {
                    Color.black
                        .opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            if dismissible {
                                withAnimation(.spring()) {
                                    isPresented = false
                                }
                                onDismiss?()
                            }
                        }
                        .transition(.opacity)
                    
                    VStack(spacing: 0) {
                        if showDragIndicator {
                            DragIndicator()
                                .padding(.top, 8)
                                .padding(.bottom, 16)
                        }
                        
                        content
                            .frame(maxWidth: .infinity)
                            .frame(height: sheetHeight(in: geometry))
                    }
                    .frame(maxWidth: .infinity)
                    .background(backgroundColor)
                    .clipShape(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .offset(y: -cornerRadius)
                    )
                    .offset(y: max(0, offset + dragState))
                    .gesture(
                        dismissible ? dragGesture(in: geometry) : nil
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isPresented)
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: dragState)
        }
    }
    
    private func sheetHeight(in geometry: GeometryProxy) -> CGFloat? {
        switch height {
        case .fixed(let value):
            return value
        case .percentage(let percentage):
            return geometry.size.height * percentage
        case .dynamic:
            return nil
        }
    }
    
    private func dragGesture(in geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .updating($dragState) { value, state, _ in
                state = value.translation.height
            }
            .onEnded { value in
                let dismissThreshold = (sheetHeight(in: geometry) ?? 300) * 0.25
                
                if value.translation.height > dismissThreshold {
                    withAnimation(.spring()) {
                        isPresented = false
                    }
                    onDismiss?()
                } else {
                    withAnimation(.spring()) {
                        offset = 0
                    }
                }
            }
    }
}

// MARK: - View Extension

public extension View {
    @available(iOS 16.0, macOS 13.0, *)
    func floeBottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        detents: Set<PresentationDetent> = [.medium, .large],
        showDragIndicator: Bool = true,
        dismissible: Bool = true,
        backgroundColor: Color = FloeColors.surface,
        cornerRadius: CGFloat = 24,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.modifier(
            FloeBottomSheetModifier(
                isPresented: isPresented,
                detents: detents,
                showDragIndicator: showDragIndicator,
                dismissible: dismissible,
                backgroundColor: backgroundColor,
                cornerRadius: cornerRadius,
                onDismiss: onDismiss,
                content: content
            )
        )
    }
    
    func floeCustomBottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        height: FloeCustomBottomSheet<Content>.Height = .percentage(0.5),
        showDragIndicator: Bool = true,
        dismissible: Bool = true,
        backgroundColor: Color = FloeColors.surface,
        cornerRadius: CGFloat = 24,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.overlay(
            FloeCustomBottomSheet(
                isPresented: isPresented,
                height: height,
                showDragIndicator: showDragIndicator,
                dismissible: dismissible,
                backgroundColor: backgroundColor,
                cornerRadius: cornerRadius,
                onDismiss: onDismiss,
                content: content
            )
        )
    }
}

@available(iOS 16.0, macOS 13.0, *)
private struct FloeBottomSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let detents: Set<PresentationDetent>
    let showDragIndicator: Bool
    let dismissible: Bool
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let onDismiss: (() -> Void)?
    let content: () -> SheetContent
    
    func body(content: Content) -> some View {
        content
            .background(
                FloeBottomSheet(
                    isPresented: $isPresented,
                    detents: detents,
                    showDragIndicator: showDragIndicator,
                    dismissible: dismissible,
                    backgroundColor: backgroundColor,
                    cornerRadius: cornerRadius,
                    onDismiss: onDismiss,
                    content: self.content
                )
            )
    }
}


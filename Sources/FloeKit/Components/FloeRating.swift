import SwiftUI

public struct FloeRating: View {
    @Binding var rating: Double
    
    public enum Style {
        case stars
        case hearts
        case circles
        case custom(filled: String, empty: String)
        
        var filledIcon: String {
            switch self {
            case .stars: return "star.fill"
            case .hearts: return "heart.fill"
            case .circles: return "circle.fill"
            case .custom(let filled, _): return filled
            }
        }
        
        var emptyIcon: String {
            switch self {
            case .stars: return "star"
            case .hearts: return "heart"
            case .circles: return "circle"
            case .custom(_, let empty): return empty
            }
        }
    }
    
    public enum DisplayMode {
        case interactive
        case display
        case compact
    }
    
    private let maximumRating: Int
    private let style: Style
    private let displayMode: DisplayMode
    private let size: CGFloat
    private let spacing: CGFloat
    private let filledColor: Color
    private let emptyColor: Color
    private let allowHalfRatings: Bool
    private let showLabel: Bool
    private let animateChanges: Bool
    private let hapticFeedback: Bool
    private let onChange: ((Double) -> Void)?
    
    @State private var internalRating: Double
    @State private var hoveredRating: Double?
    @State private var isAnimating: Bool = false
    
    public init(
        rating: Binding<Double>,
        maximumRating: Int = 5,
        style: Style = .stars,
        displayMode: DisplayMode = .interactive,
        size: CGFloat = 24,
        spacing: CGFloat = 4,
        filledColor: Color = FloeColors.warning,
        emptyColor: Color = FloeColors.neutral30,
        allowHalfRatings: Bool = false,
        showLabel: Bool = false,
        animateChanges: Bool = true,
        hapticFeedback: Bool = true,
        onChange: ((Double) -> Void)? = nil
    ) {
        self._rating = rating
        self.maximumRating = maximumRating
        self.style = style
        self.displayMode = displayMode
        self.size = size
        self.spacing = spacing
        self.filledColor = filledColor
        self.emptyColor = emptyColor
        self.allowHalfRatings = allowHalfRatings
        self.showLabel = showLabel
        self.animateChanges = animateChanges
        self.hapticFeedback = hapticFeedback
        self.onChange = onChange
        self._internalRating = State(initialValue: rating.wrappedValue)
    }
    
    public var body: some View {
        HStack(spacing: displayMode == .compact ? 2 : 8) {
            HStack(spacing: spacing) {
                ForEach(1...maximumRating, id: \.self) { index in
                    ratingIcon(for: index)
                        .onTapGesture {
                            if displayMode == .interactive {
                                handleTap(at: index)
                            }
                        }
                        .scaleEffect(isAnimating && index == Int(ceil(internalRating)) ? 1.2 : 1.0)
                }
            }
            
            if showLabel {
                Text(labelText)
                    .font(.system(size: size * 0.7, weight: .medium))
                    .foregroundColor(FloeColors.neutral40)
                    .animation(.none, value: internalRating)
            }
        }
        .onChange(of: rating) { newValue in
            withAnimation(animateChanges ? .spring(response: 0.3, dampingFraction: 0.7) : .none) {
                internalRating = newValue
            }
        }
    }
    
    @ViewBuilder
    private func ratingIcon(for index: Int) -> some View {
        let fillAmount = fillAmount(for: index)
        
        ZStack {
            Image(systemName: style.emptyIcon)
                .font(.system(size: size))
                .foregroundColor(emptyColor)
            
            if fillAmount > 0 {
                if fillAmount < 1 && allowHalfRatings {
                    Image(systemName: style.filledIcon)
                        .font(.system(size: size))
                        .foregroundColor(filledColor)
                        .mask(
                            GeometryReader { geometry in
                                Rectangle()
                                    .frame(width: geometry.size.width * fillAmount)
                            }
                        )
                } else if fillAmount == 1 {
                    Image(systemName: style.filledIcon)
                        .font(.system(size: size))
                        .foregroundColor(filledColor)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .frame(width: size, height: size)
    }
    
    private func fillAmount(for index: Int) -> Double {
        let displayedRating = hoveredRating ?? internalRating
        
        if Double(index) <= displayedRating {
            return 1.0
        } else if Double(index - 1) < displayedRating {
            return displayedRating - Double(index - 1)
        } else {
            return 0.0
        }
    }
    
    private func handleTap(at index: Int) {
        let newRating = Double(index)
        
        if allowHalfRatings && abs(rating - newRating) < 0.5 {
            updateRating(newRating - 0.5)
        } else {
            updateRating(newRating)
        }
        
        if hapticFeedback {
            #if os(iOS)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
        }
        
        if animateChanges {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isAnimating = false
            }
        }
    }
    
    private func updateRating(_ newRating: Double) {
        let clampedRating = max(0, min(Double(maximumRating), newRating))
        rating = clampedRating
        internalRating = clampedRating
        onChange?(clampedRating)
    }
    
    private var labelText: String {
        if allowHalfRatings && internalRating.truncatingRemainder(dividingBy: 1) != 0 {
            return String(format: "%.1f", internalRating)
        } else {
            return String(format: "%.0f", internalRating)
        }
    }
}

// MARK: - Convenience Initializers

public extension FloeRating {
    static func readOnly(
        rating: Double,
        maximumRating: Int = 5,
        style: Style = .stars,
        size: CGFloat = 16,
        filledColor: Color = FloeColors.warning,
        emptyColor: Color = FloeColors.neutral30
    ) -> FloeRating {
        FloeRating(
            rating: .constant(rating),
            maximumRating: maximumRating,
            style: style,
            displayMode: .display,
            size: size,
            filledColor: filledColor,
            emptyColor: emptyColor,
            animateChanges: false
        )
    }
    
    static func compact(
        rating: Binding<Double>,
        maximumRating: Int = 5,
        style: Style = .stars,
        size: CGFloat = 14
    ) -> FloeRating {
        FloeRating(
            rating: rating,
            maximumRating: maximumRating,
            style: style,
            displayMode: .compact,
            size: size,
            spacing: 2,
            showLabel: true
        )
    }
    
    static func hearts(
        rating: Binding<Double>,
        maximumRating: Int = 5,
        size: CGFloat = 24,
        filledColor: Color = .red
    ) -> FloeRating {
        FloeRating(
            rating: rating,
            maximumRating: maximumRating,
            style: .hearts,
            size: size,
            filledColor: filledColor
        )
    }
}

// MARK: - Rating Summary View

public struct FloeRatingsSummary: View {
    let averageRating: Double
    let totalRatings: Int
    let distribution: [Int: Int]?
    let maximumRating: Int
    let style: FloeRating.Style
    
    public init(
        averageRating: Double,
        totalRatings: Int,
        distribution: [Int: Int]? = nil,
        maximumRating: Int = 5,
        style: FloeRating.Style = .stars
    ) {
        self.averageRating = averageRating
        self.totalRatings = totalRatings
        self.distribution = distribution
        self.maximumRating = maximumRating
        self.style = style
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(format: "%.1f", averageRating))
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(FloeColors.neutral10)
                    
                    FloeRating.readOnly(
                        rating: averageRating,
                        maximumRating: maximumRating,
                        style: style,
                        size: 20
                    )
                    
                    Text("\(totalRatings) ratings")
                        .font(.caption)
                        .foregroundColor(FloeColors.neutral40)
                }
                
                if let distribution = distribution {
                    VStack(spacing: 4) {
                        ForEach((1...maximumRating).reversed(), id: \.self) { rating in
                            HStack(spacing: 8) {
                                Text("\(rating)")
                                    .font(.caption)
                                    .foregroundColor(FloeColors.neutral40)
                                    .frame(width: 10)
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(FloeColors.neutral30.opacity(0.3))
                                        
                                        let percentage = Double(distribution[rating] ?? 0) / Double(totalRatings)
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(FloeColors.warning)
                                            .frame(width: geometry.size.width * percentage)
                                    }
                                }
                                .frame(height: 8)
                                
                                Text("\(distribution[rating] ?? 0)")
                                    .font(.caption)
                                    .foregroundColor(FloeColors.neutral40)
                                    .frame(width: 30, alignment: .trailing)
                            }
                        }
                    }
                    .frame(maxWidth: 200)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(FloeColors.surface)
        )
    }
}

// MARK: - View Extension

public extension View {
    func floeRatingPopover(
        isPresented: Binding<Bool>,
        rating: Binding<Double>,
        title: String = "Rate this item",
        message: String? = nil,
        onSubmit: @escaping (Double) -> Void
    ) -> some View {
        self.popover(isPresented: isPresented) {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text(title)
                        .font(.headline)
                    
                    if let message = message {
                        Text(message)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                FloeRating(
                    rating: rating,
                    size: 32,
                    allowHalfRatings: true,
                    showLabel: true
                )
                
                HStack(spacing: 12) {
                    FloeButton.ghost("Cancel") {
                        isPresented.wrappedValue = false
                    }
                    
                    FloeButton.primary("Submit") {
                        isPresented.wrappedValue = false
                        onSubmit(rating.wrappedValue)
                    }
                }
            }
            .padding()
            .frame(width: 280)
        }
    }
}

// MARK: - Previews

struct FloeRating_Previews: PreviewProvider {
    static var previews: some View {
        RatingPreviewView()
    }
    
    struct RatingPreviewView: View {
        @State private var rating1: Double = 3.5
        @State private var rating2: Double = 4
        @State private var rating3: Double = 2.5
        @State private var rating4: Double = 5
        @State private var showingPopover = false
        @State private var popoverRating: Double = 0
        
        var body: some View {
            ScrollView {
                VStack(spacing: 32) {
                    Text("FloeRating Examples")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Interactive Stars")
                                .font(.headline)
                            FloeRating(
                                rating: $rating1,
                                allowHalfRatings: true,
                                showLabel: true
                            )
                            Text("Current: \(rating1, specifier: "%.1f")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Hearts Style")
                                .font(.headline)
                            FloeRating.hearts(
                                rating: $rating2,
                                size: 28
                            )
                            Text("Current: \(rating2, specifier: "%.0f")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Compact Display")
                                .font(.headline)
                            FloeRating.compact(
                                rating: $rating3,
                                maximumRating: 10
                            )
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Read-Only")
                                .font(.headline)
                            HStack(spacing: 16) {
                                FloeRating.readOnly(rating: 4.2)
                                FloeRating.readOnly(rating: 3.7, style: .hearts)
                                FloeRating.readOnly(rating: 2.5, style: .circles)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Custom Icons")
                                .font(.headline)
                            FloeRating(
                                rating: $rating4,
                                style: .custom(filled: "flame.fill", empty: "flame"),
                                size: 30,
                                filledColor: .orange
                            )
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Rating Summary")
                                .font(.headline)
                            
                            FloeRatingsSummary(
                                averageRating: 4.2,
                                totalRatings: 1234,
                                distribution: [
                                    5: 678,
                                    4: 345,
                                    3: 123,
                                    2: 56,
                                    1: 32
                                ]
                            )
                        }
                        
                        FloeButton("Show Rating Popover") {
                            showingPopover = true
                        }
                        .floeRatingPopover(
                            isPresented: $showingPopover,
                            rating: $popoverRating,
                            title: "How was your experience?",
                            message: "Your feedback helps us improve",
                            onSubmit: { rating in
                                print("Submitted rating: \(rating)")
                            }
                        )
                    }
                    .padding()
                }
            }
        }
    }
}
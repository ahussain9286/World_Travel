import SwiftUI

// MARK: - ColorProvider

/// Any SwiftUI `Color` value can be used wherever a `ColorProvider` is expected.
/// Callers can pass literal colours (`Color(red:green:blue:)`, `.red`, etc.)
/// or colours decoded from backend data.
public typealias ColorProvider = Color

// MARK: - RiskSegment

/// One segment in the investment-profile risk bar.
public struct RiskSegment: Identifiable {

    public let id = UUID()

    /// Fill colour used when this segment is *active* (completed).
    /// When the segment is inactive the card style's `inactiveSegmentColor` is used instead.
    public let color: ColorProvider

    public init(color: ColorProvider) {
        self.color = color
    }
}

// MARK: - InvestmentProfileCardModel

/// Data model for `InvestmentProfileCard`.
///
/// All fields except `segments`, `completedSegments`, and `expandButtonLabel` are optional
/// so callers can populate only what the backend provides.
///
/// ### Unsuitable state
/// Set `completedSegments` to `0` to render every segment pill in the inactive
/// (grey) colour — this represents an "Unsuitable" / "Μη κατάλληλος" profile.
public struct InvestmentProfileCardModel {

    /// Card heading. Uses `"Επενδυτικό Προφίλ"` when `nil`.
    public var title: String?

    /// Text shown in the expanded info section. Section is hidden when `nil`.
    public var expandedDescription: String?

    /// Label under the leftmost segment pill. Defaults to `"Low"` when `nil`.
    public var lowLabel: String?

    /// Label under the rightmost segment pill. Defaults to `"High"` when `nil`.
    public var highLabel: String?

    /// All segment pills to display, in order from lowest to highest risk.
    public var segments: [RiskSegment]

    /// Number of leading segments to colour as "active".
    /// `0` = all grey (Unsuitable); `segments.count` = all filled.
    public var completedSegments: Int

    /// Pre-formatted "Valid Until" date string. Row is hidden when `nil`.
    public var validUntil: String?

    /// Pre-formatted expiry date string. Warning row is hidden when `nil`.
    public var expiredSince: String?

    /// Label on the expandable-info button.
    public var expandButtonLabel: String

    /// Label shown above the segment bar (e.g. `"High"`, `"Μη κατάλληλος"`).
    /// Row is hidden when `nil`.
    public var activeLabel: String?

    public init(
        title: String?           = "Επενδυτικό Προφίλ",
        expandedDescription: String? = nil,
        lowLabel: String?        = "Low",
        highLabel: String?       = "High",
        segments: [RiskSegment],
        completedSegments: Int,
        validUntil: String?      = nil,
        expiredSince: String?    = nil,
        expandButtonLabel: String = "Τι σημαίνει αυτό για εσένα",
        activeLabel: String?     = nil
    ) {
        self.title               = title
        self.expandedDescription = expandedDescription
        self.lowLabel            = lowLabel
        self.highLabel           = highLabel
        self.segments            = segments
        self.completedSegments   = completedSegments
        self.validUntil          = validUntil
        self.expiredSince        = expiredSince
        self.expandButtonLabel   = expandButtonLabel
        self.activeLabel         = activeLabel
    }
}

// MARK: - InvestmentProfileCardStyle

/// Visual theming tokens for `InvestmentProfileCard`.
/// Segment fill colours come from each `RiskSegment.color` — only chrome and
/// inactive-state values live here.
public struct InvestmentProfileCardStyle {

    // MARK: Segment bar

    /// Colour used for unfilled (inactive) segment pills.
    public var inactiveSegmentColor: Color

    /// Height of each segment pill.
    public var segmentHeight: CGFloat

    /// Horizontal gap between segment pills.
    public var segmentSpacing: CGFloat

    // MARK: Typography / chrome

    /// Colour of the expand-info button text and chevron icon.
    public var expandButtonColor: Color

    /// Colour of the "Expired since" warning text.
    public var warningTextColor: Color

    /// Colour of the warning triangle icon.
    public var warningIconColor: Color

    // MARK: Card chrome

    /// Card background colour.
    public var cardBackground: Color

    /// Corner radius of the card.
    public var cardCornerRadius: CGFloat

    /// Shadow colour of the card.
    public var shadowColor: Color

    // MARK: – Initialiser

    public init(
        inactiveSegmentColor: Color,
        segmentHeight: CGFloat,
        segmentSpacing: CGFloat,
        expandButtonColor: Color,
        warningTextColor: Color,
        warningIconColor: Color,
        cardBackground: Color,
        cardCornerRadius: CGFloat,
        shadowColor: Color
    ) {
        self.inactiveSegmentColor = inactiveSegmentColor
        self.segmentHeight        = segmentHeight
        self.segmentSpacing       = segmentSpacing
        self.expandButtonColor    = expandButtonColor
        self.warningTextColor     = warningTextColor
        self.warningIconColor     = warningIconColor
        self.cardBackground       = cardBackground
        self.cardCornerRadius     = cardCornerRadius
        self.shadowColor          = shadowColor
    }

    // MARK: – Default style

    /// Ready-to-use style that matches the original design.
    public static let `default` = InvestmentProfileCardStyle(
        inactiveSegmentColor : Color(red: 0.88, green: 0.88, blue: 0.88),
        segmentHeight        : 12,
        segmentSpacing       : 6,
        expandButtonColor    : Color(red: 0.00, green: 0.45, blue: 0.70),
        warningTextColor     : Color(red: 0.85, green: 0.22, blue: 0.22),
        warningIconColor     : Color(red: 0.95, green: 0.50, blue: 0.13),
        cardBackground       : .white,
        cardCornerRadius     : 16,
        shadowColor          : Color.black.opacity(0.10)
    )
}

// MARK: - InvestmentProfileCard

/// A reusable card view driven entirely by `InvestmentProfileCardModel`.
///
/// ### Standard 5-level usage
/// ```swift
/// InvestmentProfileCard(model: InvestmentProfileCardModel(
///     segments: RiskSegment.defaultSegments,
///     completedSegments: 5,          // High
///     validUntil: "January 9, 2028",
///     expiredSince: "January 12, 2026",
///     expandedDescription: "Ο πελάτης ...",
///     activeLabel: "High"
/// ))
/// ```
///
/// ### Unsuitable state (all segments grey)
/// ```swift
/// InvestmentProfileCard(model: InvestmentProfileCardModel(
///     segments: RiskSegment.defaultSegments,
///     completedSegments: 0,
///     validUntil: "January 9, 2028",
///     expiredSince: "January 12, 2026",
///     activeLabel: "Μη κατάλληλος"
/// ))
/// ```
public struct InvestmentProfileCard: View {

    // MARK: – Input

    public var model: InvestmentProfileCardModel
    public var style: InvestmentProfileCardStyle

    /// Closure called when the user taps the expand button.
    public var onExpandTapped: () -> Void

    // MARK: – State

    @State private var isExpanded: Bool = false

    // MARK: – Initialisers

    public init(
        model: InvestmentProfileCardModel,
        style: InvestmentProfileCardStyle = .default,
        onExpandTapped: @escaping () -> Void = {}
    ) {
        self.model          = model
        self.style          = style
        self.onExpandTapped = onExpandTapped
    }

    // MARK: – Helpers

    /// Colour for the active-label text above the segment bar.
    /// Uses the last completed segment's colour, or `.black` when nothing is completed.
    private var activeLabelColor: Color {
        let idx = model.completedSegments - 1
        guard idx >= 0, idx < model.segments.count else { return .black }
        return model.segments[idx].color
    }

    // MARK: – Body

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let title = model.title {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.bottom, 14)
            }

            riskBarSection
                .padding(.bottom, 16)

            Divider()
                .padding(.bottom, 14)

            expandButton
                .padding(.bottom, isExpanded ? 12 : 16)

            if isExpanded, let description = model.expandedDescription {
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 16)
            }

            if let validUntil = model.validUntil {
                Text("Valid Until: \(validUntil)")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .padding(.bottom, model.expiredSince != nil ? 12 : 0)
            }

            if let expired = model.expiredSince {
                expiredRow(date: expired)
            }
        }
        .padding(20)
        .background(style.cardBackground)
        .cornerRadius(style.cardCornerRadius)
        .shadow(color: style.shadowColor, radius: 12, x: 0, y: 4)
    }

    // MARK: – Subviews

    private var riskBarSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let label = model.activeLabel {
                Text(label)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(activeLabelColor)
            }

            segmentBar

            HStack {
                Text(model.lowLabel ?? "Low")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                Spacer()
                Text(model.highLabel ?? "High")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
        }
    }

    private var segmentBar: some View {
        GeometryReader { geo in
            let count = model.segments.count
            if count > 0 {
                let totalSpacing = style.segmentSpacing * CGFloat(count - 1)
                let segmentWidth = (geo.size.width - totalSpacing) / CGFloat(count)

                HStack(spacing: style.segmentSpacing) {
                    ForEach(model.segments.indices, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(index < model.completedSegments
                                  ? model.segments[index].color
                                  : style.inactiveSegmentColor)
                            .frame(width: segmentWidth, height: style.segmentHeight)
                    }
                }
            }
        }
        .frame(height: style.segmentHeight)
    }

    private var expandButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded.toggle()
            }
            onExpandTapped()
        }) {
            HStack(spacing: 4) {
                Text(model.expandButtonLabel)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(style.expandButtonColor)

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(style.expandButtonColor)
            }
        }
        .buttonStyle(.plain)
    }

    private func expiredRow(date: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(style.warningIconColor)

            Text("Expired since: \(date)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(style.warningTextColor)
        }
    }
}

// MARK: - RiskSegment default factory

public extension RiskSegment {

    /// Standard five-segment set with earth-tone colours that matches the design.
    /// Use these as a starting point; replace any segment's colour to match
    /// whatever the backend returns.
    static var defaultSegments: [RiskSegment] {
        [
            RiskSegment(color: Color(red: 0.165, green: 0.439, blue: 0.208)),
            RiskSegment(color: Color(red: 0.369, green: 0.420, blue: 0.102)),
            RiskSegment(color: Color(red: 0.494, green: 0.420, blue: 0.082)),
            RiskSegment(color: Color(red: 0.494, green: 0.200, blue: 0.063)),
            RiskSegment(color: Color(red: 0.494, green: 0.067, blue: 0.063)),
        ]
    }
}

// MARK: – Previews

#if DEBUG
struct InvestmentProfileCard_Previews: PreviewProvider {

    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {

                // --- High (all 5 segments filled, expanded description) ---
                InvestmentProfileCard(model: InvestmentProfileCardModel(
                    segments: RiskSegment.defaultSegments,
                    completedSegments: 5,
                    validUntil: "January 9, 2028",
                    expiredSince: "January 12, 2026",
                    expandedDescription: "Ο πελάτης έχει ως βασικό στόχο τη μέγιστη δυνατή μακροπρόθεσμη απόδοση, με πολύ υψηλή ανοχή στον κίνδυνο και σε έντονες διακυμάνσεις.",
                    activeLabel: "High"
                ))
                .previewDisplayName("High – expired")

                // --- Unsuitable (completedSegments = 0, all grey) ---
                InvestmentProfileCard(model: InvestmentProfileCardModel(
                    segments: RiskSegment.defaultSegments,
                    completedSegments: 0,
                    validUntil: "January 9, 2028",
                    expiredSince: "January 12, 2026",
                    activeLabel: "Μη κατάλληλος"
                ))
                .previewDisplayName("Unsuitable – expired")

                // --- Medium (3 of 5 filled) ---
                InvestmentProfileCard(model: InvestmentProfileCardModel(
                    segments: RiskSegment.defaultSegments,
                    completedSegments: 3,
                    validUntil: "December 31, 2030",
                    expandedDescription: "Ο πελάτης έχει ως βασικό στόχο την ισόρροπη ανάπτυξη κεφαλαίου με μέτρια ανοχή στον κίνδυνο και τις διακυμάνσεις.",
                    activeLabel: "Medium"
                ))
                .previewDisplayName("Medium – valid")

                // --- Low (1 of 5 filled) ---
                InvestmentProfileCard(model: InvestmentProfileCardModel(
                    segments: RiskSegment.defaultSegments,
                    completedSegments: 1,
                    validUntil: "June 30, 2027",
                    expandedDescription: "Ο πελάτης έχει ως βασικό στόχο τη διατήρηση κεφαλαίου με πολύ χαμηλή ανοχή στον κίνδυνο και στις διακυμάνσεις.",
                    activeLabel: "Low"
                ))
                .previewDisplayName("Low – valid")

                // --- Custom: backend-provided 4-segment bar ---
                InvestmentProfileCard(model: InvestmentProfileCardModel(
                    segments: [
                        RiskSegment(color: .blue),
                        RiskSegment(color: .teal),
                        RiskSegment(color: .orange),
                        RiskSegment(color: .red),
                    ],
                    completedSegments: 2,
                    validUntil: "July 4, 2028",
                    activeLabel: "Balanced"
                ))
                .previewDisplayName("Custom 4-segment")
            }
            .padding()
        }
        .background(Color(white: 0.2))
        .previewLayout(.sizeThatFits)
    }
}
#endif


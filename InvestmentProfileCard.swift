import SwiftUI

// MARK: - RiskLevel

/// Represents the investor risk level, ordered from lowest to highest.
/// The raw `Int` value equals the number of segments that should be filled.
public enum RiskLevel: Int, CaseIterable, Hashable {
    case low = 1
    case mediumLow = 2
    case medium = 3
    case mediumHigh = 4
    case high = 5

    /// Default display label shown above the segment bar.
    public var defaultLabel: String {
        switch self {
        case .low:        return "Low"
        case .mediumLow:  return "Medium Low"
        case .medium:     return "Medium"
        case .mediumHigh: return "Medium High"
        case .high:       return "High"
        }
    }

    /// Default segment colour for each level (used by `InvestmentProfileStyle.default`).
    public var defaultColor: Color {
        switch self {
        case .low:        return Color(red: 0.16, green: 0.44, blue: 0.18) // dark green
        case .mediumLow:  return Color(red: 0.47, green: 0.72, blue: 0.22) // lime green
        case .medium:     return Color(red: 0.95, green: 0.77, blue: 0.06) // amber
        case .mediumHigh: return Color(red: 0.95, green: 0.50, blue: 0.13) // orange
        case .high:       return Color(red: 0.85, green: 0.16, blue: 0.16) // red
        }
    }
}

// MARK: - InvestmentProfileStyle

/// All visual tokens for `InvestmentProfileCard`.
/// Override only the properties you need — start from `.default`.
public struct InvestmentProfileStyle {

    // MARK: Segment bar

    /// A colour for every possible active risk level.
    /// When the card displays `riskLevel`, filled segments use `segmentColors[riskLevel]`.
    public var segmentColors: [RiskLevel: Color]

    /// Colour of unfilled (inactive) segments.
    public var inactiveSegmentColor: Color

    /// Height of each segment pill.
    public var segmentHeight: CGFloat

    /// Horizontal gap between segment pills.
    public var segmentSpacing: CGFloat

    // MARK: Typography / chrome

    /// Colour of the expand-info button and chevron icon.
    public var expandButtonColor: Color

    /// Colour of the "Expired since" text.
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
        segmentColors: [RiskLevel: Color],
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
        self.segmentColors        = segmentColors
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
    /// Each risk level has its own distinct segment colour out of the box.
    public static let `default` = InvestmentProfileStyle(
        segmentColors: Dictionary(
            uniqueKeysWithValues: RiskLevel.allCases.map { ($0, $0.defaultColor) }
        ),
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

    // MARK: – Convenience mutators

    /// Returns a copy of the style with one risk level's segment colour replaced.
    public func segmentColor(_ color: Color, for level: RiskLevel) -> InvestmentProfileStyle {
        var copy = self
        copy.segmentColors[level] = color
        return copy
    }
}

// MARK: - InvestmentProfileModel

/// Single source of truth for `InvestmentProfileCard`.
/// Pass this model to the card view; change values here to update all visuals.
public struct InvestmentProfileModel {

    // MARK: Data

    /// Card heading text.
    public var title: String

    /// The investor's current risk level.
    public var riskLevel: RiskLevel

    /// Optional custom label for the risk level.
    /// Falls back to `riskLevel.defaultLabel` when `nil`.
    public var riskLevelLabel: String?

    /// The date until which the profile is valid, as a pre-formatted string.
    public var validUntil: String

    /// Optional expiry date. When non-nil a warning row is rendered.
    public var expiredSince: String?

    /// Label for the expandable information button.
    public var expandButtonLabel: String

    // MARK: Style

    /// All visual tokens. Swap or mutate to theme the card.
    public var style: InvestmentProfileStyle

    // MARK: – Computed helpers

    /// The label shown above the segment bar.
    public var resolvedRiskLevelLabel: String {
        riskLevelLabel ?? riskLevel.defaultLabel
    }

    /// The active colour for the current risk level.
    public var activeSegmentColor: Color {
        style.segmentColors[riskLevel] ?? riskLevel.defaultColor
    }

    // MARK: – Initialisers

    public init(
        title: String = "Επενδυτικό Προφίλ",
        riskLevel: RiskLevel,
        riskLevelLabel: String? = nil,
        validUntil: String,
        expiredSince: String? = nil,
        expandButtonLabel: String = "Τι σημαίνει αυτό για εσένα",
        style: InvestmentProfileStyle = .default
    ) {
        self.title              = title
        self.riskLevel          = riskLevel
        self.riskLevelLabel     = riskLevelLabel
        self.validUntil         = validUntil
        self.expiredSince       = expiredSince
        self.expandButtonLabel  = expandButtonLabel
        self.style              = style
    }
}

// MARK: - InvestmentProfileCard

/// A reusable card view driven entirely by `InvestmentProfileModel`.
///
/// ### Minimal usage
/// ```swift
/// InvestmentProfileCard(model: InvestmentProfileModel(
///     riskLevel: .low,
///     validUntil: "January 9, 2028",
///     expiredSince: "January 12, 2026"
/// ))
/// ```
///
/// ### Custom colours per level
/// ```swift
/// var style = InvestmentProfileStyle.default
/// style.segmentColors[.high] = .purple
/// InvestmentProfileCard(model: InvestmentProfileModel(
///     riskLevel: .high,
///     validUntil: "March 1, 2029",
///     style: style
/// ))
/// ```
public struct InvestmentProfileCard: View {

    // MARK: – Input

    public var model: InvestmentProfileModel

    /// Closure called when the user taps the expand button.
    public var onExpandTapped: () -> Void

    // MARK: – Internal state

    @State private var isExpanded: Bool = false

    // MARK: – Convenience shorthands

    private var style: InvestmentProfileStyle { model.style }
    private var segmentCount: Int { RiskLevel.allCases.count }

    // MARK: – Body

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleSection
                .padding(.bottom, 14)

            riskBarSection
                .padding(.bottom, 16)

            Divider()
                .padding(.bottom, 14)

            expandButton
                .padding(.bottom, 16)

            validUntilRow
                .padding(.bottom, model.expiredSince != nil ? 12 : 0)

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

    private var titleSection: some View {
        Text(model.title)
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.black)
    }

    private var riskBarSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(model.resolvedRiskLevelLabel)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(model.activeSegmentColor)

            segmentBar

            HStack {
                Text("Low")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                Spacer()
                Text("High")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
        }
    }

    private var segmentBar: some View {
        GeometryReader { geo in
            let totalSpacing = style.segmentSpacing * CGFloat(segmentCount - 1)
            let segmentWidth = (geo.size.width - totalSpacing) / CGFloat(segmentCount)

            HStack(spacing: style.segmentSpacing) {
                ForEach(1...segmentCount, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(index <= model.riskLevel.rawValue
                              ? model.activeSegmentColor
                              : style.inactiveSegmentColor)
                        .frame(width: segmentWidth, height: style.segmentHeight)
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

    private var validUntilRow: some View {
        Text("Valid Until: \(model.validUntil)")
            .font(.system(size: 14))
            .foregroundColor(.black)
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

// MARK: – Public initialisers

public extension InvestmentProfileCard {

    /// Primary initialiser — provide a fully-configured model.
    init(model: InvestmentProfileModel, onExpandTapped: @escaping () -> Void = {}) {
        self.model           = model
        self.onExpandTapped  = onExpandTapped
    }

    /// Convenience initialiser that builds the model inline with default style.
    init(
        title: String = "Επενδυτικό Προφίλ",
        riskLevel: RiskLevel = .low,
        validUntil: String,
        expiredSince: String? = nil,
        expandButtonLabel: String = "Τι σημαίνει αυτό για εσένα",
        style: InvestmentProfileStyle = .default,
        onExpandTapped: @escaping () -> Void = {}
    ) {
        self.init(
            model: InvestmentProfileModel(
                title: title,
                riskLevel: riskLevel,
                validUntil: validUntil,
                expiredSince: expiredSince,
                expandButtonLabel: expandButtonLabel,
                style: style
            ),
            onExpandTapped: onExpandTapped
        )
    }
}

// MARK: – Previews

#if DEBUG
struct InvestmentProfileCard_Previews: PreviewProvider {

    /// Shows all five risk levels, each with its own distinct default colour.
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                // --- Low (dark green) — matches the original design ---
                InvestmentProfileCard(model: InvestmentProfileModel(
                    riskLevel: .low,
                    validUntil: "January 9, 2028",
                    expiredSince: "January 12, 2026"
                ))
                .previewDisplayName("Low – expired")

                // --- Medium Low (lime green) ---
                InvestmentProfileCard(model: InvestmentProfileModel(
                    riskLevel: .mediumLow,
                    validUntil: "June 30, 2027"
                ))
                .previewDisplayName("Medium Low – valid")

                // --- Medium (amber) ---
                InvestmentProfileCard(model: InvestmentProfileModel(
                    riskLevel: .medium,
                    validUntil: "December 31, 2030"
                ))
                .previewDisplayName("Medium – valid")

                // --- Medium High (orange) ---
                InvestmentProfileCard(model: InvestmentProfileModel(
                    riskLevel: .mediumHigh,
                    validUntil: "September 1, 2028",
                    expiredSince: "September 1, 2025"
                ))
                .previewDisplayName("Medium High – expired")

                // --- High (red) ---
                InvestmentProfileCard(model: InvestmentProfileModel(
                    riskLevel: .high,
                    validUntil: "March 1, 2029",
                    expiredSince: "March 1, 2025"
                ))
                .previewDisplayName("High – expired")

                // --- Custom style: all levels use purple segments ---
                InvestmentProfileCard(model: InvestmentProfileModel(
                    title: "Custom Style",
                    riskLevel: .medium,
                    validUntil: "July 4, 2028",
                    style: InvestmentProfileStyle(
                        segmentColors: Dictionary(
                            uniqueKeysWithValues: RiskLevel.allCases.map { ($0, Color.purple) }
                        ),
                        inactiveSegmentColor : Color(red: 0.88, green: 0.88, blue: 0.88),
                        segmentHeight        : 12,
                        segmentSpacing       : 6,
                        expandButtonColor    : .purple,
                        warningTextColor     : Color(red: 0.85, green: 0.22, blue: 0.22),
                        warningIconColor     : Color(red: 0.95, green: 0.50, blue: 0.13),
                        cardBackground       : Color(white: 0.97),
                        cardCornerRadius     : 20,
                        shadowColor          : Color.purple.opacity(0.15)
                    )
                ))
                .previewDisplayName("Custom (purple)")
            }
            .padding()
        }
        .background(Color(white: 0.2))
        .previewLayout(.sizeThatFits)
    }
}
#endif

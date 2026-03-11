import SwiftUI

// MARK: - Risk Level

/// Represents the investor risk level, ordered from lowest to highest.
public enum RiskLevel: Int, CaseIterable {
    case low = 1
    case mediumLow = 2
    case medium = 3
    case mediumHigh = 4
    case high = 5

    /// Localised display label shown above the segment bar.
    public var label: String {
        switch self {
        case .low:        return "Low"
        case .mediumLow:  return "Medium Low"
        case .medium:     return "Medium"
        case .mediumHigh: return "Medium High"
        case .high:       return "High"
        }
    }
}

// MARK: - InvestmentProfileCard

/// A reusable card that displays an investor's risk profile.
///
/// ### Usage
/// ```swift
/// InvestmentProfileCard(
///     title: "Επενδυτικό Προφίλ",
///     riskLevel: .low,
///     validUntil: "January 9, 2028",
///     expiredSince: "January 12, 2026",
///     expandButtonLabel: "Τι σημαίνει αυτό για εσένα",
///     onExpandTapped: { /* navigate or show sheet */ }
/// )
/// ```
public struct InvestmentProfileCard: View {

    // MARK: – Configuration

    /// Card heading text.
    public var title: String

    /// The investor's current risk level (drives segment colouring).
    public var riskLevel: RiskLevel

    /// The date until which the profile is valid, as a pre-formatted string.
    public var validUntil: String

    /// Optional expiry date. When non-nil an orange warning row is shown.
    public var expiredSince: String?

    /// Label for the expandable information button.
    public var expandButtonLabel: String

    /// Closure called when the user taps the expand button.
    public var onExpandTapped: () -> Void

    // MARK: – Internal state

    @State private var isExpanded: Bool = false

    // MARK: – Design tokens

    private let activeColor   = Color(red: 0.16, green: 0.44, blue: 0.18)  // dark green
    private let inactiveColor = Color(red: 0.88, green: 0.88, blue: 0.88)  // light gray
    private let expandColor   = Color(red: 0.00, green: 0.45, blue: 0.70)  // blue link
    private let warningColor  = Color(red: 0.85, green: 0.22, blue: 0.22)  // red warning
    private let warningIconColor = Color(red: 0.95, green: 0.50, blue: 0.13) // orange triangle

    private let segmentCount   = 5
    private let segmentHeight  : CGFloat = 12
    private let segmentSpacing : CGFloat = 6
    private let cardCorner     : CGFloat = 16

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
                .padding(.bottom, expiredSince != nil ? 12 : 0)

            if let expired = expiredSince {
                expiredRow(date: expired)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(cardCorner)
        .shadow(color: Color.black.opacity(0.10), radius: 12, x: 0, y: 4)
    }

    // MARK: – Subviews

    private var titleSection: some View {
        Text(title)
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.black)
    }

    private var riskBarSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(riskLevel.label)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(activeColor)

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
            let totalSpacing = segmentSpacing * CGFloat(segmentCount - 1)
            let segmentWidth = (geo.size.width - totalSpacing) / CGFloat(segmentCount)

            HStack(spacing: segmentSpacing) {
                ForEach(1...segmentCount, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(index <= riskLevel.rawValue ? activeColor : inactiveColor)
                        .frame(width: segmentWidth, height: segmentHeight)
                }
            }
        }
        .frame(height: segmentHeight)
    }

    private var expandButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded.toggle()
            }
            onExpandTapped()
        }) {
            HStack(spacing: 4) {
                Text(expandButtonLabel)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(expandColor)

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(expandColor)
            }
        }
        .buttonStyle(.plain)
    }

    private var validUntilRow: some View {
        Text("Valid Until: \(validUntil)")
            .font(.system(size: 14))
            .foregroundColor(.black)
    }

    private func expiredRow(date: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(warningIconColor)

            Text("Expired since: \(date)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(warningColor)
        }
    }
}

// MARK: – Public initialiser (memberwise with defaults)

public extension InvestmentProfileCard {
    init(
        title: String = "Επενδυτικό Προφίλ",
        riskLevel: RiskLevel = .low,
        validUntil: String,
        expiredSince: String? = nil,
        expandButtonLabel: String = "Τι σημαίνει αυτό για εσένα",
        onExpandTapped: @escaping () -> Void = {}
    ) {
        self.title              = title
        self.riskLevel          = riskLevel
        self.validUntil         = validUntil
        self.expiredSince       = expiredSince
        self.expandButtonLabel  = expandButtonLabel
        self.onExpandTapped     = onExpandTapped
    }
}

// MARK: – Previews

#if DEBUG
struct InvestmentProfileCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Matches the design in the issue exactly
            InvestmentProfileCard(
                riskLevel: .low,
                validUntil: "January 9, 2028",
                expiredSince: "January 12, 2026"
            )
            .padding()
            .background(Color(white: 0.2))
            .previewDisplayName("Low – expired")

            // Medium risk, still valid
            InvestmentProfileCard(
                riskLevel: .medium,
                validUntil: "December 31, 2030"
            )
            .padding()
            .background(Color(white: 0.2))
            .previewDisplayName("Medium – valid")

            // High risk, all five segments filled
            InvestmentProfileCard(
                riskLevel: .high,
                validUntil: "March 1, 2029",
                expiredSince: "March 1, 2025"
            )
            .padding()
            .background(Color(white: 0.2))
            .previewDisplayName("High – expired")
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif

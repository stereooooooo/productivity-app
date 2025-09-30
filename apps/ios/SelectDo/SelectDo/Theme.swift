import Combine
import SwiftUI

enum Spacing {
    static let sectionV: CGFloat = 14
    static let stackV: CGFloat = 8
    static let rowV: CGFloat = 6
}

public enum UIModeDensity: String, CaseIterable, Identifiable {
    case standard, compact
    public var id: String { rawValue }
}

public struct DensityTokens {
    public let baseFont: Font
    public let titleFont: Font
    public let labelFont: Font
    public let chipFont: Font
    public let rowVPad: CGFloat
    public let rowHPad: CGFloat
    public let sectionTop: CGFloat
    public let sectionInner: CGFloat
    public let cardCorner: CGFloat
    public let chipHPad: CGFloat
    public let chipVPad: CGFloat

    public static let standard = DensityTokens(
        baseFont: .callout,
        titleFont: .title3,
        labelFont: .subheadline,
        chipFont: .caption,
        rowVPad: Spacing.rowV,
        rowHPad: 12,
        sectionTop: Spacing.sectionV,
        sectionInner: Spacing.stackV,
        cardCorner: 16,
        chipHPad: 7,
        chipVPad: 3
    )

    public static let compact = DensityTokens(
        baseFont: .footnote,
        titleFont: .headline,
        labelFont: .footnote,
        chipFont: .caption2,
        rowVPad: 4,
        rowHPad: 10,
        sectionTop: 10,
        sectionInner: 6,
        cardCorner: 14,
        chipHPad: 6,
        chipVPad: 2
    )
}

public final class AppTheme: ObservableObject {
    public static let shared = AppTheme()
    @Published public var density: UIModeDensity = .standard

    public var tokens: DensityTokens {
        density == .compact ? .compact : .standard
    }

    static let surface = Color(.systemGroupedBackground)
    static let surfaceCard = Color(.systemBackground)
    static let border = Color(.quaternaryLabel)
    static let accent = Color.accentColor
    static let positive = Color.green
    static let warning = Color.orange

    static let cardShadow = Color.black.opacity(0.05)

    static var cardRadius: CGFloat { shared.tokens.cardCorner }
    static var blockSpacing: CGFloat { 28 }
    static var innerSpacing: CGFloat { shared.tokens.sectionInner }

    static func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(shared.tokens.titleFont.weight(.semibold))
            .foregroundStyle(.primary)
    }
}

struct SectionHeaderView: View {
    var title: String
    var body: some View {
        Text(title)
            .font(.title3.weight(.semibold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 6)
            .overlay(Divider().offset(y: 12), alignment: .bottom)
    }
}

struct Chip: View {
    var text: String
    var selected: Bool = false
    var body: some View {
        Text(text)
            .font(AppTheme.shared.tokens.chipFont.weight(.semibold))
            .padding(.horizontal, AppTheme.shared.tokens.chipHPad)
            .padding(.vertical, AppTheme.shared.tokens.chipVPad)
            .background(selected ? AppTheme.accent : .clear)
            .foregroundStyle(selected ? .white : .primary)
            .clipShape(Capsule())
            .overlay(
                Capsule().strokeBorder(Color.secondary.opacity(selected ? 0 : 0.3))
            )
    }
}

struct TagPill: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.footnote)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(.thinMaterial)
            .clipShape(Capsule())
    }
}

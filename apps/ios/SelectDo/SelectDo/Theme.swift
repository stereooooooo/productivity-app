import Combine
import SwiftUI

enum UI {
    enum Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let s: CGFloat = 6
        static let m: CGFloat = 8
        static let l: CGFloat = 12
    }

    enum Radius {
        static let chip: CGFloat = 8
        static let card: CGFloat = 14
    }

    enum Fonts {
        static let title: Font = .system(size: 20, weight: .semibold)
        static let rowTitle: Font = .system(size: 17, weight: .semibold)
        static let meta: Font = .system(size: 12, weight: .regular)
        static let micro: Font = .system(size: 11, weight: .regular)
    }
}

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
            .font(UI.Fonts.meta)
            .fontWeight(.semibold)
            .padding(.horizontal, UI.Spacing.xs)
            .padding(.vertical, UI.Spacing.xs)
            .background(
                (selected ? AppTheme.accent : Color.secondary.opacity(0.12)),
                in: RoundedRectangle(cornerRadius: UI.Radius.chip, style: .continuous)
            )
            .foregroundStyle(selected ? .white : .primary)
    }
}

struct TagPill: View {
    var text: String
    var style: Color = .secondary.opacity(0.12)
    var body: some View {
        Text(text)
            .font(UI.Fonts.meta)
            .padding(.horizontal, UI.Spacing.s)
            .padding(.vertical, UI.Spacing.xs)
            .background(style, in: RoundedRectangle(cornerRadius: UI.Radius.chip, style: .continuous))
    }
}

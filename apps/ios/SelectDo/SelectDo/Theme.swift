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

public enum UIModeDensity: String, CaseIterable, Identifiable {
    case standard, compact
    public var id: String { rawValue }
}

public final class AppTheme: ObservableObject {
    public static let shared = AppTheme()
    struct Typography {
        static let title = Font.subheadline.weight(.semibold)
        static let rowTitle = Font.subheadline
        static let meta = Font.caption
    }

    struct Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let s: CGFloat = 6
        static let rowV: CGFloat = 6
        static let rowH: CGFloat = 12
        static let sectionV: CGFloat = 10
        static let chipH: CGFloat = 8
        static let chipV: CGFloat = 3
        static let stackV: CGFloat = 8
    }

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
        titleFont: AppTheme.Typography.title,
        labelFont: .subheadline,
        chipFont: AppTheme.Typography.meta,
        rowVPad: AppTheme.Spacing.rowV,
        rowHPad: AppTheme.Spacing.rowH,
        sectionTop: AppTheme.Spacing.sectionV,
        sectionInner: AppTheme.Spacing.stackV,
        cardCorner: UI.Radius.card,
        chipHPad: AppTheme.Spacing.chipH,
        chipVPad: AppTheme.Spacing.chipV
    )

    public static let compact = DensityTokens(
        baseFont: .footnote,
        titleFont: AppTheme.Typography.title,
        labelFont: .footnote,
        chipFont: AppTheme.Typography.meta,
        rowVPad: AppTheme.Spacing.rowV,
        rowHPad: AppTheme.Spacing.rowH,
        sectionTop: AppTheme.Spacing.sectionV,
        sectionInner: AppTheme.Spacing.stackV,
        cardCorner: UI.Radius.card,
        chipHPad: AppTheme.Spacing.chipH,
        chipVPad: AppTheme.Spacing.chipV
    )
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
            .font(AppTheme.Typography.meta.weight(.semibold))
            .padding(.horizontal, AppTheme.Spacing.chipH)
            .padding(.vertical, AppTheme.Spacing.chipV)
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
            .font(AppTheme.Typography.meta)
            .padding(.horizontal, AppTheme.Spacing.chipH)
            .padding(.vertical, AppTheme.Spacing.chipV)
            .background(style, in: RoundedRectangle(cornerRadius: UI.Radius.chip, style: .continuous))
    }
}

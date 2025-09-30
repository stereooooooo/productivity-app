import Combine
import SwiftUI

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
        baseFont: .callout,                // ~16pt
        titleFont: .title3,                // section titles
        labelFont: .subheadline,
        chipFont: .caption,
        rowVPad: 10, rowHPad: 14,
        sectionTop: 24, sectionInner: 12,
        cardCorner: 16,
        chipHPad: 8, chipVPad: 5
    )

    public static let compact = DensityTokens(
        baseFont: .footnote,               // ~13pt
        titleFont: .headline,              // tighter
        labelFont: .footnote,
        chipFont: .caption2,
        rowVPad: 6, rowHPad: 10,
        sectionTop: 16, sectionInner: 8,
        cardCorner: 14,
        chipHPad: 6, chipVPad: 3
    )
}

public final class AppTheme: ObservableObject {
    public static let shared = AppTheme()
    @Published public var density: UIModeDensity = .standard

    public var tokens: DensityTokens {
        density == .compact ? .compact : .standard
    }

    // Colors (semantic)
    static let surface = Color(.systemGroupedBackground)
    static let surfaceCard = Color(.systemBackground)
    static let border = Color(.quaternaryLabel)
    static let accent = Color.accentColor
    static let positive = Color.green
    static let warning = Color.orange

    // Shadows
    static let cardShadow = Color.black.opacity(0.05)

    // Layout constants read from tokens for backwards compatibility
    static var cardRadius: CGFloat { shared.tokens.cardCorner }
    static var blockSpacing: CGFloat { 32 }
    static var innerSpacing: CGFloat { shared.tokens.sectionInner }

    // Typography helpers
    static func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(shared.tokens.titleFont.weight(.semibold))
            .foregroundStyle(.primary)
    }
}

// Reusable UI bits
struct SectionHeaderView: View {
    var title: String
    var body: some View {
        AppTheme.sectionTitle(title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, AppTheme.shared.tokens.sectionTop)
            .padding(.bottom, AppTheme.shared.tokens.sectionInner)
            .overlay(Divider(), alignment: .bottom)
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
    var text: String
    var body: some View {
        Text(text)
            .font(AppTheme.shared.tokens.chipFont)
            .padding(.horizontal, AppTheme.shared.tokens.chipHPad)
            .padding(.vertical, AppTheme.shared.tokens.chipVPad)
            .background(Color.secondary.opacity(0.12))
            .clipShape(Capsule())
    }
}

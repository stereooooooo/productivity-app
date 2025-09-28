import SwiftUI

enum AppTheme {
    // Spacing & layout
    static let blockSpacing: CGFloat = 32
    static let innerSpacing: CGFloat = 12
    static let cardRadius: CGFloat = 16

    // Colors (semantic)
    static let surface = Color(.systemGroupedBackground)
    static let surfaceCard = Color(.systemBackground)
    static let border = Color(.quaternaryLabel)
    static let accent = Color.accentColor
    static let positive = Color.green
    static let warning = Color.orange

    // Shadows
    static let cardShadow = Color.black.opacity(0.05)

    // Typography helpers
    static func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.title3.weight(.semibold))
            .foregroundStyle(.primary)
    }
}

// Reusable UI bits
struct SectionHeaderView: View {
    var title: String
    var body: some View {
        AppTheme.sectionTitle(title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 4)
            .overlay(Divider(), alignment: .bottom)
    }
}

struct Chip: View {
    var text: String
    var selected: Bool = false
    var body: some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
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
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.secondary.opacity(0.12))
            .clipShape(Capsule())
    }
}

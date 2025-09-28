import SwiftUI

enum AppTheme {
    static let cardRadius: CGFloat = 16
    static let chipRadius: CGFloat = 999
    static let sectionSpacing: CGFloat = 24
    static let blockSpacing: CGFloat = 32
}

struct SectionHeaderView: View {
    var title: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
            Divider().opacity(0.25)
        }
        .padding(.top, AppTheme.sectionSpacing)
    }
}

struct Chip: View {
    var text: String
    var selected: Bool = false
    var body: some View {
        Text(text)
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(selected ? Color.accentColor : Color(.secondarySystemBackground))
            .foregroundStyle(selected ? .white : .primary)
            .clipShape(Capsule())
    }
}

struct TagPill: View {
    var text: String
    var tint: Color = .blue.opacity(0.15)
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(tint)
            .clipShape(Capsule())
    }
}
import SwiftUI

struct ReviewView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.blockSpacing) {

                // Completed Today
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeaderView(title: "Completed Today")

                    Card {
                        if store.completedToday.isEmpty {
                            Text("No tasks completed yet. Start a task to see progress here.")
                                .foregroundStyle(.secondary)
                                .padding(.vertical, 4)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(store.completedToday) { t in
                                    HStack(alignment: .firstTextBaseline) {
                                        Text(t.title)
                                            .font(.subheadline)
                                            .foregroundStyle(.primary)
                                            .lineLimit(2)
                                            .multilineTextAlignment(.leading)
                                        Spacer(minLength: 12)
                                        Text("\(t.minutes) min")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    if t.id != store.completedToday.last?.id {
                                        Divider().opacity(0.2)
                                    }
                                }
                            }
                        }
                    }
                }

                // Weekly Insights
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeaderView(title: "Weekly Insights")

                    Card {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundStyle(.blue)
                                Text("Most productive context: \(mostContext)")
                                    .font(.subheadline)
                            }

                            Divider().opacity(0.2)

                            HStack(spacing: 8) {
                                Image(systemName: "timer")
                                    .foregroundStyle(.blue)
                                Text("Preferred time bracket: \(prefTime)")
                                    .font(.subheadline)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Simple insight calcs

    private var mostContext: String {
        Dictionary(grouping: store.tasks.filter { $0.completedAt != nil }, by: { $0.context })
            .max(by: { $0.value.count < $1.value.count })?.key ?? "—"
    }

    private var prefTime: String {
        let mins = store.tasks.compactMap { $0.completedAt == nil ? nil : $0.minutes }
        guard let avg = mins.average else { return "—" }
        switch avg {
        case ..<15: return "Quick"
        case ..<35: return "Standard"
        default:    return "Long"
        }
    }
}

// MARK: - Reusable Card

private struct Card<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        VStack { content }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cardRadius)
                    .stroke(.quaternary, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Helpers

private extension Array where Element == Int {
    var average: Double? { isEmpty ? nil : Double(reduce(0,+)) / Double(count) }
}
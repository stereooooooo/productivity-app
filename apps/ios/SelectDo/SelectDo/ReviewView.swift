import SwiftData
import SwiftUI

struct ReviewView: View {
    @Query(sort: \TaskModel.updatedAt, order: .reverse, animation: .default)
    private var allTasks: [TaskModel]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.blockSpacing) {
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeaderView(title: "Completed Today")
                    VStack(spacing: 8) {
                        ForEach(completedToday) { m in
                            HStack {
                                Text(m.title).lineLimit(1)
                                Spacer()
                                Text("\(m.minutes) min").foregroundStyle(.secondary)
                            }
                            .padding(12)
                            .background(AppTheme.surfaceCard)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.border))
                        }
                        if completedToday.isEmpty {
                            Text("No tasks completed yet. Start a task to see progress here.")
                                .foregroundStyle(.secondary)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(AppTheme.surfaceCard)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.border))
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    SectionHeaderView(title: "Weekly Insights")
                    Card(title: "Most productive context:", value: mostProductiveContext)
                    Card(title: "Preferred time bracket:", value: preferredTimeBracket)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
            .background(AppTheme.surface)
        }
    }

    private var completedToday: [TaskModel] {
        let cal = Calendar.current
        return allTasks.filter { $0.completedAt.map { cal.isDateInToday($0) } ?? false }
    }

    private var mostProductiveContext: String {
        let personal = completedToday.filter { $0.context == "Personal" }.count
        let work = completedToday.filter { $0.context == "Work" }.count
        if personal == 0, work == 0 { return "—" }
        return work >= personal ? "Work" : "Personal"
    }

    private var preferredTimeBracket: String {
        let mins = completedToday.map(\.minutes)
        guard !mins.isEmpty else { return "—" }
        let avg = mins.reduce(0,+) / mins.count
        switch avg {
        case 0 ..< 20: return "Quick"
        case 20 ..< 40: return "Standard"
        default: return "Long"
        }
    }
}

private struct Card: View {
    var title: String
    var value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label { Text(title) } icon: { Image(systemName: "chart.bar") }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value).font(.headline)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))
        .overlay(RoundedRectangle(cornerRadius: AppTheme.cardRadius).stroke(AppTheme.border))
    }
}

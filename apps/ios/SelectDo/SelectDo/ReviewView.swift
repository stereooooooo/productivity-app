import SwiftUI

struct ReviewView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        List {
            Section("Completed Today") {
                if store.completedToday.isEmpty {
                    Text("No tasks completed yet. Start a task to see progress here.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(store.completedToday) { t in
                        HStack {
                            Text(t.title)
                            Spacer()
                            Text("\(t.minutes) min").foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section("Weekly Insights") {
                Label("Most productive context: \(mostContext)", systemImage: "chart.bar.xaxis")
                Label("Preferred time bracket: \(prefTime)", systemImage: "timer")
            }
        }
    }

    private var mostContext: String {
        Dictionary(grouping: store.tasks.filter{ $0.completedAt != nil }, by: { $0.context })
            .max(by: { $0.value.count < $1.value.count })?.key ?? "—"
    }
    private var prefTime: String {
        let mins = store.tasks.compactMap { $0.completedAt == nil ? nil : $0.minutes }
        guard let avg = mins.average else { return "—" }
        switch avg {
        case ..<15: return "Quick"
        case ..<35: return "Standard"
        default: return "Long"
        }
    }
}

private extension Array where Element == Int {
    var average: Double? { isEmpty ? nil : Double(reduce(0,+)) / Double(count) }
}
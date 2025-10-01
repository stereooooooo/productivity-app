import SwiftUI

struct TaskRow: View {
    let task: TaskModel
    var onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: UI.Spacing.xs) {
            Text(task.title)
                .font(UI.Fonts.rowTitle)
            HStack(spacing: UI.Spacing.s) {
                TagPill(text: task.kind)
                TagPill(text: task.context)
                TagPill(text: "\(task.minutes) min")
                if task.isPriority {
                    TagPill(text: "⭐︎ Priority", style: Color.yellow.opacity(0.18))
                }
            }
        }
        .padding(.vertical, UI.Spacing.s)
        .contentShape(Rectangle())
        .onTapGesture(perform: onStart)
    }
}

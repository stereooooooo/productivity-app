import SwiftUI

struct TaskRow: View {
    let task: TaskModel
    var onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text(task.title)
                .font(AppTheme.Typography.rowTitle)
            HStack(spacing: AppTheme.Spacing.s) {
                TagPill(text: task.kind)
                TagPill(text: task.context)
                TagPill(text: "\(task.minutes) min")
                if task.isPriority {
                    TagPill(text: "⭐︎ Priority", style: Color.yellow.opacity(0.18))
                }
            }
        }
        .padding(.vertical, AppTheme.Spacing.rowV)
        .contentShape(Rectangle())
        .onTapGesture(perform: onStart)
    }
}

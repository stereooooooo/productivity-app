import SwiftUI

struct TodaySectionView: View {
    let tasks: [TaskModel]
    var onStart: (TaskModel) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.s) {
            header
            VStack(spacing: 0) {
                ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                    if index > 0 {
                        Rectangle()
                            .fill(Color.black.opacity(0.06))
                            .frame(height: 1)
                            .padding(.leading, AppTheme.Spacing.rowH)
                    }
                    TaskRow(task: task) {
                        onStart(task)
                    }
                    .padding(.horizontal, AppTheme.Spacing.rowH)
                    .padding(.vertical, AppTheme.Spacing.rowV)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: UI.Radius.card, style: .continuous)
                    .fill(.thinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: UI.Radius.card, style: .continuous)
                            .fill(Color.yellow.opacity(0.08))
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: UI.Radius.card, style: .continuous))
        }
    }

    private var header: some View {
        HStack(spacing: AppTheme.Spacing.s) {
            Image(systemName: "star.fill")
                .font(.caption)
                .foregroundStyle(.white)
                .frame(width: 18, height: 18)
                .background(Circle().fill(Color.yellow))
            Text("Today")
                .font(AppTheme.Typography.title)
            Spacer(minLength: 0)
        }
        .padding(.bottom, AppTheme.Spacing.xs)
    }
}

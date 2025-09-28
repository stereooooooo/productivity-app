import SwiftData
import SwiftUI

// Thin wrapper that owns @Query
struct FindTaskView: View {
    @Query private var allTasks: [TaskModel]
    @State private var showAdvancedFilters = false

    init() { _allTasks = Query() }

    var body: some View {
        FindTaskContent(allTasks: allTasks, showAdvancedFilters: $showAdvancedFilters)
            .sheet(isPresented: $showAdvancedFilters) {
                AdvancedFiltersSheet()
                    .presentationDetents([.medium, .large])
            }
    }
}

private struct FindTaskContent: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.modelContext) private var ctx

    let allTasks: [TaskModel]
    @Binding var showAdvancedFilters: Bool

    private let contexts = ["Work", "Personal"]
    private let times = [5, 10, 15, 20, 25, 30, 45, 60]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.blockSpacing) {
                // Mode
                ModeSection(
                    title: "What Mode Are You In?",
                    contexts: contexts,
                    activeContext: store.activeContext,
                    onSelect: { c in
                        store.activeContext = c
                        if store.hapticsEnabled { Haptics.light() }
                    }
                )

                // Time
                TimeSection(
                    title: "How Much Time Do You Have?",
                    times: times,
                    selected: store.selectedMinutes,
                    onSelect: { sel in
                        store.selectedMinutes = sel
                        if store.hapticsEnabled { Haptics.light() }
                    },
                    priorityOnly: $store.priorityOnly,
                    onReset: {
                        store.activeContext = "Personal"
                        store.selectedMinutes = 15
                        store.priorityOnly = false
                    },
                    onReshuffle: { store.reshuffleID = UUID() }
                )

                // Advanced shell
                AdvancedFiltersSection {
                    showAdvancedFilters = true
                    if store.hapticsEnabled { Haptics.light() }
                }

                // Tasks
                TasksSection(
                    title: "Pick a Task",
                    models: filteredModels,
                    onDelete: { model in
                        ctx.delete(model)
                        try? ctx.save()
                    },
                    onTogglePriority: { model in
                        model.isPriority.toggle()
                        model.updatedAt = .now
                        try? ctx.save()
                    },
                    onStart: { model in
                        store.startFocus(model)
                    }
                )
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        // Present sheet only when both session & model are set
        .sheet(
            isPresented: Binding(
                get: { store.activeSession != nil && store.activeModel != nil },
                set: { isPresented in
                    if !isPresented { store.finishFocus() }
                }
            )
        ) {
            if let session = store.activeSession, let model = store.activeModel {
                FocusSheet(session: session, model: model) {
                    store.finishFocus()
                }
                .presentationDetents([.height(320), .medium, .large])
            }
        }
        .background(AppTheme.surface)
    }

    // MARK: - Filtering

    private var filteredModels: [TaskModel] {
        let base = allTasks
        let byContext = base.filter { $0.context == store.activeContext }
        let open = byContext.filter { $0.completedAt == nil }
        let byTime: [TaskModel] = if let limit = store.selectedMinutes {
            open.filter { $0.minutes <= limit }
        } else {
            open
        }
        let byPriority = store.priorityOnly ? byTime.filter(\.isPriority) : byTime

        var sorted = byPriority.sorted { $0.updatedAt > $1.updatedAt }
        _ = store.reshuffleID
        sorted.shuffle()
        return sorted
    }
}

// MARK: - Subviews

private struct ModeSection: View {
    var title: String
    var contexts: [String]
    var activeContext: String
    var onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: title)
            FlowLayout(spacing: 8, rowSpacing: 8) {
                ForEach(contexts, id: \.self) { ctx in
                    Button { onSelect(ctx) } label: {
                        Chip(text: ctx, selected: activeContext == ctx)
                    }
                }
            }
        }
    }
}

private struct TimeSection: View {
    var title: String
    var times: [Int]
    var selected: Int?
    var onSelect: (Int?) -> Void

    @Binding var priorityOnly: Bool
    var onReset: () -> Void
    var onReshuffle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: title)
            FlowLayout(spacing: 12, rowSpacing: 10) {
                ForEach(times, id: \.self) { m in
                    Button { onSelect(m) } label: {
                        Chip(text: "\(m) min", selected: selected == m)
                    }
                }
                Button { onSelect(nil) } label: {
                    Chip(text: "Custom", selected: selected == nil)
                }
            }
            HStack(spacing: 16) {
                Toggle("Priority Only", isOn: $priorityOnly).toggleStyle(.switch)
                Spacer()
                Button("Reset", action: onReset)
                Button { onReshuffle() } label: { Label("Reshuffle", systemImage: "shuffle") }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
    }
}

private struct AdvancedFiltersSection: View {
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: "slider.horizontal.3")
                    .imageScale(.medium)
                    .foregroundStyle(.secondary)
                Text("Advanced filters")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(AppTheme.surfaceCard)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: AppTheme.cardRadius).stroke(AppTheme.border, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

private struct TasksSection: View {
    var title: String
    var models: [TaskModel]
    var onDelete: (TaskModel) -> Void
    var onTogglePriority: (TaskModel) -> Void
    var onStart: (TaskModel) -> Void

    @State private var editing: TaskModel?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: title)

            if models.isEmpty {
                Text("No tasks match. Try a different time or context.")
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(models) { model in
                        TaskCard(model: model) { onStart(model) }
                            .onTapGesture { editing = model } // 👈 open editor
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) { onDelete(model) } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                Button { onTogglePriority(model) } label: {
                                    Label("Priority", systemImage: "star.fill")
                                }
                                .tint(.orange)
                            }
                    }
                }
            }
        }
        .sheet(item: $editing) { m in
            TaskEditorSheet(model: m)
                .presentationDetents([.medium, .large])
        }
    }
}

private struct TaskCard: View {
    var model: TaskModel
    var onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(model.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                if model.isPriority {
                    Image(systemName: "star.fill").foregroundStyle(.orange).imageScale(.small)
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
                    .imageScale(.small)
                    .opacity(0.6)
            }
            HStack(spacing: 8) {
                TagPill(text: model.kind)
                TagPill(text: model.context)
                TagPill(text: "\(model.minutes) min")
            }
            Button(action: onStart) {
                Label("Start", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .padding(14)
        .background(AppTheme.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: AppTheme.cardRadius).stroke(AppTheme.border, lineWidth: 1))
        .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
    }
}

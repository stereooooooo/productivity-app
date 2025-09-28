import SwiftUI

struct TasksView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showTaskCreator = false
    @State private var expandedGroups: Set<String> = []
    @State private var initializedGroups: Set<String> = []

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppTheme.blockSpacing) {
                    todaySection

                    ForEach(taskGroups, id: \.title) { group in
                        ProjectSection(
                            title: group.title,
                            tasks: group.tasks,
                            isExpanded: Binding(
                                get: { expandedGroups.contains(group.title) },
                                set: { newValue in
                                    if newValue {
                                        expandedGroups.insert(group.title)
                                    } else {
                                        expandedGroups.remove(group.title)
                                    }
                                }
                            ),
                            onTogglePriority: { togglePriority($0) },
                            onDelete: { delete($0) }
                        )
                        .onAppear {
                            guard !initializedGroups.contains(group.title) else { return }
                            if !group.tasks.isEmpty {
                                expandedGroups.insert(group.title)
                            }
                            initializedGroups.insert(group.title)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 24)
                .padding(.bottom, 140)
            }
            .background(AppTheme.surface)

            addButton
                .padding(.trailing, 20)
                .padding(.bottom, 72) // small gap above the floating bar
        }
        .sheet(isPresented: $showTaskCreator) {
            NavigationStack {
                AddTaskView()
                    .navigationTitle("New Task")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { showTaskCreator = false }
                        }
                    }
            }
        }
    }

    private var taskGroups: [(title: String, tasks: [TaskItem])] {
        let work = store.tasks.filter { $0.context == "Work" }
        let personal = store.tasks.filter { $0.context == "Personal" }
        let learning = store.tasks.filter { $0.context == "Learning" }

        var groups: [(String, [TaskItem])] = []
        if !work.isEmpty { groups.append(("Work Projects", work)) }
        if !personal.isEmpty { groups.append(("Personal", personal)) }
        if !learning.isEmpty { groups.append(("Learning", learning)) }
        return groups
    }

    private func togglePriority(_ task: TaskItem) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            store.togglePriority(task)
            if store.hapticsEnabled { Haptics.light() }
        }
    }

    private func delete(_ task: TaskItem) {
        withAnimation(.easeInOut) {
            store.delete(task)
            if store.hapticsEnabled { Haptics.light() }
        }
    }

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today")
                .font(.headline)
                .foregroundStyle(.primary)

            if store.tasks.isEmpty {
                Text("No tasks planned for today")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.surfaceCard)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(store.tasks) { task in
                        TaskRow(task: task)
                    }
                }
            }
        }
    }

    private var addButton: some View {
        Button {
            showTaskCreator = true
            if store.hapticsEnabled { Haptics.light() }
        } label: {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 56, height: 56)
                .overlay(
                    Circle()
                        .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                )
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 8)
        }
        .accessibilityLabel("Add Task")
    }
}

private struct ProjectSection: View {
    var title: String
    var tasks: [TaskItem]
    @Binding var isExpanded: Bool
    var onTogglePriority: (TaskItem) -> Void
    var onDelete: (TaskItem) -> Void

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            if tasks.isEmpty {
                Text("No tasks yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 8)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 12) {
                    ForEach(tasks) { task in
                        TaskRow(task: task)
                            .padding(.leading, 12)
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    onTogglePriority(task)
                                } label: {
                                    Label(task.isPriority ? "Unstar" : "Star", systemImage: task.isPriority ? "star.slash" : "star.fill")
                                }
                                .tint(.orange)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    onDelete(task)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .padding(.top, 12)
            }
        } label: {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
        }
        .accentColor(.primary)
    }
}

private struct TaskRow: View {
    @EnvironmentObject private var store: AppStore
    var task: TaskItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(task.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)

                FlowLayout(spacing: 8, rowSpacing: 8) {
                    TagPill(text: task.kind)
                    TagPill(text: task.context)
                    TagPill(text: "\(task.minutes) min")
                    if task.isPriority {
                        TagPill(text: "⭐️ Priority")
                    }
                }
            }

            Spacer(minLength: 12)

            Button(action: startFocus) {
                Chip(text: "Start", selected: true)
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func startFocus() {
        store.startFocus(task)
        if store.hapticsEnabled { Haptics.light() }
    }
}

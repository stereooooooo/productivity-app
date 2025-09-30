import SwiftUI

struct TasksView: View {
    @EnvironmentObject private var store: AppStore
    @StateObject private var theme = AppTheme.shared
    @State private var showTaskCreator = false
    @State private var collapsed: Set<String> = []
    @State private var query = ""

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppTheme.blockSpacing) {
                todaySection
                searchSection

                ForEach(taskGroups, id: \.title) { group in
                    projectDisclosure(for: group.title, tasks: group.tasks)
                }
            }
            .padding(.horizontal)
            .padding(.top, theme.tokens.sectionTop)
        }
        .padding(.bottom, 140)
        .background(AppTheme.surface)
        .overlay(alignment: Alignment.bottomTrailing) {
            addButton
                .padding(.trailing, 18)
                .padding(.bottom, 86)
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

    private var hasQuery: Bool { query.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 }

    private var filteredTasks: [TaskItem] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else { return store.tasks }
        return store.tasks.filter { $0.title.localizedCaseInsensitiveContains(trimmed) }
    }

    private var taskGroups: [(title: String, tasks: [TaskItem])] {
        let work = filteredTasks.filter { $0.context == "Work" }
        let personal = filteredTasks.filter { $0.context == "Personal" }
        let learning = filteredTasks.filter { $0.context == "Learning" }

        return [
            ("Work Projects", work),
            ("Personal", personal),
            ("Learning", learning),
        ]
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

    private func startFocus(_ task: TaskItem) {
        store.startFocus(task)
        if store.hapticsEnabled { Haptics.light() }
    }

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: theme.tokens.sectionInner) {
            Text("Today")
                .font(theme.tokens.titleFont)
                .foregroundStyle(.primary)

            if filteredTasks.isEmpty {
                Text(hasQuery ? "No tasks match your search" : "No tasks planned for today")
                    .font(theme.tokens.labelFont)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, theme.tokens.rowVPad * 1.2)
                    .padding(.horizontal, theme.tokens.rowHPad)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(alignment: .leading, spacing: theme.tokens.sectionInner) {
                    ForEach(filteredTasks) { task in
                        TaskRow(task: task, theme: theme)
                    }
                }
            }
        }
    }

    private var searchSection: some View {
        VStack(alignment: .leading, spacing: theme.tokens.sectionInner) {
            SectionHeaderView(title: "Search")

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search tasks", text: $query)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                if !query.isEmpty {
                    Button {
                        query = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear search")
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: theme.tokens.cardCorner)
                    .fill(.ultraThinMaterial)
            )
        }
    }

    private var addButton: some View {
        Button {
            showTaskCreator = true
            if store.hapticsEnabled { Haptics.light() }
        } label: {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 52, height: 52)
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                )
                .shadow(color: Color.black.opacity(0.10), radius: 16, x: 0, y: 8)
        }
        .accessibilityLabel("Add Task")
    }
}

private struct TaskRow: View {
    @EnvironmentObject private var store: AppStore
    var task: TaskItem
    @ObservedObject var theme: AppTheme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.tokens.sectionInner / 2) {
            Text(task.title)
                .font(theme.tokens.labelFont.weight(.semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)

            FlowLayout(spacing: theme.tokens.chipHPad, rowSpacing: 4) {
                TagPill(text: task.kind)
                TagPill(text: task.context)
                TagPill(text: "\(task.minutes) min")
                if task.isPriority {
                    TagPill(text: "⭐️ Priority")
                }
            }
        }
        .padding(.vertical, theme.tokens.rowVPad)
        .padding(.horizontal, theme.tokens.rowHPad)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.clear)
        .contentShape(Rectangle())
        .onTapGesture { startFocus() }
    }

    private func startFocus() {
        store.startFocus(task)
        if store.hapticsEnabled { Haptics.light() }
    }
}

private extension TasksView {
    func isCollapsed(_ key: String) -> Bool { collapsed.contains(key) }

    func toggle(_ key: String) {
        if collapsed.contains(key) {
            collapsed.remove(key)
        } else {
            collapsed.insert(key)
        }
    }

    @ViewBuilder
    func projectDisclosure(for title: String, tasks: [TaskItem]) -> some View {
        DisclosureGroup(
            isExpanded: Binding(
                get: { !isCollapsed(title) },
                set: { newValue in
                    if newValue {
                        collapsed.remove(title)
                    } else {
                        collapsed.insert(title)
                    }
                }
            )
        ) {
            if tasks.isEmpty {
                Text(hasQuery ? "No tasks match your search" : "No tasks yet")
                    .font(theme.tokens.labelFont)
                    .foregroundStyle(.secondary)
                    .padding(.leading, theme.tokens.rowHPad / 2)
                    .padding(.vertical, theme.tokens.rowVPad / 2)
            } else {
                VStack(spacing: theme.tokens.sectionInner) {
                    ForEach(tasks) { task in
                        TaskRow(task: task, theme: theme)
                            .padding(.leading, theme.tokens.rowHPad)
                            .padding(.vertical, theme.tokens.rowVPad)
                            .contentShape(Rectangle())
                            .onTapGesture { startFocus(task) }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    togglePriority(task)
                                } label: {
                                    Label(task.isPriority ? "Unstar" : "Star", systemImage: task.isPriority ? "star.slash" : "star.fill")
                                }
                                .tint(.orange)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    delete(task)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
        } label: {
            HStack {
                Text(title)
                    .font(theme.tokens.titleFont)
                Spacer()
                Image(systemName: isCollapsed(title) ? "chevron.down" : "chevron.up")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
            .onTapGesture { toggle(title) }
            .padding(.top, theme.tokens.sectionTop)
            .padding(.bottom, theme.tokens.sectionInner)
        }
        .accentColor(.primary)
    }
}

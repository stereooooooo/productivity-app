import SwiftUI

struct TasksView: View {
    @EnvironmentObject private var store: AppStore
    @StateObject private var theme = AppTheme.shared
    @State private var showTaskCreator = false
    @State private var openWork = true
    @State private var openPersonal = true
    @State private var openLearning = true
    @State private var query = ""

    var body: some View {
        List {
            todayRow
            projectSection(title: "Work Projects", tasks: taskGroups["Work Projects"] ?? [], isOpen: $openWork)
            projectSection(title: "Personal", tasks: taskGroups["Personal"] ?? [], isOpen: $openPersonal)
            projectSection(title: "Learning", tasks: taskGroups["Learning"] ?? [], isOpen: $openLearning)
        }
        .environment(\.defaultMinListRowHeight, 36)
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
        .listSectionSeparator(.hidden)
        .overlay(alignment: .bottomTrailing) {
            Button {
                showTaskCreator.toggle()
                if store.hapticsEnabled { Haptics.light() }
            } label: {
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .semibold))
                    )
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle().stroke(Color.black.opacity(0.08))
                    )
                    .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
                    .compositingGroup()
            }
            .buttonStyle(.plain)
            .padding(.trailing, 18)
            .padding(.bottom, 110)
            .allowsHitTesting(true)
            .zIndex(2)
            .accessibilityLabel("Add Task")
        }
        .background(AppTheme.surface)
        .safeAreaInset(edge: .top) {
            searchBar
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 90)
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

    private var hasQuery: Bool { !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    private var filteredTasks: [TaskItem] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return store.tasks }
        return store.tasks.filter { $0.title.localizedCaseInsensitiveContains(trimmed) }
    }

    private var taskGroups: [String: [TaskItem]] {
        let work = filteredTasks.filter { $0.context == "Work" }
        let personal = filteredTasks.filter { $0.context == "Personal" }
        let learning = filteredTasks.filter { $0.context == "Learning" }

        return [
            "Work Projects": work,
            "Personal": personal,
            "Learning": learning,
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

    private var searchBar: some View {
        HStack(spacing: AppTheme.Spacing.s) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search tasks", text: $query)
                .font(AppTheme.Typography.meta)
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
        .padding(.horizontal, AppTheme.Spacing.rowH)
        .frame(height: 36)
        .background(
            RoundedRectangle(cornerRadius: UI.Radius.card, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: UI.Radius.card, style: .continuous)
                .stroke(Color.black.opacity(0.06))
        )
    }

    @ViewBuilder
    private func projectSection(title: String, tasks: [TaskItem], isOpen: Binding<Bool>) -> some View {
        Section {
            DisclosureGroup(isExpanded: isOpen) {
                if tasks.isEmpty {
                    Text(hasQuery ? "No tasks match your search" : "No tasks yet")
                        .font(theme.tokens.labelFont)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, AppTheme.Spacing.rowV)
                        .listRowInsets(.init(top: AppTheme.Spacing.rowV, leading: AppTheme.Spacing.rowH, bottom: AppTheme.Spacing.rowV, trailing: AppTheme.Spacing.rowH))
                        .listRowSeparator(.hidden)
            } else {
                let items = tasks
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, task in
                        TaskRow(task: makeModel(from: task)) {
                            startFocus(task)
                        }
                        .listRowInsets(.init(top: AppTheme.Spacing.rowV, leading: AppTheme.Spacing.rowH, bottom: AppTheme.Spacing.rowV, trailing: AppTheme.Spacing.rowH))
                        .listRowSeparator(.hidden)
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

                        if index < items.count - 1 {
                            Divider()
                                .overlay(Color.black.opacity(0.06))
                                .padding(.leading, AppTheme.Spacing.rowH)
                                .padding(.trailing, 0)
                                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                                .listRowSeparator(.hidden)
                        }
                    }
                }
            } label: {
                Text(title)
                    .font(AppTheme.Typography.title)
                    .padding(.vertical, AppTheme.Spacing.sectionV)
            }
            .listRowInsets(.init(top: AppTheme.Spacing.rowV, leading: AppTheme.Spacing.rowH, bottom: AppTheme.Spacing.rowV, trailing: AppTheme.Spacing.rowH))
            .listRowSeparator(.hidden)
        }
    }

    private func makeModel(from item: TaskItem) -> TaskModel {
        TaskModel(
            id: item.id,
            title: item.title,
            context: item.context,
            kind: item.kind,
            minutes: item.minutes,
            isPriority: item.isPriority,
            completedAt: item.completedAt,
            updatedAt: item.updatedAt
        )
    }

    private func startFocusFromModel(_ model: TaskModel) {
        let snapshot = TaskItem(
            id: model.id,
            title: model.title,
            context: model.context,
            kind: model.kind,
            minutes: model.minutes,
            isPriority: model.isPriority,
            completedAt: model.completedAt,
            updatedAt: model.updatedAt
        )
        startFocus(snapshot)
    }

    private var todayRow: some View {
        Group {
            if filteredTasks.isEmpty {
                Text(hasQuery ? "No tasks match your search" : "No tasks planned for today")
                    .font(theme.tokens.labelFont)
                    .foregroundStyle(.secondary)
                    .listRowInsets(.init(top: AppTheme.Spacing.rowV, leading: AppTheme.Spacing.rowH, bottom: AppTheme.Spacing.rowV, trailing: AppTheme.Spacing.rowH))
                    .listRowSeparator(.hidden)
            } else {
                TodaySectionView(tasks: filteredTasks.map { makeModel(from: $0) }) { model in
                    startFocusFromModel(model)
                }
                .listRowInsets(.init(top: AppTheme.Spacing.rowV, leading: AppTheme.Spacing.rowH, bottom: AppTheme.Spacing.rowV, trailing: AppTheme.Spacing.rowH))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
    }
}

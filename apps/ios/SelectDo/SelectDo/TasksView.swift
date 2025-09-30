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
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.sectionV) {
                    todaySection
                    searchSection

                    projectSection(title: "Work Projects", tasks: taskGroups["Work Projects"] ?? [], isOpen: $openWork)
                    projectSection(title: "Personal", tasks: taskGroups["Personal"] ?? [], isOpen: $openPersonal)
                    projectSection(title: "Learning", tasks: taskGroups["Learning"] ?? [], isOpen: $openLearning)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)

            Button {
                showTaskCreator.toggle()
                if store.hapticsEnabled { Haptics.light() }
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .semibold))
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .background(.ultraThinMaterial, in: Circle())
            .overlay(
                Circle().strokeBorder(.white.opacity(0.35), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.15), radius: 22, y: 10)
            .padding(.trailing, 18)
            .padding(.bottom, 80)
            .accessibilityLabel("Add Task")
        }
        .background(AppTheme.surface)
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

    private var todayHeader: some View {
        HStack(spacing: 10) {
            Image(systemName: "star.fill")
                .font(.caption)
                .foregroundStyle(.white)
                .frame(width: 18, height: 18)
                .background(Circle().fill(Color.yellow))
            Text("Today")
                .font(.headline.weight(.semibold))
            Spacer(minLength: 0)
        }
        .padding(.vertical, 2)
        .padding(.top, 4)
        .overlay(Divider().offset(y: 16), alignment: .bottom)
    }

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 6) {
            todayHeader

            if filteredTasks.isEmpty {
                Text(hasQuery ? "No tasks match your search" : "No tasks planned for today")
                    .font(theme.tokens.labelFont)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, theme.tokens.rowVPad)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(filteredTasks, id: \.id) { task in
                        TaskRow(task: task)
                        if task.id != filteredTasks.last?.id {
                            Divider().opacity(0.35)
                        }
                    }
                }
            }
        }
        .padding(.bottom, Spacing.sectionV)
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

}

private struct TaskRow: View {
    @EnvironmentObject private var store: AppStore
    var task: TaskItem

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body.weight(.semibold))
                FlowLayout(spacing: 6, rowSpacing: 4) {
                    TagPill(text: task.kind)
                    TagPill(text: task.context)
                    TagPill(text: "\(task.minutes) min")
                    if task.isPriority { TagPill(text: "⭐️ Priority") }
                }
            }
            Spacer(minLength: 0)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            store.startFocus(task)
            if store.hapticsEnabled { Haptics.light() }
        }
        .padding(.vertical, Spacing.rowV)
    }
}

private extension TasksView {
    @ViewBuilder
    func projectSection(title: String, tasks: [TaskItem], isOpen: Binding<Bool>) -> some View {
        ProjectHeader(title: title, isOpen: isOpen)

        if isOpen.wrappedValue {
            if tasks.isEmpty {
                Text(hasQuery ? "No tasks match your search" : "No tasks yet")
                    .font(theme.tokens.labelFont)
                    .foregroundStyle(.secondary)
                    .padding(.leading, theme.tokens.rowHPad / 2)
                    .padding(.vertical, theme.tokens.rowVPad / 2)
            } else {
                VStack(spacing: theme.tokens.sectionInner) {
                    ForEach(tasks, id: \.id) { task in
                        TaskRow(task: task)
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
        }
    }

    func ProjectHeader(title: String, isOpen: Binding<Bool>) -> some View {
        Button {
            withAnimation(.snappy) { isOpen.wrappedValue.toggle() }
        } label: {
            HStack(spacing: 10) {
                Text(title)
                    .font(.headline.weight(.semibold))
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.subheadline.weight(.semibold))
                    .rotationEffect(.degrees(isOpen.wrappedValue ? 0 : -90))
                    .foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }
}

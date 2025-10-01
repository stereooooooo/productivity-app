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
            List {
                todaySection
                projectSection(title: "Work Projects", tasks: taskGroups["Work Projects"] ?? [], isOpen: $openWork)
                projectSection(title: "Personal", tasks: taskGroups["Personal"] ?? [], isOpen: $openPersonal)
                projectSection(title: "Learning", tasks: taskGroups["Learning"] ?? [], isOpen: $openLearning)
            }
            .environment(\.defaultMinListRowHeight, 36)
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
            .listSectionSeparator(.hidden)

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

    private var todayHeaderView: some View {
        HStack(spacing: 10) {
            Image(systemName: "star.fill")
                .font(.caption)
                .foregroundStyle(.white)
                .frame(width: 18, height: 18)
                .background(Circle().fill(Color.yellow))
            Text("Today")
                .font(UI.Fonts.title)
            Spacer(minLength: 0)
        }
        .padding(.vertical, 2)
        .padding(.top, 4)
        .overlay(Divider().offset(y: 16), alignment: .bottom)
    }

    private var todaySection: some View {
        Section(header: todayHeaderView) {
            if filteredTasks.isEmpty {
                Text(hasQuery ? "No tasks match your search" : "No tasks planned for today")
                    .font(theme.tokens.labelFont)
                    .foregroundStyle(.secondary)
                    .listRowInsets(.init(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowSeparator(.hidden)
            } else {
                let items = filteredTasks
                ForEach(Array(items.enumerated()), id: \.element.id) { index, task in
                    TaskRow(task: makeModel(from: task)) {
                        startFocus(task)
                    }
                    .listRowInsets(.init(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowSeparator(.hidden)

                    if index < items.count - 1 {
                        Divider()
                            .padding(.leading, 16)
                            .padding(.trailing, 0)
                            .opacity(0.28)
                            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .listRowSeparator(.hidden)
                    }
                }
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: UI.Spacing.s) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search tasks", text: $query)
                .textFieldStyle(.roundedBorder)
                .font(UI.Fonts.meta)
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
        .padding(.horizontal)
        .padding(.vertical, UI.Spacing.xs)
        .background(.ultraThinMaterial)
    }

    @ViewBuilder
    private func projectSection(title: String, tasks: [TaskItem], isOpen: Binding<Bool>) -> some View {
        Section {
            DisclosureGroup(isExpanded: isOpen) {
                if tasks.isEmpty {
                    Text(hasQuery ? "No tasks match your search" : "No tasks yet")
                        .font(theme.tokens.labelFont)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, UI.Spacing.s)
                        .listRowInsets(.init(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowSeparator(.hidden)
                } else {
                    let items = tasks
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, task in
                        TaskRow(task: makeModel(from: task)) {
                            startFocus(task)
                        }
                        .listRowInsets(.init(top: 6, leading: 16, bottom: 6, trailing: 16))
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
                                .padding(.leading, 16)
                                .padding(.trailing, 0)
                                .opacity(0.28)
                                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                                .listRowSeparator(.hidden)
                        }
                    }
                }
            } label: {
                HStack(spacing: UI.Spacing.s) {
                    Text(title)
                        .font(UI.Fonts.title)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.subheadline.weight(.semibold))
                        .rotationEffect(.degrees(isOpen.wrappedValue ? 0 : -90))
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, UI.Spacing.s)
            }
            .listRowInsets(.init(top: 6, leading: 16, bottom: 6, trailing: 16))
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
}

import SwiftUI

struct FindTaskView: View {
    @EnvironmentObject private var store: AppStore

    // Only the two modes you want
    private let contexts = ["Work","Personal"]
    private let times = [5,10,15,20,25,30,45,60]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.blockSpacing) {

                // 1) Mode
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeaderView(title: "What Mode Are You In?")
                    FlowLayout(spacing: 8, rowSpacing: 8) {
                        ForEach(contexts, id: \.self) { ctx in
                            Button {
                                store.activeContext = ctx
                                Haptics.light()
                            } label: {
                                Chip(text: ctx, selected: store.activeContext == ctx)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // 2) Time
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeaderView(title: "How Much Time Do You Have?")
                    FlowLayout(spacing: 12, rowSpacing: 10) {
                        ForEach(times, id: \.self) { m in
                            Button {
                                store.selectedMinutes = m
                                Haptics.light()
                            } label: {
                                Chip(text: "\(m) min", selected: store.selectedMinutes == m)
                            }
                        }
                        // Custom lives in the same flow to avoid overlap
                        Button {
                            store.selectedMinutes = nil
                        } label: {
                            Text("Custom")
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .overlay(Capsule().stroke(Color.secondary.opacity(0.35)))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Small filter bar under time
                    HStack(spacing: 12) {
                        Toggle(
                            "Priority Only",
                            isOn: Binding(get: { store.priorityOnly },
                                          set: { store.priorityOnly = $0 })
                        )
                        .toggleStyle(.switch)

                        Spacer()

                        Button("Reset") {
                            store.activeContext = "Personal"
                            store.selectedMinutes = 15
                            store.priorityOnly = false
                        }

                        Button {
                            store.reshuffleID = UUID()
                        } label: {
                            Label("Reshuffle", systemImage: "shuffle")
                        }
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }

                // 3) Tasks
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeaderView(title: "Pick a Task")

                    if filteredTasks.isEmpty {
                        Text("No tasks match. Try a different time or context.")
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 4)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredTasks) { task in
                                TaskCard(task: task) { store.startFocus(task) }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) { store.delete(task) } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        Button { store.togglePriority(task) } label: {
                                            Label("Priority", systemImage: "star.fill")
                                        }
                                        .tint(.orange)
                                    }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        // Focus timer sheet
        .sheet(
            item: Binding(get: { store.activeSession }, set: { store.activeSession = $0 })
        ) { session in
            FocusSheet(session: session) { store.finishFocus() }
                .presentationDetents([.height(320), .medium, .large])
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Filtering (in-memory for now)
    private var filteredTasks: [TaskItem] {
        var list = store.tasks.filter { t in
            (store.selectedMinutes == nil || t.minutes <= (store.selectedMinutes ?? t.minutes)) &&
            t.context == store.activeContext &&
            (!store.priorityOnly || t.isPriority)
        }
        _ = store.reshuffleID
        list.shuffle()
        return list
    }
}

// MARK: - Card

private struct TaskCard: View {
    var task: TaskItem
    var onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(task.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                if task.isPriority {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.orange)
                        .imageScale(.small)
                }
                Spacer(minLength: 8)
            }

            HStack(spacing: 8) {
                TagPill(text: task.kind)
                TagPill(text: task.context)
                TagPill(text: "\(task.minutes) min")
            }

            Button(action: onStart) {
                Label("Start", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardRadius)
                .stroke(.quaternary, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
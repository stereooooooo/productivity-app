import SwiftUI

struct FindTaskView: View {
    @EnvironmentObject private var store: AppStore

    private let contexts = ["Work", "Personal"]
    private let times = [5, 10, 15, 20, 25, 30, 45, 60]
    @State private var showAdvanced = false

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
                        Button {
                            store.selectedMinutes = nil
                        } label: {
                            Chip(text: "Custom", selected: store.selectedMinutes == nil)
                        }
                    }

                    // Filter row
                    HStack(spacing: 16) {
                        Toggle("Priority Only", isOn: $store.priorityOnly)
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

                // 3) Advanced filters (UI shell for parity)
                DisclosureGroup(isExpanded: $showAdvanced) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Energy Level")
                            .font(.subheadline.weight(.semibold))
                        FlowLayout(spacing: 8, rowSpacing: 8) {
                            TagPill(text: "Low")
                            TagPill(text: "Medium")
                            TagPill(text: "High")
                        }

                        Text("Projects")
                            .font(.subheadline.weight(.semibold))
                        FlowLayout(spacing: 8, rowSpacing: 8) {
                            TagPill(text: "Work Projects")
                            TagPill(text: "Personal")
                            TagPill(text: "Learning")
                        }

                        Text("Tags")
                            .font(.subheadline.weight(.semibold))
                        FlowLayout(spacing: 8, rowSpacing: 8) {
                            TagPill(text: "#research")
                            TagPill(text: "#writing")
                            TagPill(text: "#review")
                        }
                    }
                    .padding(14)
                    .background(AppTheme.surfaceCard)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cardRadius)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
                } label: {
                    Text("Advanced filters")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // 4) Tasks
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
        .sheet(item: Binding(get: { store.activeSession }, set: { store.activeSession = $0 })) { session in
            FocusSheet(session: session) { store.finishFocus() }
                .presentationDetents([.height(320), .medium, .large])
        }
        .background(AppTheme.surface)
    }

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

// Card view matches web styling
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
                    Image(systemName: "star.fill").foregroundStyle(.orange).imageScale(.small)
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
                    .imageScale(.small)
                    .opacity(0.6)
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
        .background(AppTheme.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: AppTheme.cardRadius).stroke(AppTheme.border, lineWidth: 1))
        .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
    }
}

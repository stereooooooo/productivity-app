import SwiftUI

struct FindTaskView: View {
    @EnvironmentObject private var store: AppStore
    private let contexts = ["Work","Personal","Home","Capital ENT"]
    private let times = [5,10,15,20,25,30,45,60]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                SectionHeader("What Mode Are You In?")
                FlowChips(selection: $store.activeContext, options: contexts)

                SectionHeader("How Much Time Do You Have?")
                TimeChips(selected: $store.selectedMinutes, options: times)

                SectionHeader("Pick a Task")
                LazyVStack(spacing: 12) {
                    ForEach(filteredTasks) { task in
                        TaskCard(task: task) { store.complete(task) }
                    }
                }

            }
            .padding(.horizontal)
            .padding(.vertical, 16)
        }
    }

    private var filteredTasks: [TaskItem] {
        store.tasks.filter { t in
            (store.selectedMinutes == nil || t.minutes <= store.selectedMinutes!) &&
            (t.context == store.activeContext)
        }
    }
}

struct SectionHeader: View {
    var title: String
    init(_ title: String) { self.title = title }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.title3.bold())
            Divider().opacity(0.4)
        }
    }
}

struct FlowChips: View {
    @Binding var selection: String
    var options: [String]
    var body: some View {
        WrapHStack(spacing: 8, rowSpacing: 8) {
            ForEach(options, id:\.self) { opt in
                let selected = selection == opt
                Button {
                    selection = opt; Haptics.light()
                } label: {
                    Text(opt).font(.subheadline)
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(selected ? Color.accentColor.opacity(0.12) : Color(.secondarySystemBackground))
                        .foregroundStyle(selected ? Color.accentColor : .primary)
                        .clipShape(Capsule())
                }
            }
        }
    }
}

struct TimeChips: View {
    @Binding var selected: Int?
    var options: [Int]
    var body: some View {
        WrapHStack(spacing: 8, rowSpacing: 8) {
            ForEach(options, id:\.self) { m in
                let isSel = selected == m
                Button {
                    selected = m; Haptics.light()
                } label: {
                    Text("\(m) min").font(.subheadline)
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(isSel ? Color.accentColor : Color(.secondarySystemBackground))
                        .foregroundStyle(isSel ? .white : .primary)
                        .clipShape(Capsule())
                }
            }
            Button { selected = nil } label: {
                Text("Custom").font(.subheadline)
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .overlay(Capsule().stroke(Color.secondary.opacity(0.4)))
            }
        }
    }
}

struct TaskCard: View {
    var task: TaskItem
    var onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(task.title).font(.headline)
            HStack(spacing: 8) {
                Tag(task.kind)
                Tag(task.context)
                Tag("\(task.minutes) min")
                if task.isPriority { Tag("Priority", color: .orange) }
            }
            Button(action: onStart) {
                Label("Start", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(12)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(.quaternary))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}

struct Tag: View {
    var text: String
    var color: Color = .blue.opacity(0.15)
    init(_ text: String, color: Color = .blue.opacity(0.15)) {
        self.text = text; self.color = color
    }
    var body: some View {
        Text(text).font(.caption).padding(.horizontal, 8).padding(.vertical, 4)
            .background(color).clipShape(Capsule())
    }
}
import SwiftData
import SwiftUI

struct AddTaskView: View {
    @Environment(\.modelContext) private var ctx
    @EnvironmentObject private var store: AppStore

    @State private var title = ""
    @State private var context = "Personal"
    @State private var kind = "Atomic"
    @State private var minutes = 15
    @State private var priority = false

    private let contexts = ["Work", "Personal"]
    private let kinds = ["Atomic", "Standard", "Progress"]
    private let minuteOptions = [5, 10, 15, 20, 25, 30, 45, 60]

    var body: some View {
        Form {
            Section("Details") {
                TextField("Task title", text: $title)

                Picker("Context", selection: $context) {
                    ForEach(contexts, id: \.self) { item in
                        Text(item)
                    }
                }

                Picker("Type", selection: $kind) {
                    ForEach(kinds, id: \.self) { item in
                        Text(item)
                    }
                }

                Picker("Est. minutes", selection: $minutes) {
                    ForEach(minuteOptions, id: \.self) { m in
                        Text("\(m) min")
                    }
                }

                Toggle("Priority", isOn: $priority)
            }

            Section {
                Button(action: add) {
                    Label("Add Task", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal)
                .padding(.vertical, 6)
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .formStyle(.grouped)
    }

    private func add() {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let model = TaskModel(
            title: title,
            context: context,
            kind: kind,
            minutes: minutes,
            isPriority: priority,
            completedAt: nil,
            updatedAt: .now
        )
        ctx.insert(model)
        try? ctx.save()
        if store.hapticsEnabled { Haptics.success() }
        // reset
        title = ""
        context = "Personal"
        kind = "Atomic"
        minutes = 15
        priority = false
    }
}

import SwiftData
import SwiftUI

struct TaskEditorSheet: View {
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss

    // SwiftData bindable model (no Binding wrapper needed)
    @Bindable var model: TaskModel

    private let contexts = ["Work", "Personal"]
    private let kinds = ["Atomic", "Standard", "Progress"]
    private let minuteOptions = [5, 10, 15, 20, 25, 30, 45, 60]

    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    TextField("Title", text: $model.title)
                }

                Section("Settings") {
                    Picker("Context", selection: $model.context) {
                        ForEach(contexts, id: \.self) { item in
                            Text(item)
                        }
                    }

                    Picker("Type", selection: $model.kind) {
                        ForEach(kinds, id: \.self) { item in
                            Text(item)
                        }
                    }

                    Picker("Est. minutes", selection: $model.minutes) {
                        ForEach(minuteOptions, id: \.self) { m in
                            Text("\(m) min")
                        }
                    }

                    Toggle("Priority", isOn: $model.isPriority)
                }

                if model.completedAt != nil {
                    Section {
                        Button(role: .destructive) {
                            model.completedAt = nil
                        } label: {
                            Label("Mark as not completed", systemImage: "arrow.uturn.backward")
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        model.updatedAt = .now
                        try? ctx.save()
                        dismiss()
                    }
                }
            }
        }
    }
}

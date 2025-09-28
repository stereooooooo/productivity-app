import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject private var store: AppStore
    @State private var title = ""
    @State private var context = "Personal"
    @State private var kind = "Atomic"
    @State private var minutes = 15
    @State private var priority = false

    private let contexts = ["Work","Personal"]
    private let kinds = ["Atomic","Standard","Progress"]
    private let minuteOptions = [5,10,15,20,25,30,45,60]

    var body: some View {
        Form {
            Section("Details") {
                TextField("Task title", text: $title)
                Picker("Context", selection: $context) {
                    ForEach(contexts, id:\.self, content: Text.init)
                }
                Picker("Type", selection: $kind) {
                    ForEach(kinds, id:\.self, content: Text.init)
                }
                Picker("Est. minutes", selection: $minutes) {
                    ForEach(minuteOptions, id:\.self) { Text("\($0) min") }
                }
                Toggle("Priority", isOn: $priority)
            }

            // Big primary button section styled like the web app
            Section {
                Button(action: add) {
                    Text("Add Task")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            .listRowInsets(EdgeInsets())        // remove default Form padding for this row
            .listRowBackground(Color.clear)     // so background is consistent
        }
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .formStyle(.grouped)
    }

    private func add() {
        store.addTask(
            title: title,
            context: context,
            kind: kind,
            minutes: minutes,
            priority: priority
        )
        title = ""
    }
}
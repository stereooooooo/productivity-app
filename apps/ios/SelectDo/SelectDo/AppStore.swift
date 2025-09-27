import SwiftUI

enum Mode: String, CaseIterable { case add = "Add", find = "Find", review = "Review" }

struct TaskItem: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var context: String   // Work, Personal, Home, etc.
    var kind: String      // Atomic / Standard / Progress
    var minutes: Int
    var isPriority: Bool = false
    var completedAt: Date? = nil
    var updatedAt: Date = Date()
}

final class AppStore: ObservableObject {
    // UI
    @Published var mode: Mode = .find
    @Published var selectedMinutes: Int? = 15
    @Published var activeContext: String = "Personal"

    // Data
    @Published var tasks: [TaskItem] = [
        .init(title: "List Epix watch for sale", context: "Personal", kind: "Atomic", minutes: 15, isPriority: true),
        .init(title: "Clean up cardboard boxes", context: "Home", kind: "Standard", minutes: 20),
        .init(title: "Work on Select + Do app", context: "Work", kind: "Progress", minutes: 45)
    ]

    func addTask(title: String, context: String, kind: String, minutes: Int, priority: Bool) {
        tasks.append(.init(title: title, context: context, kind: kind, minutes: minutes, isPriority: priority))
        Haptics.light()
    }

    func complete(_ task: TaskItem) {
        if let idx = tasks.firstIndex(of: task) {
            tasks[idx].completedAt = Date()
            tasks[idx].updatedAt = Date()
            Haptics.success()
        }
    }

    var completedToday: [TaskItem] {
        let cal = Calendar.current
        return tasks.filter { $0.completedAt.map { cal.isDateInToday($0) } ?? false }
    }
}
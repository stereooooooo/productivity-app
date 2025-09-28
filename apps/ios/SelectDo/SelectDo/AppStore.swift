import Foundation
import Combine
import SwiftUI

enum Mode: String, CaseIterable { case add = "Add", find = "Find", review = "Review" }

struct TaskItem: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var context: String
    var kind: String
    var minutes: Int
    var isPriority: Bool = false
    var completedAt: Date? = nil
    var updatedAt: Date = Date()
}

struct FocusSession: Identifiable, Equatable {
    let id = UUID()
    let task: TaskItem
    var remaining: Int   // seconds
}

final class AppStore: ObservableObject {
    // UI
    @Published var mode: Mode = .find
    @Published var selectedMinutes: Int? = 15
    @Published var activeContext: String = "Personal"
    @Published var priorityOnly: Bool = false
    @Published var reshuffleID = UUID()

    // Data
    @Published var tasks: [TaskItem] = [
        .init(title: "List Epix watch for sale", context: "Personal", kind: "Atomic", minutes: 15, isPriority: true),
        .init(title: "Clean up cardboard boxes", context: "Home", kind: "Standard", minutes: 20),
        .init(title: "Work on Select + Do app", context: "Work", kind: "Progress", minutes: 45)
    ]

    // Focus
    @Published var activeSession: FocusSession?

    // ✅ Call your normalizer once on creation so only Work/Personal remain
    init() {
        normalizeContexts()
    }

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

    func togglePriority(_ t: TaskItem) {
        if let idx = tasks.firstIndex(of: t) {
            tasks[idx].isPriority.toggle()
            tasks[idx].updatedAt = .now
        }
    }

    func delete(_ t: TaskItem) {
        tasks.removeAll { $0.id == t.id }
    }

    func normalizeContexts() {
        for i in tasks.indices {
            if tasks[i].context != "Work" && tasks[i].context != "Personal" {
                tasks[i].context = "Personal"
            }
        }
    }

    var completedToday: [TaskItem] {
        let cal = Calendar.current
        return tasks.filter { $0.completedAt.map { cal.isDateInToday($0) } ?? false }
    }
}

// Focus session helpers
extension AppStore {
    func startFocus(_ task: TaskItem) {
        activeSession = FocusSession(task: task, remaining: task.minutes * 60)
    }

    func tickFocus() {
        guard var s = activeSession else { return }
        if s.remaining > 0 {
            s.remaining -= 1
            activeSession = s
        } else {
            finishFocus()
        }
    }

    func finishFocus() {
        if let t = activeSession?.task { complete(t) }
        activeSession = nil
    }
}
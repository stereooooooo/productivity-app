import Combine
import Foundation
import SwiftData
import SwiftUI

// MARK: - App Mode

enum Mode: String, CaseIterable { case add = "Add", find = "Find", review = "Review" }

// MARK: - Core Types

struct TaskItem: Identifiable, Hashable {
    let id: UUID
    var title: String
    var context: String // "Work" | "Personal"
    var kind: String // "Atomic" | "Standard" | "Progress"
    var minutes: Int
    var isPriority: Bool = false
    var completedAt: Date?
    var updatedAt: Date = .init()
    var energy: String?
    var project: String?
    var tags: [String]

    init(
        id: UUID = UUID(),
        title: String,
        context: String,
        kind: String,
        minutes: Int,
        isPriority: Bool = false,
        completedAt: Date? = nil,
        updatedAt: Date = Date(),
        energy: String? = nil,
        project: String? = nil,
        tags: [String] = []
    ) {
        self.id = id
        self.title = title
        self.context = context
        self.kind = kind
        self.minutes = minutes
        self.isPriority = isPriority
        self.completedAt = completedAt
        self.updatedAt = updatedAt
        self.energy = energy
        self.project = project
        self.tags = tags
    }
}

struct FocusSession: Identifiable, Equatable {
    let id = UUID()
    let task: TaskItem // snapshot for UI
    var remaining: Int // seconds
}

// MARK: - Store

final class AppStore: ObservableObject {
    // UI
    @Published var mode: Mode = .find
    @Published var selectedMinutes: Int? = 15
    @Published var activeContext: String = "Personal"
    @Published var priorityOnly: Bool = false
    @Published var reshuffleID = UUID()
    @Published var energy: Set<String> = []
    @Published var projects: Set<String> = []
    @Published var tags: Set<String> = []

    // Settings
    @Published var hapticsEnabled: Bool = true
    enum ThemeChoice: String, CaseIterable, Identifiable { case system, light, dark
        var id: String { rawValue }
    }

    @Published var themeChoice: ThemeChoice = .system
    var preferredColorScheme: ColorScheme? {
        switch themeChoice {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    // Legacy in-memory seed (still used by some views)
    @Published var tasks: [TaskItem] = [
        .init(title: "List Epix watch for sale", context: "Personal", kind: "Atomic", minutes: 15, isPriority: true),
        .init(title: "Clean up cardboard boxes", context: "Home", kind: "Standard", minutes: 20),
        .init(title: "Work on Select + Do app", context: "Work", kind: "Progress", minutes: 45),
    ]

    // Focus
    @Published var activeSession: FocusSession?
    @Published var activeModel: TaskModel? // <-- SwiftData task being focused

    init() {
        normalizeContexts()
    }

    // MARK: - CRUD (in-memory path; SwiftData handled in views)

    func addTask(title: String, context: String, kind: String, minutes: Int, priority: Bool) {
        tasks.append(.init(title: title, context: context, kind: kind, minutes: minutes, isPriority: priority))
        if hapticsEnabled { Haptics.light() }
    }

    func complete(_ task: TaskItem) {
        if let idx = tasks.firstIndex(of: task) {
            tasks[idx].completedAt = Date()
            tasks[idx].updatedAt = Date()
            if hapticsEnabled { Haptics.success() }
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
            if tasks[i].context != "Work", tasks[i].context != "Personal" {
                tasks[i].context = "Personal"
            }
        }
    }

    var completedToday: [TaskItem] {
        let cal = Calendar.current
        return tasks.filter { $0.completedAt.map { cal.isDateInToday($0) } ?? false }
    }
}

// MARK: - Focus session helpers

extension AppStore {
    /// Start a focus session from a SwiftData TaskModel (preferred path).
    func startFocus(_ model: TaskModel) {
        activeModel = model
        let snapshot = TaskItem(
            id: model.id,
            title: model.title,
            context: model.context,
            kind: model.kind,
            minutes: model.minutes,
            isPriority: model.isPriority,
            completedAt: model.completedAt,
            updatedAt: model.updatedAt,
            energy: model.energy,
            project: model.project,
            tags: model.tags
        )
        activeSession = FocusSession(task: snapshot, remaining: model.minutes * 60)
    }

    /// Legacy path (if any code still passes a TaskItem).
    func startFocus(_ item: TaskItem) {
        activeModel = nil
        activeSession = FocusSession(task: item, remaining: item.minutes * 60)
    }

    func tickFocus() {
        guard var s = activeSession else { return }
        if s.remaining > 0 {
            s.remaining -= 1
            activeSession = s
        } else {
            // Timer finished. We don't auto-complete the SwiftData model here
            // because AppStore doesn't have a model context; the sheet handles save.
            finishFocus()
        }
    }

    /// End the session (sheet will persist completion for SwiftData path).
    func finishFocus() {
        // If this was an in-memory task session, mark as complete.
        if activeModel == nil, let task = activeSession?.task {
            complete(task)
        }
        activeSession = nil
        activeModel = nil
    }
}

import Foundation
import SwiftData

@Model
final class TaskModel {
    @Attribute(.unique) var id: UUID
    var title: String
    var context: String // "Work" | "Personal"
    var kind: String // "Atomic" | "Standard" | "Progress"
    var minutes: Int
    var isPriority: Bool
    var completedAt: Date?
    var updatedAt: Date
    var energy: String?
    var project: String?
    var tagsData: Data
    @Transient var tags: [String] {
        get {
            (try? JSONDecoder().decode([String].self, from: tagsData)) ?? []
        }
        set {
            let cleaned = newValue.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
            tagsData = (try? JSONEncoder().encode(cleaned)) ?? Data()
        }
    }

    init(id: UUID = UUID(),
         title: String,
         context: String,
         kind: String,
         minutes: Int,
         isPriority: Bool = false,
         completedAt: Date? = nil,
         updatedAt: Date = .now,
         energy: String? = nil,
         project: String? = nil,
         tags: [String] = [])
    {
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
        self.tagsData = Data()
        self.tags = tags
    }
}

extension TaskModel {
    static let demo: [TaskModel] = [
        TaskModel(title: "List Epix watch for sale", context: "Personal", kind: "Atomic", minutes: 15, isPriority: true),
        TaskModel(title: "Clean up cardboard boxes", context: "Personal", kind: "Standard", minutes: 20),
        TaskModel(title: "Work on Select + Do app", context: "Work", kind: "Progress", minutes: 45),
    ]
}

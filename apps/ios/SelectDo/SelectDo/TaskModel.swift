import Foundation
import SwiftData

@Model
final class TaskModel {
    @Attribute(.unique) var id: UUID
    var title: String
    var context: String
    var kind: String
    var minutes: Int
    var isPriority: Bool
    var completedAt: Date?
    var updatedAt: Date
    var isDeleted: Bool

    init(
        id: UUID = UUID(),
        title: String,
        context: String,
        kind: String,
        minutes: Int,
        isPriority: Bool = false,
        completedAt: Date? = nil,
        updatedAt: Date = .now,
        isDeleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.context = context
        self.kind = kind
        self.minutes = minutes
        self.isPriority = isPriority
        self.completedAt = completedAt
        self.updatedAt = updatedAt
        self.isDeleted = isDeleted
    }
}
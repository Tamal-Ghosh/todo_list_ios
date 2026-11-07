import Foundation
import FirebaseFirestore

struct TaskItem: Identifiable {
    let id: String
    var title: String
    var taskDescription: String
    var completed: Bool
    var createdAt: Date

    init(id: String = UUID().uuidString, title: String, taskDescription: String, completed: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.taskDescription = taskDescription
        self.completed = completed
        self.createdAt = createdAt
    }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let title = data["title"] as? String else { return nil }
        self.id = document.documentID
        self.title = title
        self.taskDescription = data["description"] as? String ?? ""
        self.completed = data["completed"] as? Bool ?? false
        self.createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? .distantPast
    }
}

import Foundation
import FirebaseFirestore

@MainActor
final class TaskStore: ObservableObject {
    @Published private(set) var tasks: [TaskItem] = []
    @Published var errorMessage: String?
    private var listener: ListenerRegistration?
    private let db = Firestore.firestore()
    private let uid: String

    init(uid: String) {
        self.uid = uid
        listener = db.collection("users").document(uid).collection("tasks")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                Task { @MainActor in
                    if let error { self?.errorMessage = error.localizedDescription; return }
                    self?.tasks = snapshot?.documents.compactMap(TaskItem.init(document:)) ?? []
                }
            }
    }
    private var collection: CollectionReference {
        db.collection("users").document(uid).collection("tasks")
    }
    func save(id: String?, title: String, description: String) async -> Bool {
        errorMessage = nil
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty else { errorMessage = "Title is required"; return false }
        do {
            if let id {
                try await collection.document(id).updateData(["title": cleanTitle, "description": description])
            } else {
                try await collection.document().setData([
                    "title": cleanTitle,
                    "description": description,
                    "completed": false,
                    "createdAt": FieldValue.serverTimestamp()
                ])
            }
            return true
        } catch { errorMessage = error.localizedDescription; return false }
    }
    func toggle(_ task: TaskItem) async {
        do { try await collection.document(task.id).updateData(["completed": !task.completed]) }
        catch { errorMessage = error.localizedDescription }
    }
    func delete(_ task: TaskItem) async {
        do { try await collection.document(task.id).delete() }
        catch { errorMessage = error.localizedDescription }
    }
    deinit { listener?.remove() }
}

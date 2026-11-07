import SwiftUI

struct TaskEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: TaskStore
    let task: TaskItem?
    @State private var title: String
    @State private var description: String
    @State private var saving = false

    init(store: TaskStore, task: TaskItem?) {
        self.store = store
        self.task = task
        _title = State(initialValue: task?.title ?? "")
        _description = State(initialValue: task?.taskDescription ?? "")
    }
    var body: some View {
        NavigationStack {
            Form {
                TextField("Task title", text: $title)
                TextField("Description", text: $description, axis: .vertical)
                    .lineLimit(3...6)
            }
            .navigationTitle(task == nil ? "New Task" : "Edit Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saving = true
                        Task {
                            let success = await store.save(id: task?.id, title: title, description: description)
                            saving = false
                            if success { dismiss() }
                        }
                    }
                    .disabled(saving || title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

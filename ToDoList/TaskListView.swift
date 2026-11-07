import SwiftUI

struct TaskListView: View {
    @EnvironmentObject private var auth: AuthStore
    @StateObject private var store: TaskStore
    @State private var editing: TaskItem?
    @State private var showAdd = false

    init() {
        // The signed-in user is available when this view is created.
        let uid = FirebaseAuthBridge.currentUID
        _store = StateObject(wrappedValue: TaskStore(uid: uid))
    }

    var body: some View {
        NavigationStack {
            List {
                if store.tasks.isEmpty {
                    ContentUnavailableView("No tasks yet", systemImage: "checklist", description: Text("Tap + to add your first task"))
                }
                ForEach(store.tasks) { task in
                    HStack {
                        Button { Task { await store.toggle(task) } } label: {
                            Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                                .font(.title3)
                        }
                        .buttonStyle(.borderless)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(task.title).font(.headline)
                                .strikethrough(task.completed)
                            if !task.taskDescription.isEmpty {
                                Text(task.taskDescription).font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        Button { editing = task } label: { Image(systemName: "pencil") }
                            .buttonStyle(.borderless)
                    }
                    .swipeActions {
                        Button("Delete", role: .destructive) { Task { await store.delete(task) } }
                    }
                }
            }
            .navigationTitle("My Tasks")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Logout") { auth.signOut() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showAdd) { TaskEditorView(store: store, task: nil) }
            .sheet(item: $editing) { task in TaskEditorView(store: store, task: task) }
            .alert("Error", isPresented: Binding(get: { store.errorMessage != nil }, set: { if !$0 { store.errorMessage = nil } })) {
                Button("OK") { store.errorMessage = nil }
            } message: { Text(store.errorMessage ?? "") }
        }
    }
}

import FirebaseAuth
private enum FirebaseAuthBridge {
    static var currentUID: String { Auth.auth().currentUser?.uid ?? "" }
}

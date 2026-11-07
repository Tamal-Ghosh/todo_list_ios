import SwiftUI
import FirebaseCore

@main
struct TaskManagerApp: App {
    @StateObject private var auth: AuthStore

    init() {
        FirebaseApp.configure()
        _auth = StateObject(wrappedValue: AuthStore())
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if let user = auth.user {
                    TaskListView().id(user.uid)
                } else {
                    AuthView()
                }
            }
            .environmentObject(auth)
        }
    }
}

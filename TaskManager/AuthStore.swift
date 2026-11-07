import Foundation
import FirebaseAuth

@MainActor
final class AuthStore: ObservableObject {
    @Published private(set) var user: User?
    @Published var errorMessage: String?
    private var listener: AuthStateDidChangeListenerHandle?

    init() {
        user = Auth.auth().currentUser
        listener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in self?.user = user }
        }
    }
    func signIn(email: String, password: String) async {
        errorMessage = nil
        do { _ = try await Auth.auth().signIn(withEmail: email, password: password) }
        catch { errorMessage = error.localizedDescription }
    }
    func register(email: String, password: String) async {
        errorMessage = nil
        do { _ = try await Auth.auth().createUser(withEmail: email, password: password) }
        catch { errorMessage = error.localizedDescription }
    }
    func signOut() {
        do { try Auth.auth().signOut() }
        catch { errorMessage = error.localizedDescription }
    }
    deinit { if let listener { Auth.auth().removeStateDidChangeListener(listener) } }
}

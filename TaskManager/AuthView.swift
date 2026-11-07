import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var auth: AuthStore
    @State private var email = ""
    @State private var password = ""
    @State private var isRegister = false
    @State private var busy = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    SecureField("Password (at least 6 characters)", text: $password)
                }
                if let error = auth.errorMessage {
                    Text(error).foregroundStyle(.red)
                }
                Button(isRegister ? "Create Account" : "Sign In") {
                    busy = true
                    Task {
                        if isRegister { await auth.register(email: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password) }
                        else { await auth.signIn(email: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password) }
                        busy = false
                    }
                }
                .disabled(busy || email.isEmpty || password.count < 6)
                Button(isRegister ? "Already registered? Sign In" : "New here? Register") {
                    isRegister.toggle()
                    auth.errorMessage = nil
                }
            }
            .navigationTitle(isRegister ? "Register" : "Todo Login")
        }
    }
}

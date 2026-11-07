# ToDo List — SwiftUI Firebase iOS App

Native iOS 17+ SwiftUI app with email/password authentication, per-user Firestore tasks, and add/list/edit/delete/complete actions. Uses MVVM-inspired observable stores.

## Requirements
- Windows + VS Code + Git for source editing
- Free Firebase Spark project
- GitHub public repository with GitHub Actions enabled for cloud iOS Simulator builds
- No paid Apple Developer account needed for unsigned Simulator build

## Firebase setup
1. Open https://console.firebase.google.com/ and create a Firebase project on Spark.
2. Authentication > Sign-in method > enable **Email/Password**.
3. Firestore Database > Create database. Choose a location and create database; deploy the rules in `firestore.rules` in Firestore > Rules before using the app.
4. Project settings > Your apps > add **Apple** app, bundle ID **com.todolist.app** (must match `project.yml`). Download `GoogleService-Info.plist`.
5. Keep the plist in `FirebaseConfig/GoogleService-Info.plist` locally, **do not commit it**. Add the plist contents as a GitHub Actions secret, as explained below.

## GitHub Actions secret (Windows PowerShell)
Run in the project directory, after saving your downloaded plist in `FirebaseConfig`:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes((Resolve-Path 'FirebaseConfig/GoogleService-Info.plist')))
```

Copy output to GitHub repository > Settings > Secrets and variables > Actions > New repository secret. Name: `FIREBASE_PLIST_BASE64`. Paste the base64 output as the value.

Push project to a **public GitHub repository**. Workflow `.github/workflows/ios-build.yml` generates `TaskManager.xcodeproj` on a macOS runner, downloads Firebase Swift packages, and builds for generic iOS Simulator without signing.

## Local Xcode (if available later)
Install XcodeGen (`brew install xcodegen`), put plist in FirebaseConfig, run `xcodegen generate`, then open `TaskManager.xcodeproj`. For deployment to a physical iPhone, configure signing separately.

## Firestore structure
`users/{uid}/tasks/{taskId}` with fields `title`, `description`, `completed`, `createdAt`.

## Notes
- Firebase Spark has free usage quotas; don't enable paid billing.
- Cloud build is **not** a substitute for interactive iPhone testing.
- This is a starter project; build success has not been verified in this environment. Check GitHub Actions logs and fix compatibility issues if any.
- Firebase config file identifies the project and is not a server-side admin secret; nevertheless this template keeps it out of Git for tidy repository configuration. Never upload service-account keys.

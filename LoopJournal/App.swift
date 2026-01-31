
import SwiftUI
import CoreData

@main
struct LoopJournalApp: App {
    @StateObject private var authManager = AuthManager.shared
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial = false
    @AppStorage("hasSeenFirstLaunchGate") private var hasSeenFirstLaunchGate = false
    
        let persistence = CoreDataManager.shared
    var body: some Scene {
        WindowGroup {
            ZStack {
                MainContentView()
                    .environment(\.managedObjectContext, persistence.context)

                if shouldShowTutorial {
                    TutorialView {
                        hasSeenTutorial = true
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }

                if shouldShowFirstLaunchGate {
                    FirstLaunchGateView {
                        hasSeenFirstLaunchGate = true
                    }
                    .transition(.opacity)
                    .zIndex(2)
                }

                if authManager.isLockEnabled && !authManager.isAuthenticated {
                    LockScreenView(authManager: authManager)
                        .transition(.opacity)
                        .zIndex(3)
                }
            }
            .task {
                if authManager.isLockEnabled && !authManager.isAuthenticated {
                    await authManager.authenticate()
                }
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            handleScenePhaseChange(to: newPhase)
        }
    }
    
    private func handleScenePhaseChange(to newPhase: ScenePhase) {
        switch newPhase {
        case .background:
            // Reset authentication when app goes to background
            authManager.resetAuthentication()
        case .inactive:
            break
        case .active:
            // Re-authenticate when app comes to foreground (if lock is enabled)
            if authManager.isLockEnabled && !authManager.isAuthenticated {
                Task {
                    await authManager.authenticate()
                }
            }
        @unknown default:
            break
        }
    }

    private var shouldShowTutorial: Bool {
        !hasSeenTutorial && (!authManager.isLockEnabled || authManager.isAuthenticated)
    }

    private var shouldShowFirstLaunchGate: Bool {
        !hasSeenFirstLaunchGate && (!authManager.isLockEnabled || authManager.isAuthenticated)
    }
}

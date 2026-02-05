import SwiftUI
import CoreData

/// Step-by-step tutorial that guides the user to create their first journal entry.
/// Ends with "Create my first entry" which presents LogEntryView; on dismiss, marks tutorial complete.
struct TutorialView: View {
    @Environment(\.managedObjectContext) private var context

    private struct Step: Identifiable {
        let id: Int
        let title: String
        let body: String
        let icon: String
        let tint: Color
    }

    private let steps: [Step] = [
        Step(
            id: 1,
            title: "Open Log Entry",
            body: "Tap the round + button at the bottom of the screen to open the new entry screen.",
            icon: "plus.circle.fill",
            tint: .cyan
        ),
        Step(
            id: 2,
            title: "Choose your mood",
            body: "Select how you're feeling by tapping one or more mood emojis. You can pick several.",
            icon: "face.smiling.fill",
            tint: .pink
        ),
        Step(
            id: 3,
            title: "Add a note (optional)",
            body: "Type a short note about your day if you like. This step is optional.",
            icon: "text.alignleft",
            tint: .orange
        ),
        Step(
            id: 4,
            title: "Save your entry",
            body: "Tap Save. Your entry will appear on your timeline — you can swipe left and right to browse entries anytime.",
            icon: "checkmark.circle.fill",
            tint: .green
        )
    ]

    let onFinish: () -> Void
    @State private var currentIndex = 0
    @State private var showingLogEntry = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.black, Color(white: 0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Add your first entry")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 8)

                TabView(selection: $currentIndex) {
                    ForEach(steps) { step in
                        VStack(spacing: 20) {
                            Image(systemName: step.icon)
                                .font(.system(size: 56, weight: .bold))
                                .foregroundStyle(step.tint)
                                .shadow(color: step.tint.opacity(0.5), radius: 12, y: 4)

                            Text("Step \(step.id)")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))

                            Text(step.title)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)

                            Text(step.body)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.white.opacity(0.85))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 28)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .tag(step.id - 1)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                VStack(spacing: 12) {
                    Button(action: { showingLogEntry = true }) {
                        Text("Create my first entry")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [.cyan, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                    }
                    .accessibilityLabel("Create my first entry")
                    .padding(.horizontal, 24)

                    Button(action: onFinish) {
                        Text("Skip for now")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .accessibilityLabel("Skip tutorial")
                }
                .padding(.bottom, 32)
            }
        }
        .fullScreenCover(isPresented: $showingLogEntry) {
            LogEntryView()
                .environment(\.managedObjectContext, context)
                .onDisappear { onFinish() }
        }
    }
}

#Preview {
    TutorialView {}
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
}

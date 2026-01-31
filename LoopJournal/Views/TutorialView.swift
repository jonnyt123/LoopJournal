import SwiftUI

struct TutorialView: View {
    private struct Page: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let systemImage: String
        let tint: Color
    }

    private let pages: [Page] = [
        Page(
            title: "Capture Moments",
            subtitle: "Tap + to log a quick entry with mood, notes, and media.",
            systemImage: "plus.circle.fill",
            tint: .cyan
        ),
        Page(
            title: "Swipe Your Timeline",
            subtitle: "Swipe left or right to browse your recent entries.",
            systemImage: "rectangle.stack.fill",
            tint: .pink
        ),
        Page(
            title: "See Your Insights",
            subtitle: "Open Insights to spot patterns and track progress.",
            systemImage: "chart.line.uptrend.xyaxis.circle.fill",
            tint: .orange
        ),
        Page(
            title: "Stay Secure",
            subtitle: "Enable app lock in Settings to keep your journal private.",
            systemImage: "lock.circle.fill",
            tint: .purple
        )
    ]

    let onFinish: () -> Void
    @State private var currentIndex = 0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.black, Color(white: 0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                TabView(selection: $currentIndex) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        VStack(spacing: 18) {
                            Image(systemName: page.systemImage)
                                .font(.system(size: 64, weight: .bold))
                                .foregroundStyle(page.tint)
                                .shadow(color: page.tint.opacity(0.5), radius: 14, y: 6)

                            Text(page.title)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)

                            Text(page.subtitle)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 28)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page)
            }
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 12) {
                    Button(action: onFinish) {
                        Text("Skip")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 18)
                    }
                    .accessibilityLabel("Skip tutorial")

                    Button(action: advanceOrFinish) {
                        Text(currentIndex == pages.count - 1 ? "Get Started" : "Next")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    colors: [.cyan, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                    }
                    .accessibilityLabel(currentIndex == pages.count - 1 ? "Finish tutorial" : "Next tutorial page")
                }
                .padding()
            }
        }
    }

    private func advanceOrFinish() {
        if currentIndex >= pages.count - 1 {
            onFinish()
        } else {
            withAnimation(.easeInOut(duration: 0.2)) {
                currentIndex += 1
            }
        }
    }
}

#Preview {
    TutorialView {}
}

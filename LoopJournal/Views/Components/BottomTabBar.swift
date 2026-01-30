import SwiftUI

/// Personal journal tab bar with privacy-first labeling
struct JournalTabBar: View {
    @Binding var selectedTab: TabSelection
    @State private var isPressed: [Bool] = Array(repeating: false, count: 3)
    
    enum TabSelection {
        case myLoop
        case insights
        case timeline
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // My Loop tab
            tabButton(
                icon: "house.fill",
                label: "My Loop",
                tab: .myLoop,
                index: 0
            )
            
            Spacer()
            
            // Mood Insights tab
            tabButton(
                icon: "chart.bar.fill",
                label: "Insights",
                tab: .insights,
                index: 1
            )

            Spacer()

            // Timeline tab (list view)
            tabButton(
                icon: "calendar",
                label: "Timeline",
                tab: .timeline,
                index: 2
            )
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.black.opacity(0.3))
                .blur(radius: 0.5)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
    
    private func tabButton(icon: String, label: String, tab: TabSelection, index: Int) -> some View {
        let isSelected = selectedTab == tab
        let isPressedState = isPressed[index]
        
        return Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed[index] = true
                selectedTab = tab
            }
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed[index] = false
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: isSelected ? 22 : 20, weight: isSelected ? .bold : .medium))
                    .foregroundStyle(
                        isSelected
                            ? LinearGradient(
                                colors: [.cyan, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [.white.opacity(0.5), .white.opacity(0.3)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                    )
                    .scaleEffect(isPressedState ? 0.9 : 1.0)
                    .shadow(color: isSelected ? .cyan.opacity(0.6) : .clear, radius: 6, y: 2)
                
                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular, design: .rounded))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

/// Custom button style for press animation
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

/// Bottom action buttons for journal entry (bookmark, etc.)
struct JournalActionBar: View {
    let onBookmark: () -> Void
    let onExport: () -> Void
    
    var body: some View {
        HStack(spacing: 24) {
            // Bookmark button
            Button(action: onBookmark) {
                VStack(spacing: 4) {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.cyan, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Text("Save")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Export button
            Button(action: onExport) {
                VStack(spacing: 4) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 24))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Text("Export")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
        )
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack {
            Spacer()
            JournalTabBar(selectedTab: .constant(.myLoop))
        }
    }
}

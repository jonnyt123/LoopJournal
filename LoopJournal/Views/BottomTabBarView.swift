import SwiftUI

struct BottomTabBar: View {
    @Binding var selectedTab: Int
    var body: some View {
        HStack {
            tabButton(icon: "house.fill", index: 0)
            Spacer()
            tabButton(icon: "plus.circle.fill", index: 1)
            Spacer()
            tabButton(icon: "chart.bar.fill", index: 2)
            Spacer()
            tabButton(icon: "gearshape.fill", index: 3)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 18)
        .background(
            BlurView(style: .systemUltraThinMaterialDark)
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(
                    LinearGradient(colors: [.cyan, .purple, .pink], startPoint: .leading, endPoint: .trailing),
                    lineWidth: 2
                )
                .opacity(0.7)
        )
        .shadow(color: .cyan.opacity(0.18), radius: 18, y: 4)
        .padding(.horizontal, 24)
        .padding(.bottom, 12)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: selectedTab)
    }
    
    func tabButton(icon: String, index: Int) -> some View {
        Button(action: { withAnimation { selectedTab = index } }) {
            ZStack {
                Circle()
                    .fill(selectedTab == index ? Color.cyan.opacity(0.18) : Color.clear)
                    .frame(width: 48, height: 48)
                    .shadow(color: selectedTab == index ? .cyan.opacity(0.4) : .clear, radius: 10, y: 4)
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(selectedTab == index ? .cyan : .white.opacity(0.7))
                    .scaleEffect(selectedTab == index ? 1.18 : 1.0)
                    .shadow(color: selectedTab == index ? .cyan.opacity(0.5) : .clear, radius: 8)
            }
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: selectedTab == index ? [.cyan, .purple, .pink] : [.clear, .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .shadow(color: selectedTab == index ? .cyan : .clear, radius: 8)
            )
        }
    }
}

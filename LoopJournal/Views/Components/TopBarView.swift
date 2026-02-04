import SwiftUI

/// Single source of truth for the Entry Pager top bar (logo + Settings). Placement via safeAreaInset in TimelineView (CarouselLayout).
struct TopBarView: View {
    @Binding var isProfilePresented: Bool
    var onListTap: (() -> Void)? = nil

    private enum Layout {
        static let horizontalPadding: CGFloat = 20
        static let verticalPadding: CGFloat = 6
        static let minHeight: CGFloat = 44
        static let iconSpacing: CGFloat = 12
        static let brandingSpacing: CGFloat = 8
    }

    /// Used by layout regression tests; do not remove.
    static var layoutMinHeightForRegressionTests: CGFloat { Layout.minHeight }
    static var layoutHorizontalPaddingForRegressionTests: CGFloat { Layout.horizontalPadding }

    var body: some View {
        HStack(spacing: Layout.iconSpacing) {
            // Left: App branding (leading-aligned)
            HStack(spacing: Layout.brandingSpacing) {
                Image(systemName: "infinity.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan, .purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .purple.opacity(0.5), radius: 8, x: 0, y: 2)
                
                Text("LoopJournal")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            
            Spacer()
            
            // Right: List + Settings
            HStack(spacing: 16) {
                if let onListTap = onListTap {
                    Button(action: onListTap) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }

                Button(action: { isProfilePresented.toggle() }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: Layout.minHeight)
        .padding(.horizontal, Layout.horizontalPadding)
        .padding(.vertical, Layout.verticalPadding)
        .background(Color.black.opacity(0.001))
        .contentShape(Rectangle())
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("carousel_top_bar")
    }
}

/// Blur view wrapper for iOS
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack {
            TopBarView(isProfilePresented: .constant(false), onListTap: {})
            Spacer()
        }
    }
}

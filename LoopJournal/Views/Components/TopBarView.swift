import SwiftUI

/// Minimal top bar with personal branding
struct TopBarView: View {
    @Binding var isProfilePresented: Bool
    var onListTap: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 0) {
            // Left: App branding
            HStack(spacing: 8) {
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
            .padding(.leading, 20)
            
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
                .padding(.trailing, 4)
            }
            .padding(.trailing, 12)
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
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

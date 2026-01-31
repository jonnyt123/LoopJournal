import SwiftUI

/// Minimal top bar with personal branding
struct TopBarView: View {
    @Binding var isProfilePresented: Bool
    var onListTap: (() -> Void)? = nil
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            // Left: App branding
            HStack(alignment: .firstTextBaseline, spacing: 8) {
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
                    .alignmentGuide(.firstTextBaseline) { dimensions in
                        dimensions[.bottom]
                    }
                
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
            .alignmentGuide(.firstTextBaseline) { dimensions in
                dimensions[.firstTextBaseline]
            }
            .padding(.leading, 20)
            
            Spacer()
            
            // Right: List + Settings
            HStack(alignment: .firstTextBaseline, spacing: 16) {
                if let onListTap = onListTap {
                    Button(action: onListTap) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .alignmentGuide(.firstTextBaseline) { dimensions in
                        dimensions[.bottom]
                    }
                }

                Button(action: { isProfilePresented.toggle() }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.8))
                }
                .alignmentGuide(.firstTextBaseline) { dimensions in
                    dimensions[.bottom]
                }
            }
            .alignmentGuide(.firstTextBaseline) { dimensions in
                dimensions[.firstTextBaseline]
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.001))
        .contentShape(Rectangle())
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

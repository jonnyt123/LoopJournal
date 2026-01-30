import SwiftUI

struct TopBarView: View {
    let date: Date
    var body: some View {
        ZStack {
            // Glassmorphism blur background
            BlurView(style: .systemUltraThinMaterialDark)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: .black.opacity(0.18), radius: 12, y: 4)
                .padding(.horizontal, 8)
                .frame(height: 54)
            HStack {
                // Left: Date
                Text(date, format: .dateTime.month(.abbreviated).day())
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.leading, 12)
                Spacer()
                // Center: App name/logo
                Text("LoopJournal")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(LinearGradient(colors: [.pink, .purple, .blue], startPoint: .leading, endPoint: .trailing))
                    .shadow(color: .purple.opacity(0.3), radius: 6, y: 2)
                Spacer()
                // Right: Profile icon (placeholder)
                Image(systemName: "person.crop.circle")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.trailing, 12)
            }
            .frame(height: 54)
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(Color.clear)
    }
// UIKit blur wrapper for glassmorphism
struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
}

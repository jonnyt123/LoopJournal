import SwiftUI

struct FirstLaunchGateView: View {
    let onContinue: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image with proper scaling for all iPhone sizes
                Image("LaunchBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea()

                // Subtle gradient overlay (reduced opacity to preserve image beauty)
                LinearGradient(
                    colors: [Color.black.opacity(0.0), Color.black.opacity(0.3)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack {
                    Spacer()
                }
                .safeAreaInset(edge: .bottom) {
                Button(action: onContinue) {
                    Text("Get Started")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .padding(.vertical, 14)
                        .frame(maxWidth: 220)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.25), radius: 12, y: 6)
                }
                .accessibilityLabel("Get started")
                .padding(.bottom, 40)
                .padding(.horizontal)
            }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    FirstLaunchGateView {}
}

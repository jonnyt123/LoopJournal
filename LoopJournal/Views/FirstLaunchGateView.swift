import SwiftUI

struct FirstLaunchGateView: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Image("LaunchBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            LinearGradient(
                colors: [Color.black.opacity(0.0), Color.black.opacity(0.65)],
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
                .padding()
            }
        }
    }
}

#Preview {
    FirstLaunchGateView {}
}

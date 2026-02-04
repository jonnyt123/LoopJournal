import SwiftUI

/// Preference key for lock screen container size (adaptive layout: size from background only).
private struct LockScreenBaseSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

/// Custom lock screen shown when app is locked
struct LockScreenView: View {
    @ObservedObject var authManager: AuthManager
    @State private var isAnimating = false
    @Environment(\.scenePhase) private var scenePhase
    @State private var isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
    @State private var baseSize: CGFloat = 400

    private var lockSizes: (glow: CGFloat, logo: CGFloat, biometric: CGFloat, icon: CGFloat) {
        (baseSize * 0.42, baseSize * 0.28, baseSize * 0.18, baseSize * 0.075)
    }

    var body: some View {
        lockContent
    }

    private var lockContent: some View {
        ZStack {
            // Background with blur
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.1),
                    Color(red: 0.1, green: 0.1, blue: 0.15)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Blur overlay effect
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                    Spacer()

                    // App logo with animation (sizes from baseSize for adaptive layout)
                    ZStack {
                        // Outer glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        .cyan.opacity(0.3),
                                        .purple.opacity(0.2),
                                        .clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: lockSizes.glow * 0.55
                                )
                            )
                            .frame(width: lockSizes.glow, height: lockSizes.glow)
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                            .animation(
                                .easeInOut(duration: 2)
                                .repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                        
                        // Logo circle
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.1, green: 0.1, blue: 0.2),
                                        Color(red: 0.15, green: 0.15, blue: 0.25)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: lockSizes.logo, height: lockSizes.logo)
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [.cyan, .purple, .pink],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 3
                                    )
                            )
                        
                        // Infinity icon
                        Image(systemName: "infinity.circle.fill")
                            .font(.system(size: lockSizes.icon))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.cyan, .purple, .pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .cyan.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    
                    // Title
                    Text("LoopJournal")
                        .font(.system(size: max(22, baseSize * 0.06), weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                    
                    Spacer()
                    
                    // Unlock instruction
                    VStack(spacing: 24) {
                        Text("Unlock LoopJournal")
                            .font(.system(size: max(16, baseSize * 0.045), weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        
                        // Biometric button
                        Button(action: {
                            Task {
                                await authManager.authenticate()
                            }
                        }) {
                            ZStack {
                                // Background circle
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.cyan.opacity(0.2), .purple.opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: lockSizes.biometric, height: lockSizes.biometric)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    colors: [.cyan, .purple],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 2
                                            )
                                    )
                                
                                // Biometric icon
                                Image(systemName: authManager.biometricType.iconName)
                                    .font(.system(size: lockSizes.biometric * 0.45))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.cyan, .purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                        }
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                        .animation(
                            .easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                        .disabled(authManager.isAuthenticating)
                        
                        // Authentication status
                        if let error = authManager.authenticationError {
                            Text(error)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.red.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        if authManager.isAuthenticating {
                            ProgressView()
                                .tint(.cyan)
                                .scaleEffect(1.2)
                        }
                        
                        // Biometric type info
                        Text(authManager.biometricType.displayName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    // Privacy reminder
                    HStack(spacing: 6) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12))
                        Text("Your journal is private and secure")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.5))
                    .padding()
                    .safeAreaPadding(.bottom)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    GeometryReader { g in
                        Color.clear.preference(
                            key: LockScreenBaseSizePreferenceKey.self,
                            value: min(g.size.width, g.size.height)
                        )
                    }
                )
        }
        .onPreferenceChange(LockScreenBaseSizePreferenceKey.self) { baseSize = $0 }
        .onAppear {
            isAnimating = canAnimate
        }
        .onChange(of: scenePhase) { _, _ in
            isAnimating = canAnimate
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSProcessInfoPowerStateDidChange)) { _ in
            isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
            isAnimating = canAnimate
        }
    }

    private var canAnimate: Bool {
        scenePhase == .active && !isLowPowerMode
    }
}

/// Preview
struct LockScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LockScreenView(authManager: AuthManager.shared)
    }
}

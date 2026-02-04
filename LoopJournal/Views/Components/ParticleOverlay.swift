import SwiftUI

struct ParticleOverlay: View {
    let emoji: String
    let count: Int
    @State private var animate = false
    @Environment(\.scenePhase) private var scenePhase
    @State private var isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
    private let particles: [Particle]

    private struct Particle: Identifiable {
        let id = UUID()
        let angle: Double
        let radius: CGFloat
        let size: CGFloat
        let duration: Double
        let opacity: Double
    }

    init(emoji: String, count: Int) {
        self.emoji = emoji
        let cappedCount = min(count, 6)
        self.count = cappedCount
        var generator = SystemRandomNumberGenerator()
        self.particles = (0..<cappedCount).map { i in
            let angle = Double(i) / Double(max(cappedCount, 1)) * 2 * .pi
            return Particle(
                angle: angle,
                radius: CGFloat.random(in: 70...150, using: &generator),
                size: CGFloat.random(in: 26...40, using: &generator),
                duration: Double.random(in: 4.0...7.0, using: &generator),
                opacity: Double.random(in: 0.08...0.14, using: &generator)
            )
        }
    }
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                let x = cos(particle.angle) * particle.radius
                let y = sin(particle.angle) * particle.radius
                Text(emoji)
                    .font(.system(size: particle.size))
                    .opacity(particle.opacity)
                    .offset(x: animate ? x : 0, y: animate ? y : 0)
                    .blur(radius: 2)
                    .animation(
                        .easeInOut(duration: particle.duration).repeatForever(autoreverses: true),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = canAnimate
        }
        .onChange(of: scenePhase) { _, _ in
            animate = canAnimate
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSProcessInfoPowerStateDidChange)) { _ in
            isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
            animate = canAnimate
        }
        .drawingGroup()
    }

    private var canAnimate: Bool {
        scenePhase == .active && !isLowPowerMode
    }
}

import SwiftUI

/// Interactive media preview that can be tapped to enlarge
struct MediaPreviewView: View {
    let media: MediaType
    @State private var isExpanded: Bool = false
    @State private var image: UIImage?
    @State private var animateWave = false
    private let waveHeights: [CGFloat] = [24, 40, 56, 36, 28]
    @Environment(\.scenePhase) private var scenePhase
    @State private var isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
    
    var body: some View {
        Group {
            if isExpanded {
                ExpandableMediaView(
                    media: media,
                    isExpanded: $isExpanded,
                    image: image
                )
            } else {
                compactView
            }
        }
    }
    
    private var compactView: some View {
        Group {
            switch media {
            case .photo(let imageName):
                photoView(imageName: imageName)
            case .voice(let audioName):
                voiceView(audioName: audioName)
            case .link(let url):
                linkView(url: url)
            }
        }
        .onAppear {
            if case .photo(let imageName) = media {
                loadImage(named: imageName)
            }
        }
    }
    
    private func photoView(imageName: String) -> some View {
        ZStack {
            // Placeholder gradient background
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.15), .white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.3), .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
            
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 10)
            } else {
                // Placeholder icon
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white.opacity(0.6), .white.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
        .frame(height: 280)
        .onTapGesture {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                isExpanded = true
            }
        }
    }
    
    private func voiceView(audioName: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.12), .white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [.cyan.opacity(0.4), .purple.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
            
            VStack(spacing: 12) {
                // Animated waveform
                HStack(spacing: 4) {
                    ForEach(0..<5, id: \.self) { index in
                        let baseHeight = waveHeights[index]
                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                LinearGradient(
                                    colors: [.cyan, .purple],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 6, height: baseHeight)
                            .scaleEffect(y: animateWave ? 1.0 : 0.5, anchor: .bottom)
                            .animation(
                                .easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.12),
                                value: animateWave
                            )
                    }
                }
                .frame(height: 60)
                .onAppear {
                    animateWave = canAnimateWave
                }
                .onChange(of: scenePhase) { _, _ in
                    animateWave = canAnimateWave
                }
                .onReceive(NotificationCenter.default.publisher(for: .NSProcessInfoPowerStateDidChange)) { _ in
                    isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
                    animateWave = canAnimateWave
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "waveform")
                        .foregroundColor(.cyan)
                    Text("Voice Note")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 8)
            }
        }
        .frame(height: 200)
    }
    
    private func linkView(url: URL) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [.orange.opacity(0.15), .pink.opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [.orange.opacity(0.4), .pink.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
            
            VStack(spacing: 12) {
                Image(systemName: "link")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text(url.host ?? url.absoluteString)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text("Tap to open")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(20)
        }
        .frame(height: 200)
        .onTapGesture {
            if let url = URL(string: "https://\(url.host ?? url.absoluteString)") {
                UIApplication.shared.open(url)
            }
        }
    }
    
    private func loadImage(named imageName: String) {
        // Try to load from assets
        if let image = UIImage(named: imageName) {
            self.image = image
        }
    }

    private var canAnimateWave: Bool {
        scenePhase == .active && !isLowPowerMode
    }
}

/// Full-screen expanded media view
struct ExpandableMediaView: View {
    let media: MediaType
    @Binding var isExpanded: Bool
    let image: UIImage?
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isExpanded = false
                    }
                }
            
            // Close button
            VStack {
                HStack {
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            isExpanded = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white.opacity(0.8), .white.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(radius: 4)
                    }
                    .padding(.top, 50)
                    .padding(.leading, 20)
                    
                    Spacer()
                }
                
                Spacer()
            }
            
            // Media content
            Group {
                switch media {
                case .photo(let imageName):
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
                    } else if let img = UIImage(named: imageName) {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
                    }
                case .voice(let audioName):
                    VStack(spacing: 20) {
                        Image(systemName: "waveform")
                            .font(.system(size: 80))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.cyan, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Text("Voice Note: \(audioName)")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                    }
                case .link(let url):
                    VStack(spacing: 20) {
                        Image(systemName: "link")
                            .font(.system(size: 80))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Text(url.absoluteString)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
            }
            .padding(.horizontal, 30)
        }
        .transition(.opacity)
    }
}

#Preview {
    MediaPreviewView(media: .photo(imageName: "photo1"))
}

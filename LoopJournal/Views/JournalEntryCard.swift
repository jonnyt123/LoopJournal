import SwiftUI
import Combine
import CoreData
import AVFoundation

/// A full-screen card displaying a single journal entry
/// Personal, private offline-first experience
struct JournalEntryCard: View {
        @State private var showShareSheet = false
        @State private var pdfURL: URL?
    let entry: MoodEmojisProvider
    var showBackground: Bool = true
    var onDelete: (() -> Void)? = nil
    @State private var isBookmarked: Bool = false
    @State private var showMediaFull: Bool = false
    @StateObject private var voicePlayback = VoicePlaybackController()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if showBackground {
                    MoodBackgroundView(moodEmojis: moodEmojis)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.4), value: moodEmojis.first ?? "")
                }

                entryCardView(in: geometry)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .onDisappear {
            voicePlayback.stop()
        }
    }

    // UIKit wrapper for UIActivityViewController (PDF only, no social)
    struct SharePDFViewController: UIViewControllerRepresentable {
        let url: URL
        func makeUIViewController(context: Context) -> UIActivityViewController {
            let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            activity.excludedActivityTypes = [
                .postToFacebook,
                .postToTwitter,
                .postToWeibo,
                .postToFlickr,
                .postToVimeo,
                .postToTencentWeibo,
                .assignToContact,
                .saveToCameraRoll,
                .addToReadingList,
                .markupAsPDF,
                .print,
                .copyToPasteboard,
                .message,
                .mail,
                .airDrop,
                .openInIBooks
            ]
            return activity
        }
        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    }
    
    /// Mood gradient colors for record animation
    private var moodEmojis: [String] {
        entry.moodEmojis
    }

    private var noteText: String {
        entry.noteText
    }

    private var entryDate: Date {
        entry.entryDate
    }

    private var voiceNoteURL: URL? {
        entry.voiceNoteURL
    }

    private var moodDisplayText: String {
        let emoji = moodEmojis.first ?? "🙂"
        let label = moodLabel(for: emoji)
        return "\(emoji) \(label)"
    }

    private func entryCardView(in geometry: GeometryProxy) -> some View {
        let screenWidth = geometry.size.width
        let screenHeight = geometry.size.height
        let cardWidth = min(screenWidth * CarouselLayout.cardWidthFraction, CarouselLayout.cardMaxWidth)
        let cardHeight = min(max(screenHeight * CarouselLayout.cardHeightFraction, CarouselLayout.cardMinHeight), CarouselLayout.cardMaxHeight)
        return ZStack {
            RoundedRectangle(cornerRadius: CarouselLayout.cardCornerRadius, style: .continuous)
                .fill(Color.white.opacity(0.06))
            RoundedRectangle(cornerRadius: CarouselLayout.cardCornerRadius, style: .continuous)
                .fill(Color.white.opacity(0.08))
            RoundedRectangle(cornerRadius: CarouselLayout.cardCornerRadius, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text(entryDate, format: .dateTime.weekday(.wide).month().day())
                        .font(.system(size: screenWidth < 380 ? 13 : 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))

                    Text(moodDisplayText)
                        .font(.system(size: screenWidth < 380 ? 15 : 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)

                    Text(noteText.isEmpty ? "No entry text yet." : noteText)
                        .font(.system(size: screenWidth < 380 ? 16 : 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let voiceNoteURL = voiceNoteURL {
                        VoicePlaybackRow(
                            url: voiceNoteURL,
                            isPlaying: voicePlayback.isPlaying,
                            onToggle: { voicePlayback.toggle(url: voiceNoteURL) }
                        )
                    }
                }
                .padding(CarouselLayout.cardContentPadding)
            }
            .scrollIndicators(.hidden)
        }
        .frame(width: cardWidth, height: cardHeight)
        .shadow(color: Color.black.opacity(0.22), radius: 8, y: 4)
        .overlay(alignment: .topTrailing) {
            if let onDelete = onDelete {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 34, height: 34)
                        .background(Color.black.opacity(0.35))
                        .clipShape(Circle())
                }
                .padding(CarouselLayout.cardDeleteButtonInset)
                .contentShape(Rectangle())
            }
        }
    }

    private func moodLabel(for emoji: String) -> String {
        switch emoji {
        case "😄", "😃", "😊", "😁", "🙂", "🥳": return "Happy"
        case "😢", "😔", "😞", "☹️", "🙁", "😿": return "Sad"
        case "😌", "😇", "🧘", "😴", "🫶": return "Calm"
        case "🎧": return "Focus"
        case "💭": return "Reflective"
        case "🧠": return "Productive"
        case "🌈": return "Joyful"
        case "😡": return "Angry"
        case "😰": return "Anxious"
        default: return "Mood"
        }
    }

    /// Formats date as "JAN 23"
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date).uppercased()
    }
    
    /// Formats date as day name (e.g., "Monday")
    func formattedDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
}

/// Spinning record animation for mood indicator
struct RecordSpinView: View {
    let colors: [Color]
    @State private var isAnimating: Bool = false
    
    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .strokeBorder(
                    AngularGradient(
                        colors: colors.map { $0.opacity(0.4) },
                        center: .center
                    ),
                    lineWidth: 2
                )
                .frame(width: 44, height: 44)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(
                    .linear(duration: 4)
                    .repeatForever(autoreverses: false),
                    value: isAnimating
                )
            
            // Inner record
            Circle()
                .fill(
                    LinearGradient(
                        colors: colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 28, height: 28)
                .overlay(
                    Circle()
                        .fill(Color.black.opacity(0.4))
                        .frame(width: 8, height: 8)
                )
        }
        .onAppear {
            isAnimating = true
        }
    }
}

/// Preview
struct JournalEntryCard_Previews: PreviewProvider {
    static var previews: some View {
        JournalEntryCard(entry: DummyData.entries[0])
            .previewLayout(.fixed(width: 390, height: 844))
    }
}

final class VoicePlaybackController: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false
    private var player: AVAudioPlayer?

    func toggle(url: URL) {
        if isPlaying {
            pause()
        } else {
            play(url: url)
        }
    }

    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
    }

    private func play(url: URL) {
        guard FileManager.default.fileExists(atPath: url.path) else {
            isPlaying = false
            return
        }
        do {
            if player?.url != url {
                player = try AVAudioPlayer(contentsOf: url)
                player?.delegate = self
            }
            player?.play()
            isPlaying = true
        } catch {
            isPlaying = false
        }
    }

    private func pause() {
        player?.pause()
        isPlaying = false
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
}

struct VoicePlaybackRow: View {
    let url: URL
    let isPlaying: Bool
    let onToggle: () -> Void

    private let waveHeights: [CGFloat] = [6, 12, 18, 10, 16, 8, 14]

    var body: some View {
        let isAnimating = isPlaying
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Circle())
            }

            HStack(spacing: 4) {
                ForEach(waveHeights.indices, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.cyan.opacity(0.8))
                        .frame(width: 4, height: waveHeights[index])
                        .scaleEffect(y: isAnimating ? 1.0 : 0.6, anchor: .bottom)
                        .animation(
                            .easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.08),
                            value: isAnimating
                        )
                }
            }

            Text("Voice note")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.7))

            Spacer()
        }
        .padding(10)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityLabel(isPlaying ? "Pause voice note" : "Play voice note")
    }
}

// Protocol for moodEmojis support
public protocol MoodEmojisProvider {
    var moodEmojis: [String] { get }
    var noteText: String { get }
    var entryDate: Date { get }
    var voiceNoteURL: URL? { get }
}

extension JournalEntry: MoodEmojisProvider {
    public var noteText: String { note }
    public var entryDate: Date { date }
    public var voiceNoteURL: URL? { nil }
}

extension JournalEntryModel: MoodEmojisProvider {
    public var noteText: String { note }
    public var entryDate: Date { date }
}

// MARK: - Mood Background

struct MoodBackgroundView: View {
    let moodEmojis: [String]
    var showEffects: Bool = true
    @State private var isVisible = false
    @AppStorage("backgroundEffectsEnabled") private var backgroundEffectsEnabled = true

    var body: some View {
        let backgroundImageName = MoodStyle.backgroundImageName(for: moodEmojis)
        let effectiveEffects = showEffects && backgroundEffectsEnabled
        let allowBackgroundAnimation = effectiveEffects && backgroundImageName == nil
        ZStack {
            if let backgroundImageName {
                Image(backgroundImageName)
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(1.08)
                    .blur(radius: allowBackgroundAnimation ? (isVisible ? 0 : 10) : 0)
                    .transition(.opacity)
                    .animation(allowBackgroundAnimation ? .easeInOut(duration: 0.4) : nil, value: backgroundImageName)
                    .ignoresSafeArea()
            } else {
                MoodStyle.gradient(for: moodEmojis.first ?? "")
                    .scaleEffect(1.08)
                    .blur(radius: effectiveEffects ? (isVisible ? 0 : 10) : 0)
                    .transition(.opacity)
                    .animation(effectiveEffects ? .easeInOut(duration: 0.4) : nil, value: moodEmojis.first ?? "")
                    .ignoresSafeArea()
            }

            if effectiveEffects {
                MoodStyle.washGradient(for: moodEmojis)
                    .blendMode(.screen)
                    .opacity(0.55)
                    .ignoresSafeArea()

                ParticleOverlay(emoji: moodEmojis.first ?? "✨", count: 8)
                    .allowsHitTesting(false)
                    .drawingGroup()
            }

            LinearGradient(
                colors: [
                    Color.black.opacity(0.18),
                    Color.black.opacity(0.05),
                    Color.black.opacity(0.38)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
        .drawingGroup()
        .onAppear {
            if effectiveEffects {
                withAnimation(.easeInOut(duration: 0.4)) {
                    isVisible = true
                }
            } else {
                isVisible = true
            }
        }
    }
}

private enum MoodStyle {
    static func backgroundImageName(for emojis: [String]) -> String? {
        let happyEmojis: Set<String> = ["😄", "😃", "😊", "😁", "🙂", "🥳"]
        let sadEmojis: Set<String> = ["😢", "😔", "😞", "☹️", "🙁", "😿"]
        let calmEmojis: Set<String> = ["😌", "😇", "🧘", "😴", "🫶"]
        let focusedEmojis: Set<String> = ["🎧"]
        let reflectiveEmojis: Set<String> = ["💭"]
        let productiveEmojis: Set<String> = ["🧠"]
        let inspiredEmojis: Set<String> = ["🌈"]
        let angryEmojis: Set<String> = ["😡"]
        let anxiousEmojis: Set<String> = ["😰"]
        if emojis.contains(where: { happyEmojis.contains($0) }) {
            return "HappyBackground"
        }
        if emojis.contains(where: { sadEmojis.contains($0) }) {
            return "SadBackground"
        }
        if emojis.contains(where: { calmEmojis.contains($0) }) {
            return "CalmBackground"
        }
        if emojis.contains(where: { focusedEmojis.contains($0) }) {
            return "FocusedBackground"
        }
        if emojis.contains(where: { reflectiveEmojis.contains($0) }) {
            return "ReflectiveBackground"
        }
        if emojis.contains(where: { productiveEmojis.contains($0) }) {
            return "ProductiveBackground"
        }
        if emojis.contains(where: { inspiredEmojis.contains($0) }) {
            return "InspiredBackground"
        }
        if emojis.contains(where: { angryEmojis.contains($0) }) {
            return "AngryBackground"
        }
        if emojis.contains(where: { anxiousEmojis.contains($0) }) {
            return "AnxiousBackground"
        }
        return "LaunchBackground"
    }

    static func gradientColors(for emojis: [String]) -> [Color] {
        switch emojis.first {
        case "😄", "😃", "😊", "😁", "🙂", "🥳": return [.yellow, .pink]
        case "😢", "😔", "😞", "☹️", "🙁", "😿": return [.blue, .purple]
        case "😌", "😇", "🧘", "😴", "🫶": return [.mint, .cyan]
        case "🎧": return [.orange, .red]
        case "💭": return [.indigo, .teal]
        case "🧠": return [.green, .teal]
        case "🌈": return [.orange, .pink]
        case "😡": return [.red, .orange]
        case "😰": return [.teal, .indigo]
        default: return [.gray, .gray.opacity(0.5)]
        }
    }

    static func washGradient(for emojis: [String]) -> LinearGradient {
        let colors = gradientColors(for: emojis)
        let start = colors.first?.opacity(0.35) ?? Color.white.opacity(0.12)
        let end = colors.last?.opacity(0.28) ?? Color.white.opacity(0.08)
        return LinearGradient(colors: [start, end], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static func gradient(for mood: String) -> LinearGradient {
        switch mood {
        case "😄", "😃", "😊", "😁", "🙂", "🥳":
            return LinearGradient(colors: [ThemeColors.yellow, ThemeColors.orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "😢", "😔", "😞", "☹️", "🙁", "😿":
            return LinearGradient(colors: [ThemeColors.blue, ThemeColors.indigo], startPoint: .top, endPoint: .bottom)
        case "😌", "😇", "🧘", "😴", "🫶":
            return LinearGradient(colors: [ThemeColors.mint, ThemeColors.lavender], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "🎧":
            return LinearGradient(colors: [ThemeColors.purple, ThemeColors.electricBlue], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "💭":
            return LinearGradient(colors: [ThemeColors.lightGrey, ThemeColors.lightBlue], startPoint: .top, endPoint: .bottom)
        case "🧠":
            return LinearGradient(colors: [ThemeColors.teal, ThemeColors.navy], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "🌈":
            return LinearGradient(colors: ThemeColors.rainbow, startPoint: .topLeading, endPoint: .bottomTrailing)
        case "😡":
            return LinearGradient(colors: [ThemeColors.orange, ThemeColors.red], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "😰":
            return LinearGradient(colors: [ThemeColors.teal, ThemeColors.indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: ThemeColors.defaultGradient, startPoint: .top, endPoint: .bottom)
        }
    }
}

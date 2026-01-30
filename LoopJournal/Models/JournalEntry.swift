import Foundation
import SwiftUI
import CoreData

/// Represents a single journal entry with mood, media, and note.
struct JournalEntry: Identifiable {
    let id: UUID
    let date: Date
    let moodEmojis: [String] // 1–3 emojis
    let note: String
    let media: MediaType?
    let mood: Mood
    let theme: Theme
}

extension JournalEntry {
    init?(entity: JournalEntryEntity) {
        guard let date = entity.date else { return nil }
        let moodEmojis = entity.moodEmojisArray
        guard let mood = moodFromEmojis(moodEmojis) else { return nil }
        let media: MediaType? = nil
        self.id = entity.uuid ?? UUID()
        self.date = date
        self.moodEmojis = moodEmojis
        self.note = entity.note ?? ""
        self.media = media
        self.mood = mood
        self.theme = .defaultDark
    }
}

private func moodFromEmojis(_ emojis: [String]) -> Mood? {
    for token in emojis {
        if let mood = moodFromToken(token) {
            return mood
        }
    }
    return nil
}

/// Supported media types for a journal entry.
enum MediaType {
    case photo(imageName: String)
    case voice(audioName: String)
    case link(url: URL)
}

/// Mood types for gradient theming
enum Mood: String, CaseIterable {
    case happy
    case sad
    case calm
    case focused
    case reflective
    case productive
    case inspired
    case angry
    case anxious

    /// Returns the gradient colors as UIColors for PDF export
    var gradientColors: [UIColor] {
        switch self {
        case .happy:
            return [UIColor.systemYellow, UIColor.systemPink]
        case .sad:
            return [UIColor.systemBlue, UIColor.systemIndigo]
        case .calm:
            return [UIColor.systemMint, UIColor.systemTeal]
        case .focused:
            return [UIColor.systemPurple, UIColor.systemBlue]
        case .reflective:
            return [UIColor.systemIndigo, UIColor.systemTeal]
        case .productive:
            return [UIColor.systemGreen, UIColor.systemTeal]
        case .inspired:
            return [UIColor.systemOrange, UIColor.systemPink]
        case .angry:
            return [UIColor.systemRed, UIColor.systemOrange]
        case .anxious:
            return [UIColor.systemTeal, UIColor.systemIndigo]
        }
    }
    
    /// Returns the gradient colors for this mood
    var gradient: LinearGradient {
        switch self {
        case .happy:
            return LinearGradient(
                colors: [Color.yellow.opacity(0.8), Color.pink.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .sad:
            return LinearGradient(
                colors: [Color.blue.opacity(0.8), Color.indigo.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .calm:
            return LinearGradient(
                colors: [Color.mint.opacity(0.8), Color.teal.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .focused:
            return LinearGradient(
                colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .reflective:
            return LinearGradient(
                colors: [Color.indigo.opacity(0.8), Color.teal.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .productive:
            return LinearGradient(
                colors: [Color.green.opacity(0.8), Color.teal.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .inspired:
            return LinearGradient(
                colors: [Color.orange.opacity(0.9), Color.pink.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .angry:
            return LinearGradient(
                colors: [Color.red.opacity(0.9), Color.orange.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .anxious:
            return LinearGradient(
                colors: [Color.teal.opacity(0.9), Color.indigo.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

/// Helper function to get gradient for mood array
func getGradient(for moods: [String]) -> LinearGradient {
    let normalizedMoods = moods.map { mood in
        switch mood.lowercased() {
        case "happy", "😃", "😄", "😊", "😁", "🙂", "🥳":
            return Mood.happy
        case "sad", "😔", "😢", "😞", "☹️", "🙁", "😿":
            return Mood.sad
        case "calm", "😌", "😇", "🧘", "😴", "🫶":
            return Mood.calm
        case "focused", "🎧":
            return Mood.focused
        case "reflective", "💭", "🤔":
            return Mood.reflective
        case "productive", "🧠":
            return Mood.productive
        case "inspired", "🌈":
            return Mood.inspired
        case "angry", "😡":
            return Mood.angry
        case "anxious", "😰":
            return Mood.anxious
        default:
            return Mood.calm
        }
    }
    
    // Use the first dominant mood for gradient
    let dominantMood = normalizedMoods.first ?? Mood.calm
    return dominantMood.gradient
}

private func moodFromToken(_ token: String) -> Mood? {
    switch token.lowercased() {
    case "happy", "😃", "😄", "😊", "😁", "🙂", "🥳":
        return .happy
    case "sad", "😔", "😢", "😞", "☹️", "🙁", "😿":
        return .sad
    case "calm", "😌", "😇", "🧘", "😴", "🫶":
        return .calm
    case "focused", "🎧":
        return .focused
    case "reflective", "💭", "🤔":
        return .reflective
    case "productive", "🧠":
        return .productive
    case "inspired", "🌈":
        return .inspired
    case "angry", "😡":
        return .angry
    case "anxious", "😰":
        return .anxious
    default:
        return nil
    }
}

/// Supported themes for personalization.
enum Theme: String, CaseIterable {
    case defaultDark, neon, retro, scrapbook
}
